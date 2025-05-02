//
//  HTMLTag.swift
//  WebDriver
//
//  Created by Vaida on 5/2/25.
//


extension Session.Window.Element {
    
    /// A struct representing an HTML tag, which can be initialized from a string or used as a string literal.
    public struct HTMLTag: Sendable, ExpressibleByStringLiteral {
        
        /// The raw string value of the HTML tag.
        let rawValue: String
        
        /// Initializes a new `HTMLTag` with the given raw string value.
        /// - Parameter rawValue: The string value of the HTML tag.
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Initializes a new `HTMLTag` using a string literal.
        /// - Parameter value: The string literal to initialize the `HTMLTag`.
        public init(stringLiteral value: StringLiteralType) {
            self.init(value)
        }
        
        // MARK: - Static Constants for HTML Tags
        
        /// Represents the `<html>` tag, the root element of an HTML document.
        public static let html = HTMLTag("html")
        
        /// Represents the `<head>` tag, containing metadata and links to external resources.
        public static let head = HTMLTag("head")
        
        /// Represents the `<body>` tag, containing the content of the HTML document.
        public static let body = HTMLTag("body")
        
        /// Represents the `<title>` tag, which sets the title of the document shown in the browser tab.
        public static let title = HTMLTag("title")
        
        /// Represents the `<meta>` tag, used for specifying metadata like character set or author.
        public static let meta = HTMLTag("meta")
        
        /// Represents the `<link>` tag, used to link external resources such as stylesheets.
        public static let link = HTMLTag("link")
        
        /// Represents the `<style>` tag, used to define internal CSS styles.
        public static let style = HTMLTag("style")
        
        /// Represents the `<script>` tag, used to define client-side JavaScript.
        public static let script = HTMLTag("script")
        
        /// Represents the `<p>` tag, used to define a paragraph of text.
        public static let p = HTMLTag("p")
        
        /// Represents the `<h1>` tag, used for the highest level heading.
        public static let h1 = HTMLTag("h1")
        
        /// Represents the `<h2>` tag, used for the second level heading.
        public static let h2 = HTMLTag("h2")
        
        /// Represents the `<h3>` tag, used for the third level heading.
        public static let h3 = HTMLTag("h3")
        
        /// Represents the `<h4>` tag, used for the fourth level heading.
        public static let h4 = HTMLTag("h4")
        
        /// Represents the `<h5>` tag, used for the fifth level heading.
        public static let h5 = HTMLTag("h5")
        
        /// Represents the `<h6>` tag, used for the sixth level heading.
        public static let h6 = HTMLTag("h6")
        
        /// Represents the `<a>` tag, used to define hyperlinks.
        public static let a = HTMLTag("a")
        
        /// Represents the `<img>` tag, used to embed images.
        public static let img = HTMLTag("img")
        
        /// Represents the `<div>` tag, used to define a generic container for HTML elements.
        public static let div = HTMLTag("div")
        
        /// Represents the `<span>` tag, used to define a section of inline text.
        public static let span = HTMLTag("span")
        
        /// Represents the `<ul>` tag, used to define an unordered list.
        public static let ul = HTMLTag("ul")
        
        /// Represents the `<ol>` tag, used to define an ordered list.
        public static let ol = HTMLTag("ol")
        
        /// Represents the `<li>` tag, used to define a list item.
        public static let li = HTMLTag("li")
        
        /// Represents the `<table>` tag, used to define a table.
        public static let table = HTMLTag("table")
        
        /// Represents the `<tr>` tag, used to define a row in a table.
        public static let tr = HTMLTag("tr")
        
        /// Represents the `<th>` tag, used to define a header cell in a table.
        public static let th = HTMLTag("th")
        
        /// Represents the `<td>` tag, used to define a data cell in a table.
        public static let td = HTMLTag("td")
        
        /// Represents the `<form>` tag, used to define an HTML form.
        public static let form = HTMLTag("form")
        
        /// Represents the `<input>` tag, used to define an input field in a form.
        public static let input = HTMLTag("input")
        
        /// Represents the `<button>` tag, used to define a clickable button.
        public static let button = HTMLTag("button")
        
        /// Represents the `<select>` tag, used to define a dropdown list.
        public static let select = HTMLTag("select")
        
        /// Represents the `<option>` tag, used to define an option in a dropdown list.
        public static let option = HTMLTag("option")
        
        /// Represents the `<label>` tag, used to define a label for an input element.
        public static let label = HTMLTag("label")
        
        /// Represents the `<br>` tag, used to insert a line break.
        public static let br = HTMLTag("br")
        
        /// Represents the `<hr>` tag, used to insert a horizontal rule.
        public static let hr = HTMLTag("hr")
        
        /// Represents the `<iframe>` tag, used to define an inline frame for embedding another document.
        public static let iframe = HTMLTag("iframe")
        
        /// Represents the `<footer>` tag, used to define a footer for a document or section.
        public static let footer = HTMLTag("footer")
        
        /// Represents the `<header>` tag, used to define a header for a document or section.
        public static let header = HTMLTag("header")
        
        /// Represents the `<article>` tag, used to define an article within a document.
        public static let article = HTMLTag("article")
        
        /// Represents the `<section>` tag, used to define a section in a document.
        public static let section = HTMLTag("section")
        
        /// Represents the `<nav>` tag, used to define navigation links.
        public static let nav = HTMLTag("nav")
        
        /// Represents the `<aside>` tag, used to define content aside from the main content (like a sidebar).
        public static let aside = HTMLTag("aside")
        
        /// Represents the `<main>` tag, used to define the main content of a document.
        public static let main = HTMLTag("main")
        
        /// Represents the `<figure>` tag, used to define content like images or illustrations with an optional caption.
        public static let figure = HTMLTag("figure")
        
        /// Represents the `<figcaption>` tag, used to define a caption for a `<figure>` element.
        public static let figcaption = HTMLTag("figcaption")
        
        /// Represents the `<details>` tag, used to define additional information that the user can view or hide.
        public static let details = HTMLTag("details")
        
        /// Represents the `<summary>` tag, used to define a heading for the `<details>` element.
        public static let summary = HTMLTag("summary")
        
        /// Represents the `<address>` tag, used to define contact information.
        public static let address = HTMLTag("address")
    }

    
}
