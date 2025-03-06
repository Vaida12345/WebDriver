//
//  Disjunction.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//

@testable
import WebDriver
import Testing


extension Tag {
    @Tag static var disjunction: Tag
}


@Suite(.tags(.disjunction, .locator))
struct DisjunctionLocator {
    
    @Test func attributes() async throws {
        let query = query {
            $0.title == "Google" || $0.alt == "Google"
        }
        
        #expect(query == Query(locator: .css, value: "[title=\"Google\"], [alt=\"Google\"]"))
    }
    
    @Test func attributesORTagname() async throws {
        let query = query {
            $0.title == "Google" || $0.tag == "p"
        }
        
        #expect(query == Query(locator: .xpath, value: "//*[@title=\"Google\"] | //p"))
    }
    
    @Test func xPathANDAttribute() async throws {
        let query = query {
            $0.title == "Google" || $0.text == "Google"
        }
        
        #expect(query == Query(locator: .xpath, value: "//*[(@title=\"Google\" or text()=\"Google\")]"))
    }
    
    @Test func xPathORTagname() async throws {
        let query = query {
            $0.tag == "p" || $0.text == "Google"
        }
        
        #expect(query == Query(locator: .xpath, value: "//p | //*[text()=\"Google\"]"))
    }
    
    @Test func xPathORTagnameORAttribute() async throws {
        let query = query {
            $0.tag == "p" || $0.text == "Google" || $0.class == "lst"
        }
        
        #expect(query == Query(locator: .xpath, value: "//p | //*[text()=\"Google\"] | //*[@class=\"lst\"]"))
    }
    
    @Test func mixture() async throws {
        let query = query {
            ($0.tag == "p" && $0.text == "Google" && $0.class == "lst") || ($0.tag == "a" && $0.text == "Wikipedia") || (($0.tag == "div" || $0.tag == "a") && $0.name == "search") || (($0.tag == "div" && $0.name == "search") || $0.placeholder == "Search")
        }
        
        #expect(query == Query(locator: .xpath, value: "//p[text()=\"Google\" and @class=\"lst\"] | //a[text()=\"Wikipedia\"] | //div[@name=\"search\"] | //a[@name=\"search\"] | //div[@name=\"search\"] | //*[@placeholder=\"Search\"]"))
    }
    
}
