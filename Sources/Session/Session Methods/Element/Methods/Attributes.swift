//
//  Attributes.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import CoreGraphics


extension Element {
    
    /// Returns the text as rendered.
    public var text: String {
        get async throws {
            try await self.parser(.get, "text")!["value"]
        }
    }
    
    /// Returns the tag name.
    public var tag: String {
        get async throws {
            try await self.parser(.get, "name")!["value"]
        }
    }
    
    /// The element rect.
    ///
    /// ## Coordinate System
    ///
    /// The coordinate systems for WebDriver window rect and `CGRect` are essentially the same in terms of their basic structure and how they define the window's position and size.
    ///
    /// - Origin (0, 0): Both use the top-left corner of the screen as the origin.
    ///     - WebDriver: The top-left corner of the screen is (0, 0) in its coordinate system.
    ///     - `CGRect`: Similarly, the top-left corner of the screen or window is also (0, 0) in its coordinate system.
    /// - Position and Size:
    ///     - Both systems define a bounding box for the window using:
    ///         - `x`: The horizontal distance from the left edge of the screen or parent container.
    ///         - `y`: The vertical distance from the top edge of the screen or parent container.
    ///         - `width`: The width of the window or view.
    ///         - `height`: The height of the window or view.
    /// - Coordinate Meaning:
    ///     - Both systems represent a window's position relative to the screen or parent container, starting from the top-left corner.
    public var frame: CGRect {
        get async throws {
            let parser = try await self.parser(.get, "rect")!
            
            return try CGRect(x: parser["x", .numeric],
                              y: parser["y", .numeric],
                              width: parser["width", .numeric],
                              height: parser["height", .numeric])
        }
    }
    
    /// Represents the computed label of an element in the W3C WebDriver standard.
    ///
    /// The **computed label** is the accessible name assigned to an element, primarily used by assistive technologies
    /// like screen readers. It is derived from various sources, including:
    ///
    /// - `aria-label` attribute
    /// - `aria-labelledby` attribute
    /// - `<label>` element (for form controls)
    /// - `alt` attribute (for images)
    /// - Visible text content of the element
    ///
    /// ## Examples
    ///
    /// ### Example 1: Using `aria-label`
    /// ```html
    /// <button aria-label="Submit Form">Submit</button>
    /// ```
    /// Computed Label: `"Submit Form"`
    ///
    /// ### Example 2: Using `<label>` for Input
    /// ```html
    /// <label for="username">Username</label>
    /// <input id="username" type="text">
    /// ```
    /// Computed Label for Input: `"Username"`
    ///
    /// ### Example 3: Using Element Text Content
    /// ```html
    /// <button>Click Me</button>
    /// ```
    /// Computed Label: `"Click Me"`
    ///
    /// - Note: If an element has no accessible name, the response will return `""`.
    ///
    /// ## See Also
    /// - [W3C WebDriver Specification – Computed Label](https://www.w3.org/TR/webdriver2/#computed-label)
    /// - [Accessible Name and Description Computation](https://www.w3.org/TR/accname/)
    public var label: String {
        get async throws {
            try await self.parser(.get, "computedlabel")!["value"]
        }
    }
    
    
    /// Load the attribute.
    public func load(_ attribute: LoadableAttribute, at source: LoadSource = .latest) async throws -> String {
        switch source {
        case .original:
            try await self.parser(.get, "attribute/\(attribute.rawValue)")!["value"]
        case .script:
            try await self.parser(.get, "property/\(attribute.rawValue)")!["value"]
        case .latest:
            try await self.parser(.get, "css/\(attribute.rawValue)")!["value"]
        }
    }
    
    /// Load the attribute.
    public func load(_ attribute: String, at source: LoadSource = .latest) async throws -> String {
        switch source {
        case .original:
            try await self.parser(.get, "attribute/\(attribute)")!["value"]
        case .script:
            try await self.parser(.get, "property/\(attribute)")!["value"]
        case .latest:
            try await self.parser(.get, "css/\(attribute)")!["value"]
        }
    }
    
    
    public enum LoadSource {
        /// The original attribute in the HTML value.
        case original
        
        /// The value that may have been modified by script.
        case script
        
        /// The latest value obtained by inspecting the CSS value.
        case latest
    }
    
    
    public enum LoadableAttribute: String, CaseIterable {
        /// Specifies a list of accepted file types for file input
        case accept
        
