//
//  Query.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// The query formed by locator, used for transmitting the query to backend.
    public struct Query: Equatable, Sendable {
        
        let locator: Locator
        
        let value: String
        
        enum Locator: String, CustomStringConvertible, Equatable, Sendable {
            case css = "css selector"
            case linkText = "link text"
            case partialLinkText = "partial link text"
            case tagName = "tag name"
            case xpath = "xpath"
            
            var description: String {
                ".\(self.rawValue)"
            }
        }
        
        
        init(locator: Locator, value: String) {
            self.locator = locator
            self.value = value
        }

        /// The query, restricted to the descendants of the element it is evaluated on.
        ///
        /// In XPath, a path starting with `//` searches the whole document, even when evaluated on an element. This prefixes each top-level `//` path, including each branch of a `|` union, with `.`, so that it searches from the element instead. Paths nested within predicates or string literals are left as is, as they are meant to be absolute, such as `//label[…]/@for`.
        ///
        /// Other locator strategies are already relative to the element, and are returned as is.
        func relativeToContextNode() -> Query {
            guard locator == .xpath else { return self }

            var result = ""
            var depth = 0
            var quote: Character? = nil
            /// Whether a path can start here: at the beginning, or right after a top-level `|`.
            var expectsPath = true
            var index = value.startIndex

            while index < value.endIndex {
                let character = value[index]
                let next = value.index(after: index)

                if let open = quote {
                    if character == open { quote = nil }
                } else {
                    switch character {
                    case "\"", "'":
                        quote = character
                    case "[", "(":
                        depth += 1
                    case "]", ")":
                        depth -= 1
                    case "|" where depth == 0:
                        expectsPath = true
                        result.append(character)
                        index = next
                        continue
                    case "/" where depth == 0 && expectsPath && next < value.endIndex && value[next] == "/":
                        result.append(".")
                    default:
                        break
                    }
                }

                if !character.isWhitespace { expectsPath = false }
                result.append(character)
                index = next
            }

            return Query(locator: locator, value: result)
        }
    }
    
}
