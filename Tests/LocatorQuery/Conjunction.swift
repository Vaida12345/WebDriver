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

    @Test func normalizedTextContentANDTagname() async throws {
        let query = query {
            $0.normalizedTextContent == "foo" && $0.tag == "bar"
        }

        #expect(query == Query(locator: .xpath, value: "//bar[normalize-space(.)=\"foo\"]"))
    }

    @Test func classesContainsANDTag() async throws {
        let query = query {
            $0.tag == "button" && $0.classes.contains("btn") && $0.classes.contains("large")
        }

        #expect(query == Query(locator: .css, value: "button[class~=\"btn\"][class~=\"large\"]"))
    }

    /// Each arm of the tag disjunction stays a flat `//tag[…]`, rather than nesting an absolute path in a predicate.
    @Test func tagDisjunctionANDChained() async throws {
        let query = query {
            ($0.tag == "a" || $0.tag == "button") && $0.class == "x" && $0.text == "OK"
        }

        #expect(query == Query(locator: .xpath, value: "//a[@class=\"x\" and text()=\"OK\"] | //button[@class=\"x\" and text()=\"OK\"]"))
    }

    @Test func attributeANDTagDisjunction() async throws {
        let query = query {
            $0.class == "x" && ($0.tag == "a" || $0.tag == "button")
        }

        #expect(query == Query(locator: .css, value: "a[class=\"x\"], button[class=\"x\"]"))
    }

    /// `hrefText` adds its own `a` tag, which is the same tag.
    @Test func sameTagANDLinkText() async throws {
        let query = query {
            $0.tag == "a" && $0.hrefText == "Docs"
        }

        #expect(query == Query(locator: .xpath, value: "//a[normalize-space(.)=\"Docs\"]"))
    }

    /// A CSS selector list cannot be nested, so this falls back to XPath.
    @Test func tagANDAttributeDisjunction() async throws {
        let query = query {
            $0.tag == "div" && ($0.id == "a" || $0.id == "b")
        }

        #expect(query == Query(locator: .xpath, value: "//div[(@id=\"a\" or @id=\"b\")]"))
    }

}
