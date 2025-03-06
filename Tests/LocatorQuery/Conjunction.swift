//
//  Conjunction.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

@testable
import WebDriver
import Testing


extension Tag {
    @Tag static var conjunction: Tag
}


@Suite(.tags(.conjunction, .locator))
struct ConjunectionLocator {
    
    @Test func attributes() async throws {
        let query = query {
            $0.title == "Google" && $0.alt == "Google"
        }
        
        #expect(query == Query(locator: .css, value: "[title=\"Google\"][alt=\"Google\"]"))
    }
    
    @Test func attributesANDTagname() async throws {
        let query = query {
            $0.title == "Google" && $0.tag == "p"
        }
        
        #expect(query == Query(locator: .css, value: "p[title=\"Google\"]"))
    }
    
    @Test func xPathANDAttribute() async throws {
        let query = query {
            $0.title == "Google" && $0.text == "Google"
        }
        
        #expect(query == Query(locator: .xpath, value: "//*[(@title=\"Google\" and text()=\"Google\")]"))
    }
    
    @Test func xPathANDTagname() async throws {
        let query = query {
            $0.tag == "p" && $0.text == "Google"
        }
        
        #expect(query == Query(locator: .xpath, value: "//p[text()=\"Google\"]"))
    }
    
    @Test func xPathANDTagnameANDAttribute() async throws {
        let query = query {
            $0.tag == "p" && $0.text == "Google" && $0.class == "lst"
        }
        
        #expect(query == Query(locator: .xpath, value: "//p[text()=\"Google\" and @class=\"lst\"]"))
    }
    
}
