//
//  LocatorProxy.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    public struct LocatorProxy: Sendable {
        
        /// The id of the element.
        ///
        /// This is the fastest way of locating an element.
        public var id: AttributeLocator {
            AttributeLocator(name: "id")
        }
        
        /// The tagname of the element.
        ///
        /// For example, the tag name of `<p>` is `p`. One element has only one tag name, it will raise an `preconditionFailure` when an element is required to have two tag names.
        public var tag: TagLocator {
            TagLocator()
        }
        
        /// The class of the element.
        public var `class`: AttributeLocator {
            AttributeLocator(name: "class")
        }
        
        /// Inline CSS.
        public var style: AttributeLocator {
            AttributeLocator(name: "style")
        }
        
        /// Tooltip text.
        public var title: AttributeLocator {
            AttributeLocator(name: "title")
        }
        
        /// Hides the element.
        public var hidden: AttributeLocator {
            AttributeLocator(name: "hidden")
        }
        
        /// Defines tab order.
        public var tabindex: AttributeLocator {
            AttributeLocator(name: "tabindex")
        }
        
        /// Defines input type (text, email, password, etc..
        public var type: AttributeLocator {
            AttributeLocator(name: "type")
        }
        
        /// Default value of input.
        public var value: AttributeLocator {
            AttributeLocator(name: "value")
        }
        
        /// Hint text inside input.
        public var placeholder: AttributeLocator {
            AttributeLocator(name: "placeholder")
        }
        
        /// Name of input field.
        public var name: AttributeLocator {
            AttributeLocator(name: "name")
        }
        
        /// Regex validation.
        public var pattern: AttributeLocator {
            AttributeLocator(name: "pattern")
        }
        
        /// URL of the link.
        public var href: AttributeLocator {
            AttributeLocator(name: "href")
        }

        /// Image/audio/video source URL.
        public var src: AttributeLocator {
            AttributeLocator(name: "src")
        }
        
        /// Alternative text for images.
        public var alt: AttributeLocator {
            AttributeLocator(name: "alt")
        }
        
        /// Text content of an `<a>` element.
        public var hrefText: LinkTextLocator {
            LinkTextLocator()
        }
        
        /// The text content.
        ///
        /// This does not check its decedents.
        ///
        /// - SeeAlso: `textContent`
        public var text: XPathLocator {
            .init(attribute: .function("text"))
        }

        /// The whitespace-normalized text content of the element, including all descendants.
        ///
        /// Corresponds to XPath `normalize-space(.)`: leading and trailing whitespace is stripped, and inner runs of whitespace collapse into a single space. Unlike ``text``, which matches only the element's own text nodes, this matches the concatenated text of the element's entire subtree.
        public var normalizedTextContent: XPathLocator {
            .init(attribute: .expression("normalize-space(.)"))
        }

        /// The text content of the element, including all descendants.
        ///
        /// Corresponds to XPath `string(.)`, and to the DOM `textContent` property: the concatenated text of the element's entire subtree, with whitespace preserved as is.
        ///
        /// - SeeAlso: ``normalizedTextContent``, which also collapses whitespace.
        public var textContent: XPathLocator {
            .init(attribute: .expression("string(.)"))
        }

        /// The class list of the element, for matching whole class names.
        ///
        /// `$0.classes.contains("btn")` matches `class="btn primary"` but not `class="btn-primary"`, whereas `$0.class.contains("btn")` is a substring search that matches both.
        public var classes: ClassListLocator {
            ClassListLocator()
        }

        /// The accessible name of the element, from its `aria-label` attribute.
        public var ariaLabel: AttributeLocator {
            AttributeLocator(name: "aria-label")
        }

        /// The ARIA role of the element, such as `button` or `dialog`.
        ///
        /// This only matches an explicit `role` attribute, not the implicit role of an element such as `<button>`.
        public var role: AttributeLocator {
            AttributeLocator(name: "role")
        }

        /// An attribute of the element with the given name, such as `data-testid`.
        ///
        /// - Parameter name: The attribute name. It is used as is, without escaping, so it must be a valid attribute name.
        public func attribute(_ name: String) -> AttributeLocator {
            AttributeLocator(name: name)
        }

        
    }
    
}
