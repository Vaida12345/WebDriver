//
//  LocatorProxy.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    public struct LocatorProxy {
        
        /// The id of the element.
        ///
        /// This is the fastest way of locating an element.
        public var id: Session.Window.Element.AttributeLocator {
            .id
        }
        
        /// The tagname of the element.
        public var tag: Session.Window.Element.TagLocator {
            .tag
        }
        
        /// The class of the element.
        public var `class`: Session.Window.Element.AttributeLocator {
            .class
        }
        
        /// Inline CSS.
        public var style: Session.Window.Element.AttributeLocator {
            .style
        }
        
        /// Tooltip text.
        public var title: Session.Window.Element.AttributeLocator {
            .title
        }
        
        /// Hides the element.
        public var hidden: Session.Window.Element.AttributeLocator {
            .hidden
        }
        
        /// Defines tab order.
        public var tabindex: Session.Window.Element.AttributeLocator {
            .tabindex
        }
        
        /// Defines input type (text, email, password, etc..
        public var type: Session.Window.Element.AttributeLocator {
            .type
        }
        
        /// Default value of input.
        public var value: Session.Window.Element.AttributeLocator {
            .value
        }
        
        /// Hint text inside input.
        public var placeholder: Session.Window.Element.AttributeLocator {
            .placeholder
        }
        
        /// Name of input field.
        public var name: Session.Window.Element.AttributeLocator {
            .name
        }
        
        /// Regex validation.
        public var pattern: Session.Window.Element.AttributeLocator {
            .pattern
        }
        
        /// URL of the link.
        public var href: Session.Window.Element.AttributeLocator {
            .href
        }

        /// Image/audio/video source URL.
        public var src: Session.Window.Element.AttributeLocator {
            .src
        }
        
        /// Alternative text for images.
        public var alt: Session.Window.Element.AttributeLocator {
            .alt
        }

        
    }
    
}
