//
//  Summary.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Foundation
import Essentials
import JSONParser


extension Session.Window.Element {

    /// The script that produces ``summary``, given the element as `arguments[0]`.
    private static let summaryScript = #"""
    const element = arguments[0];
    const limit = 80;
    const shorten = s => s.length > limit ? s.slice(0, limit) + "…" : s;
    const shell = element.cloneNode(false);
    for (const attribute of shell.attributes) {
        attribute.value = shorten(attribute.value);
    }
    const text = (element.textContent || "").replace(/\s+/g, " ").trim();
    if (text.length > 0) shell.textContent = shorten(text);
    return shell.outerHTML;
    """#

    /// A short HTML summary of the element, for identifying it in logs and error reports.
    ///
    /// The summary is the element's own tag with its attributes, enclosing an excerpt of its text content. Long attribute values and text are shortened, and child elements are omitted. For example:
    ///
    /// ```html
    /// <button id="submit" class="btn primary">Sign In</button>
    /// ```
    ///
    /// > First Responder:
    /// > The first responder is switched to the window in which `self` locates.
    ///
    /// - SeeAlso: For the full content, use ``load(_:at:)-43sms`` with ``LoadableAttribute/outerHTML`` at ``LoadSource/script``.
    public var summary: String {
        get async throws {
            try await self.window.execute(Self.summaryScript, args: [self.reference]).decode(String.self, forKey: "value")
        }
    }

    /// The ``summary``, or `nil` if it could not be read.
    ///
    /// Unlike ``summary``, this does not switch the first responder, and never creates a ``WebDriverError``, so it is safe to call while constructing one.
    internal var summaryIfAvailable: String? {
        get async {
            let session = self.window.session
            guard let body = try? JSONSerialization.data(withJSONObject: ["script": Self.summaryScript, "args": [self.reference]]) else { return nil }
            let request = session.makeRequest(.post, "session/\(session.id)/execute/sync", data: body)
            guard let (data, response) = try? await session.session.data(for: request),
                  (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            return try? JSONParser(data: data).decode(String.self, forKey: "value")
        }
    }

    /// The JSON reference to `self`, as passed in script arguments.
    private var reference: [String : String] {
        ["element-6066-11e4-a52e-4f735466cecf" : self.id]
    }

}
