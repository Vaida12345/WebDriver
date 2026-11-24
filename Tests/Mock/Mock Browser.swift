//
//  Mock Browser.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation
import AppKit
import WebKit
@testable
import WebDriver


/// A stand-in for a WebDriver server, backed by an in-process `WKWebView`.
///
/// Requests made by a ``startSession()`` session are intercepted by ``MockWebDriverProtocol`` and evaluated against the web view's DOM, so tests exercise the real HTTP and script paths without launching a browser.
///
/// Only the endpoints needed by the tests are implemented: creating and deleting the session, getting and switching the window, finding elements, executing scripts, and taking screenshots. Other endpoints respond with `unknown command`.
@MainActor
final class MockBrowser {

    private static var browsers: [String : MockBrowser] = [:]

    /// The identifier of the browser, used as the host of the WebDriver URL.
    let id = "mock-" + UUID().uuidString.lowercased()

    let webView = WKWebView()

    private let navigation = NavigationWaiter()

    /// The `alwaysMatch` capabilities of the last new-session request.
    private(set) var capabilities: [String : Any] = [:]

    /// Replaces the base64 value returned by the screenshot endpoints, to test undecodable responses.
    var screenshotOverride: String?

    /// The size of the image returned by the viewport screenshot endpoint.
    static let viewportScreenshotSize = (width: 4, height: 3)

    /// The size of the image returned by the full-page screenshot endpoint.
    static let fullPageScreenshotSize = (width: 4, height: 10)


    init(html: String) async throws {
        self.webView.navigationDelegate = self.navigation
        try await withCheckedThrowingContinuation { continuation in
            self.navigation.continuation = continuation
            self.webView.loadHTMLString(html, baseURL: nil)
        }
        Self.browsers[self.id] = self
    }

    static func browser(for host: String?) -> MockBrowser? {
        host.flatMap { self.browsers[$0] }
    }

    /// Starts a session that talks to `self`.
    func startSession(driver: WebDriver.Firefox? = nil) async throws -> Session {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockWebDriverProtocol.self]
        let launcher = LinkedLauncher(driver: try driver ?? WebDriver.Firefox(), host: self.id, port: 4444)
        return try await Session(launcher: launcher, context: .unavailable, invoker: #function, urlSessionConfiguration: configuration)
    }

    /// Handles a WebDriver request, returning the status code and the JSON body.
    func respond(method: String, path: [String], body: [String : Any]) async -> (Int, Data) {
        // Drop the session id, which is always the second component.
        let route = path.enumerated().filter { $0.offset != 1 }.map { $0.offset == 3 && path.count >= 4 && path[2] == "element" ? "{id}" : $0.element }
        let find = ["using": body["using"] ?? "", "value": body["value"] ?? ""]
        
        switch (method, route.joined(separator: "/")) {
        case ("POST", "session"):
            self.capabilities = (body["capabilities"] as? [String : Any])?["alwaysMatch"] as? [String : Any] ?? [:]
            return Self.ok(["sessionId": "session"])
        case ("GET", "session/screenshot"):
            return Self.ok(self.screenshotOverride ?? Self.png(size: Self.viewportScreenshotSize))
        case ("GET", "session/moz/screenshot/full"):
            return Self.ok(self.screenshotOverride ?? Self.png(size: Self.fullPageScreenshotSize))
        case ("DELETE", "session"):
            Self.browsers[self.id] = nil
            return Self.ok(NSNull())
        case ("GET", "session/window"):
            return Self.ok("window")
        case ("POST", "session/window"):
            return Self.ok(NSNull())
        case ("POST", "session/element"):
            return await self.evaluate("find", find)
        case ("POST", "session/elements"):
            return await self.evaluate("findAll", find)
        case ("POST", "session/element/{id}/element"):
            return await self.evaluate("find", find.merging(["root": path[3]]) { $1 })
        case ("POST", "session/element/{id}/elements"):
            return await self.evaluate("findAll", find.merging(["root": path[3]]) { $1 })
        case ("POST", "session/execute/sync"):
            return await self.evaluate("execute", ["script": body["script"] ?? "", "args": body["args"] ?? []])
        default:
            return Self.error(404, "unknown command", "\(method) /\(path.joined(separator: "/")) is not implemented by MockBrowser")
        }
    }
    
