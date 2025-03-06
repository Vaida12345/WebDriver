//
//  Essentials.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

@testable
import WebDriver
import Testing


typealias Query = Element.Query


@Suite
struct LocatorEssentials {
    
    func query(_ predicate: (Element.LocatorProxy) -> any LocatorQuery) -> Element.Query {
        let proxy = Element.LocatorProxy()
        return predicate(proxy).makeQuery()
    }
    
    @Test func id() async throws {
        let query = query {
            $0.id == "2"
        }
        
        #expect(query == Query(locator: .css, value: "[id=\"2\"]"))
    }
    
    @Test func tagname() async throws {
        let query = query {
            $0.tag == "p"
        }
        
        #expect(query == Query(locator: .tagName, value: "p"))
    }
    
    @Test func title() async throws {
        let query = query {
            $0.title == "abc"
        }
        
        #expect(query == Query(locator: .css, value: "[title=\"abc\"]"))
    }
    
}

