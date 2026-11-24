//
//  Diagnostic Snapshot.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//

import Essentials
import Foundation


extension Session.Window {

    /// A trimmed serialization of the DOM, intended for error reports.
    ///
    /// Every element and its attributes are kept, but the contents of `script`, `style`, `noscript`, `svg`, and `template` are replaced with a size marker, comments are removed, and long attribute values are shortened. The live page is never modified.
    ///
    /// Use ``pageSource`` for a faithful serialization.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public var diagnosticSnapshot: String {
        get async throws {
            let script = #"""
            const size = n => "…(" + (n / 1024).toFixed(1) + " KB)";
            const root = document.documentElement.cloneNode(true);
            for (const el of root.querySelectorAll("script, style, noscript, svg, template")) {
                const length = el.innerHTML.length;
                if (length === 0) continue;
                const marker = document.createTextNode(size(length));
                if (el.tagName === "TEMPLATE") {
                    el.content.replaceChildren(marker);
                } else {
                    el.replaceChildren(marker);
                }
            }
            const walker = document.createTreeWalker(root, NodeFilter.SHOW_COMMENT);
            const comments = [];
            while (walker.nextNode()) comments.push(walker.currentNode);
            for (const comment of comments) comment.remove();
            for (const el of root.querySelectorAll("*")) {
                for (const attribute of el.attributes) {
                    if (attribute.value.length > 200) {
                        attribute.value = attribute.value.slice(0, 80) + size(attribute.value.length);
                    }
                }
            }
            return root.outerHTML;
            """#

            let snapshot = try await self.execute(script, args: []).decode(String.self, forKey: "value")

            let limit = 200_000
            guard snapshot.count > limit else { return snapshot }
            let total = String(format: "%.1f", Double(snapshot.utf8.count) / 1024)
            return String(snapshot.prefix(limit)) + "…(truncated, \(total) KB total)"
        }
    }

    /// The ``diagnosticSnapshot``, falling back to ``pageSource``, or `nil` if neither is available.
    ///
    /// Never throws, so it cannot mask the error it is attached to.
    var timeoutDetails: String? {
        get async {
            if let snapshot = try? await self.diagnosticSnapshot {
                return snapshot
            }
            return try? await self.pageSource
        }
    }

}