    private func evaluate(_ action: String, _ payload: [String : Any]) async -> (Int, Data) {
        do {
            let result = try await self.webView.callAsyncJavaScript(Self.dispatcher, arguments: ["action": action, "payload": payload], contentWorld: .page)
            guard let string = result as? String,
                  let object = try JSONSerialization.jsonObject(with: Data(string.utf8)) as? [String : Any],
                  let status = object["status"] as? Int,
                  let body = object["body"] else {
                return Self.error(500, "unknown error", "Malformed dispatcher result: \(String(describing: result))")
            }
            return (status, try JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed))
        } catch {
            return Self.error(500, "javascript error", "\(error)")
        }
    }

    /// Returns a base64-encoded PNG image of the given size.
    private static func png(size: (width: Int, height: Int)) -> String {
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size.width, pixelsHigh: size.height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        return bitmap.representation(using: .png, properties: [:])!.base64EncodedString()
    }

    private static func ok(_ value: Any) -> (Int, Data) {
        (200, try! JSONSerialization.data(withJSONObject: ["value": value]))
    }

    private static func error(_ status: Int, _ error: String, _ message: String) -> (Int, Data) {
        (status, try! JSONSerialization.data(withJSONObject: ["value": ["error": error, "message": message, "stacktrace": ""]]))
    }

    /// Evaluates `action` with `payload` in the page, mirroring the WebDriver element and script semantics.
    private static let dispatcher = #"""
    const KEY = "element-6066-11e4-a52e-4f735466cecf";
    const registry = (window.__mockElements ??= []);
    class Stale extends Error {}
    const ok = value => JSON.stringify({ status: 200, body: { value } });
    const fail = (status, error, message) => JSON.stringify({ status, body: { value: { error, message, stacktrace: "" } } });
    const ref = element => {
        let index = registry.indexOf(element);
        if (index < 0) { index = registry.length; registry.push(element); }
        return { [KEY]: "e" + index };
    };
    const deref = value => {
        if (Array.isArray(value)) return value.map(deref);
        if (value && typeof value === "object" && KEY in value) {
            const element = registry[Number(value[KEY].slice(1))];
            if (!element || !element.isConnected) throw new Stale();
            return element;
        }
        return value;
    };
    const serialize = value => {
        if (value instanceof Element) return ref(value);
        if (Array.isArray(value)) return value.map(serialize);
        return value === undefined ? null : value;
    };
    const find = (root, using, value) => {
        switch (using) {
        case "css selector":
            return [...root.querySelectorAll(value)];
        case "tag name":
            return [...root.getElementsByTagName(value)];
        case "xpath": {
            const result = document.evaluate(value, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
            return Array.from({ length: result.snapshotLength }, (_, i) => result.snapshotItem(i));
        }
        case "link text":
            return [...root.querySelectorAll("a")].filter(a => a.textContent.trim() === value);
        case "partial link text":
            return [...root.querySelectorAll("a")].filter(a => a.textContent.includes(value));
        }
        throw new Error("Unsupported locator: " + using);
    };
    try {
        switch (action) {
        case "find":
        case "findAll": {
            const root = payload.root ? deref({ [KEY]: payload.root }) : document;
            const found = find(root, payload.using, payload.value);
            if (action === "findAll") return ok(found.map(ref));
            if (found.length === 0) return fail(404, "no such element", "Unable to locate element: " + payload.value);
            return ok(ref(found[0]));
        }
        case "execute":
            return ok(serialize(new Function(payload.script).apply(null, deref(payload.args))));
        }
        return fail(404, "unknown command", "Unknown action: " + action);
    } catch (error) {
        if (error instanceof Stale) return fail(404, "stale element reference", "The element is no longer attached to the DOM");
        return fail(500, "javascript error", String(error));
    }
    """#

}


@MainActor
private final class NavigationWaiter: NSObject, WKNavigationDelegate {

    var continuation: CheckedContinuation<Void, any Error>?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.continuation?.resume()
        self.continuation = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        self.continuation?.resume(throwing: error)
        self.continuation = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        self.continuation?.resume(throwing: error)
        self.continuation = nil
    }

}


/// Routes requests to the ``MockBrowser`` named by the request's host.
final class MockWebDriverProtocol: URLProtocol, @unchecked Sendable {

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let request = self.request
        let body = Self.body(of: request)

        Task { @MainActor in
            let path = request.url?.pathComponents.filter { $0 != "/" } ?? []
            let (status, data) = if let browser = MockBrowser.browser(for: request.url?.host()) {
                await browser.respond(method: request.httpMethod ?? "GET", path: path, body: body)
            } else {
                (404, Data(#"{"value":{"error":"invalid session id","message":"No such mock browser","stacktrace":""}}"#.utf8))
            }

            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {

    }

    /// The JSON body, which `URLSession` may have moved into the body stream.
    private static func body(of request: URLRequest) -> [String : Any] {
        var data = request.httpBody
        if data == nil, let stream = request.httpBodyStream {
            var buffer = Data()
            stream.open()
            defer { stream.close() }
            var chunk = [UInt8](repeating: 0, count: 4096)
            while stream.hasBytesAvailable {
                let count = stream.read(&chunk, maxLength: chunk.count)
                guard count > 0 else { break }
                buffer.append(chunk, count: count)
            }
            data = buffer
        }
        guard let data, !data.isEmpty else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data) as? [String : Any]) ?? [:]
    }

}