        /// Specifies the character encodings that are to be used for form submission
        case acceptCharset = "accept-charset"
        
        /// Defines a keyboard shortcut for the element
        case accessKey = "accesskey"
        
        /// Specifies the URL for form submission
        case action
        
        /// Provides alternative text for an image
        case alt
        
        /// Specifies if an input field has autocomplete enabled
        case autocomplete
        
        /// Declares the character encoding of an HTML document
        case charset
        
        /// Specifies a reference to a cited source
        case cite
        
        /// Defines one or more class names for an element
        case className = "class"
        
        /// Specifies the number of columns in a textarea
        case cols
        
        /// Defines how many columns a table cell should span
        case colspan
        
        /// Provides metadata information for an element
        case content
        
        /// Specifies coordinates for an area in an image map
        case coords
        
        /// Defines if a resource should be loaded with CORS
        case crossorigin
        
        /// Stores custom data attributes
        case data
        
        /// Specifies the date and time of an element (e.g., `<time>`)
        case datetime
        
        /// Defines how the browser should decode an image
        case decoding
        
        /// Specifies text direction (ltr, rtl, auto)
        case dir
        
        /// Provides a URL for downloading a linked file
        case download
        
        /// Specifies the encoding type for form submission
        case enctype
        
        /// Associates a label with an element
        case forAttribute = "for"
        
        /// Specifies the form an element belongs to
        case form
        
        /// Defines the URL for form submission when using a submit button
        case formaction
        
        /// Specifies associated header cells in a table
        case headers
        
        /// Defines the URL of a hyperlink
        case href
        
        /// Specifies the language of a linked document
        case hreflang
        
        /// Provides an HTTP header equivalent (e.g., `<meta http-equiv="refresh">`)
        case httpEquiv = "http-equiv"
        
        /// Defines a unique identifier for an element
        case id
        
        /// Specifies the expected virtual keyboard type
        case inputmode
        
        /// Specifies a cryptographic hash for an external resource
        case integrity
        
        /// Defines a custom element type
        case isAttribute = "is"
        
        /// Specifies a label for an element
        case label
        
        /// Defines the language of an element
        case lang
        
        /// Associates an input with a datalist
        case list
        
        /// Specifies whether an image should be loaded lazily
        case loading
        
        /// Defines the maximum value for an input field
        case max
        
        /// Specifies the maximum number of characters allowed in an input
        case maxlength
        
        /// Defines the minimum value for an input field
        case min
        
        /// Specifies the minimum number of characters for an input
        case minlength
        
        /// Specifies the name of an element
        case name
        
        /// Defines a regular expression pattern for an input
        case pattern
        
        /// Provides a hint for expected input in a field
        case placeholder
        
        /// Specifies the image to be shown before a video plays
        case poster
        
        /// Defines the relationship between the current document and linked resource
        case rel
        
        /// Specifies the number of visible lines in a textarea
        case rows
        
        /// Defines how many rows a table cell should span
        case rowspan
        
        /// Restricts the capabilities of an iframe
        case sandbox
        
        /// Specifies the scope of a `<th>` element in a table
        case scope
        
        /// Defines the shape of a clickable area in an image map
        case shape
        
        /// Specifies the size of an input field or control
        case size
        
        /// Defines image sizes for different viewport conditions
        case sizes
        
        /// Specifies the name of a slot in a Web Component
        case slot
        
        /// Defines the number of columns a `<col>` element should span
        case span
        
        /// Specifies the URL of an image, script, audio, or video
        case src
        
        /// Embeds HTML as a string within an iframe
        case srcdoc
        
        /// Specifies the language of track text data
        case srclang
        
        /// Defines multiple image sources for responsive loading
        case srcset
        
        /// Specifies the legal number intervals for an input field
        case step
        
        /// Defines inline styles for an element
        case style
        
        /// Specifies the tab order of an element
        case tabindex
        
        /// Defines where a hyperlink should open
        case target
        
        /// Provides additional information about an element as a tooltip
        case title
        
        /// Specifies if content should be translated
        case translate
        
        /// Defines the type of an input, button, or script
        case type
        
        /// Specifies an image map associated with an element
        case usemap
        
        /// Defines the current value of an input field
        case value
        
        /// Specifies the width of an element
        case width
        
        /// Defines how text in a textarea should be wrapped
        case wrap
    }
    
}
