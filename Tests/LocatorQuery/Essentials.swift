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


extension Tag {
    @Tag static var essentials: Tag
    @Tag static var locator: Tag
}

func query(_ predicate: (Element.LocatorProxy) -> any LocatorQuery) -> Element.Query {
    let proxy = Element.LocatorProxy()
    return predicate(proxy).makeQuery()
}

func query(_ predicate: (Element.LocatorProxy) -> Query) -> Element.Query {
    let proxy = Element.LocatorProxy()
    return predicate(proxy)
}



@Suite(.tags(.essentials, .locator))
struct LocatorEssentials {
    
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
    
    @Test func partialLinkText() async throws {
        let query = query {
            $0.hrefText.contains("abc")
        }
        
        #expect(query == Query(locator: .partialLinkText, value: "abc"))
    }
    
    @Test func text() async throws {
        let query = query {
            $0.text == "abc"
        }
        
        #expect(query == Query(locator: .xpath, value: "//*[text()=\"abc\"]"))
    }
    
    
    @Test func titleContains() async throws {
        let query = query {
            $0.title.contains("abc")
        }
        
        #expect(query == Query(locator: .css, value: "[title*=\"abc\"]"))
    }
    
    @Test func titleNotEqual() async throws {
        let query = query {
            $0.title != "abc"
        }
        
        #expect(query == Query(locator: .xpath, value: "//*[@title != \"abc\"]"))
    }

    
}

