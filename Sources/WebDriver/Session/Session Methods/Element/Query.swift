//
//  Query.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    /// The query formed by locator, used for transmitting the query to backend.
    public indirect enum _Query {
        case css_selector(String)
        case link_text(String)
        case partial_link_text(String)
        case tag_name(String)
        case xpath(String)
    }
    
}
