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
    /// The content of open shadow roots, nested or not, is included inside each host as `<template shadowrootmode="open">`, trimmed the same way. Closed shadow roots, which scripts cannot reach, and the documents of frames are not included.
    ///
    /// The snapshot is indented, two spaces per level, with each element on its own line:
    ///
    /// ```html
    /// <html>
    ///   <head></head>
    ///   <body>
    ///     <p id="greeting">Hello</p>
    ///     <input id="name" type="text" required>
    ///   </body>
    /// </html>
    /// ```
    ///
    /// Whitespace in text is collapsed, except in `pre` and `textarea`. An element whose only content is a short text stays on one line. Because text and elements are put on separate lines, inline content such as `Some <b>bold</b> text` is split across lines.
    ///
    /// Use ``pageSource`` for a faithful serialization.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public var diagnosticSnapshot: String {
        get async throws {
            let script = #"""
            const size = n => "…(" + (n / 1024).toFixed(1) + " KB)";
            const trimmed = "script, style, noscript, svg, template";
            // Trims a detached copy in place, including `root` itself.
            const trim = root => {
                for (const el of [root, ...root.querySelectorAll(trimmed)]) {
                    if (!el.matches(trimmed)) continue;
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
                for (const el of [root, ...root.querySelectorAll("*")]) {
                    for (const attribute of el.attributes) {
                        if (attribute.value.length > 200) {
                            attribute.value = attribute.value.slice(0, 80) + size(attribute.value.length);
                        }
                    }
                }
            };
            // Returns a trimmed copy of `source`, with the content of each open shadow root inserted into its host as a template.
            const copy = source => {
                const clone = source.cloneNode(true);
                // The clone has the same structure, so the two lists line up.
                const originals = [source, ...source.querySelectorAll("*")];
                const copies = [clone, ...clone.querySelectorAll("*")];
                trim(clone);
                // Inserted after trimming, so that the shadow templates are not emptied like the page's own templates.
                originals.forEach((original, index) => {
                    const shadow = original.shadowRoot;
                    if (!shadow) return;
                    const template = document.createElement("template");
                    template.setAttribute("shadowrootmode", shadow.mode);
                    for (const child of shadow.childNodes) {
                        if (child.nodeType === Node.ELEMENT_NODE) {
                            template.content.append(copy(child));
                        } else if (child.nodeType === Node.TEXT_NODE) {
                            template.content.append(child.cloneNode());
                        }
                    }
                    copies[index].prepend(template);
                });
                return clone;
            };
            // Serializes `root` indented, with each element and text on its own line.
            const voids = new Set(["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "source", "track", "wbr"]);
            const preserved = new Set(["pre", "textarea"]);
            const escapeText = text => text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\u00A0/g, "&nbsp;");
            const escapeAttribute = value => value.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/\u00A0/g, "&nbsp;");
            const collapse = text => text.replace(/\s+/g, " ").trim();
            const startTag = element => "<" + element.localName + [...element.attributes].map(attribute =>
                " " + attribute.name + (attribute.value === "" ? "" : "=\"" + escapeAttribute(attribute.value) + "\"")
            ).join("") + ">";
            const format = root => {
                const lines = [];
                const write = (node, depth) => {
                    const indent = "  ".repeat(depth);
                    if (node.nodeType === Node.TEXT_NODE) {
                        const text = collapse(node.data);
                        if (text) lines.push(indent + escapeText(text));
                        return;
                    }
                    if (node.nodeType !== Node.ELEMENT_NODE) return;
                    const open = startTag(node);
                    if (voids.has(node.localName)) {
                        lines.push(indent + open);
                        return;
                    }
                    const close = "</" + node.localName + ">";
                    if (preserved.has(node.localName)) {
                        lines.push(indent + open + escapeText(node.textContent) + close);
                        return;
                    }
                    // A template's children are in its content.
                    const children = [...(node.localName === "template" ? node.content : node).childNodes]
                        .filter(child => child.nodeType === Node.ELEMENT_NODE || (child.nodeType === Node.TEXT_NODE && collapse(child.data)));
                    if (children.length === 0) {
                        lines.push(indent + open + close);
                    } else if (children.length === 1 && children[0].nodeType === Node.TEXT_NODE && collapse(children[0].data).length <= 80) {
                        lines.push(indent + open + escapeText(collapse(children[0].data)) + close);
                    } else {
                        lines.push(indent + open);
                        for (const child of children) write(child, depth + 1);
                        lines.push(indent + close);
                    }
                };
                write(root, 0);
                return lines.join("\n");
            };
            return format(copy(document.documentElement));
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
