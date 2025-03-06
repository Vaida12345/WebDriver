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
            .id
        }
        
        /// The tagname of the element.
        ///
        /// For example, the tag name of `<p>` is `p`. One element has only one tag name, it will raise an `preconditionFailure` when an element is required to have two tag names.
        public var tag: TagLocator {
            TagLocator()
        }
        
        /// The class of the element.
        public var `class`: AttributeLocator {
            .class
        }
        
        /// Inline CSS.
        public var style: AttributeLocator {
            .style
        }
        
        /// Tooltip text.
        public var title: AttributeLocator {
            .title
        }
        
        /// Hides the element.
        public var hidden: AttributeLocator {
            .hidden
        }
        
        /// Defines tab order.
        public var tabindex: AttributeLocator {
            .tabindex
        }
        
        /// Defines input type (text, email, password, etc..
        public var type: AttributeLocator {
            .type
        }
        
        /// Default value of input.
        public var value: AttributeLocator {
            .value
        }
        
        /// Hint text inside input.
        public var placeholder: AttributeLocator {
            .placeholder
        }
        
        /// Name of input field.
        public var name: AttributeLocator {
            .name
        }
        
        /// Regex validation.
        public var pattern: AttributeLocator {
            .pattern
        }
        
        /// URL of the link.
        public var href: AttributeLocator {
            .href
        }

        /// Image/audio/video source URL.
        public var src: AttributeLocator {
            .src
        }
        
        /// Alternative text for images.
        public var alt: AttributeLocator {
            .alt
        }
        
        /// Text content of an `<a>` element.
        public var hrefText: LinkTextLocator {
            LinkTextLocator()
        }
        
        /// The text content.
        public var text: XPathLocator {
            .init(attribute: .function("text"))
        }

        
    }
    
}
