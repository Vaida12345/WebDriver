//
//  Matching.swift
//  WebDriver
//
//  Created by Claude on 11/24/26.
//
//  Tests for attribute presence, combinable link text, labels, tag negation, relative queries, case-insensitive matching, and empty text.
//

@testable
import WebDriver
import Testing


extension Tag {
    @Tag static var matching: Tag
}


@Suite(.tags(.matching, .locator))
struct MatchingLocator {

    // MARK: - Attribute presence

    @Test func exists() async throws {
        let query = query {
            $0.disabled.exists
        }

        #expect(query == Query(locator: .css, value: "[disabled]"))
    }

    @Test func existsANDTag() async throws {
        let query = query {
            $0.tag == "input" && $0.required.exists
        }

        #expect(query == Query(locator: .css, value: "input[required]"))
    }

    @Test func existsInXPath() async throws {
        let query = query {
            $0.attribute("readonly").exists && $0.text == "x"
        }

        #expect(query == Query(locator: .xpath, value: "//*[(@readonly and text()=\"x\")]"))
    }

    // MARK: - Link text

    @Test func linkTextAlone() async throws {
        let query = query {
            $0.hrefText == "Docs"
        }

        #expect(query == Query(locator: .linkText, value: "Docs"))
    }

    @Test func linkTextANDAttribute() async throws {
        let query = query {
            $0.hrefText == "Docs" && $0.class == "nav"
        }

        #expect(query == Query(locator: .xpath, value: "//a[normalize-space(.)=\"Docs\" and @class=\"nav\"]"))
    }

    @Test func partialLinkTextORAttribute() async throws {
        let query = query {
            $0.hrefText.contains("Doc") || $0.title == "Docs"
        }

        #expect(query == Query(locator: .xpath, value: "//a[contains(normalize-space(.), \"Doc\")] | //*[@title=\"Docs\"]"))
    }

    // MARK: - Label

    @Test func label() async throws {
        let query = query {
            $0.label == "Email"
        }

        #expect(query == Query(locator: .xpath, value: "//*[(@id = //label[normalize-space(.)=\"Email\"]/@for or (ancestor::label[normalize-space(.)=\"Email\"] and (self::button or self::input or self::meter or self::output or self::progress or self::select or self::textarea)))]"))
    }

    @Test func labelANDTag() async throws {
        let query = query {
            $0.tag == "input" && $0.label.hasPrefix("Pass")
        }

        #expect(query == Query(locator: .xpath, value: "//input[(@id = //label[starts-with(normalize-space(.), \"Pass\")]/@for or (ancestor::label[starts-with(normalize-space(.), \"Pass\")] and (self::button or self::input or self::meter or self::output or self::progress or self::select or self::textarea)))]"))
    }

    // MARK: - Tag negation

    @Test func tagNotEqual() async throws {
        let query = query {
            $0.tag != "div"
        }

        #expect(query == Query(locator: .xpath, value: "//*[not(self::div)]"))
    }

    @Test func negateTagANDAttribute() async throws {
        let query = query {
            !($0.tag == "div" && $0.class == "x")
        }

        #expect(query == Query(locator: .xpath, value: "//*[not((self::div and @class=\"x\"))]"))
    }

    @Test func tagNotEqualANDTag() async throws {
        let query = query {
            $0.tag == "p" && $0.class == "x" && $0.tag != "div"
        }

        #expect(query == Query(locator: .xpath, value: "//p[@class=\"x\" and not(self::div)]"))
    }

    @Test func negateLinkText() async throws {
        let query = query {
            !($0.hrefText == "Docs")
        }

        #expect(query == Query(locator: .xpath, value: "//*[not((self::a and normalize-space(.)=\"Docs\"))]"))
    }

    // MARK: - Relative

    @Test func hasDescendantWithTag() async throws {
        let query = query {
            $0.tag == "div" && $0.has { $0.tag == "button" && $0.text == "OK" }
        }

        #expect(query == Query(locator: .xpath, value: "//div[descendant::button[text()=\"OK\"]]"))
    }

    @Test func hasDescendantTagOnly() async throws {
        let query = query {
            $0.has { $0.tag == "img" }
        }

        #expect(query == Query(locator: .xpath, value: "//*[descendant::img]"))
    }

    @Test func hasDescendantWithoutTag() async throws {
        let query = query {
            $0.has { $0.text == "OK" }
        }

        #expect(query == Query(locator: .xpath, value: "//*[descendant::*[text()=\"OK\"]]"))
    }

    @Test func nestedHas() async throws {
        let query = query {
            $0.tag == "ul" && $0.has { $0.tag == "li" && $0.has { $0.hrefText == "Home" } }
        }

        #expect(query == Query(locator: .xpath, value: "//ul[descendant::li[descendant::a[normalize-space(.)=\"Home\"]]]"))
    }

    @Test func follows() async throws {
        let query = query {
            $0.tag == "dd" && $0.follows { $0.tag == "dt" && $0.text == "Price" }
        }

        #expect(query == Query(locator: .xpath, value: "//dd[preceding-sibling::*[1][(self::dt and text()=\"Price\")]]"))
    }

    // MARK: - Case-insensitive

    @Test func attributeEqualsCaseInsensitive() async throws {
        let query = query {
            $0.title.equals("Abc", caseInsensitive: true)
        }

        #expect(query == Query(locator: .css, value: "[title=\"Abc\" i]"))
    }

    @Test func attributeHasPrefixCaseInsensitive() async throws {
        let query = query {
            $0.href.hasPrefix("HTTPS", caseInsensitive: true)
        }

        #expect(query == Query(locator: .css, value: "[href^=\"HTTPS\" i]"))
    }

    @Test func attributeHasSuffixCaseInsensitiveInXPath() async throws {
        let query = query {
            $0.src.hasSuffix(".PNG", caseInsensitive: true) && $0.text == "x"
        }

        let src = "translate(@src, \"ABCDEFGHIJKLMNOPQRSTUVWXYZ\", \"abcdefghijklmnopqrstuvwxyz\")"
        #expect(query == Query(locator: .xpath, value: "//*[(substring(\(src), string-length(\(src)) - string-length(\".png\") + 1)=\".png\" and text()=\"x\")]"))
    }

    @Test func textEqualsCaseInsensitive() async throws {
        let query = query {
            $0.normalizedTextContent.equals("Sign In", caseInsensitive: true)
        }

        #expect(query == Query(locator: .xpath, value: "//*[translate(normalize-space(.), \"ABCDEFGHIJKLMNOPQRSTUVWXYZ\", \"abcdefghijklmnopqrstuvwxyz\")=\"sign in\"]"))
    }

    @Test func caseFoldingIsASCIIOnly() async throws {
        #expect(XPathQuery.asciiLowercased("ÉCOLE Ok") == "École ok")
    }

    // MARK: - Empty

    @Test func isEmpty() async throws {
        let query = query {
            $0.tag == "td" && $0.textContent.isEmpty
        }

        #expect(query == Query(locator: .xpath, value: "//td[normalize-space(string(.))=\"\"]"))
    }

    // MARK: - Classes

    @Test func classesContainsAll() async throws {
        let query = query {
            $0.tag == "button" && $0.classes.contains(all: ["btn", "large"])
        }

        #expect(query == Query(locator: .css, value: "button[class~=\"btn\"][class~=\"large\"]"))
    }

    @Test func classesContainsAllSingle() async throws {
        let query = query {
            $0.classes.contains(all: ["btn"])
        }

        #expect(query == Query(locator: .css, value: "[class~=\"btn\"]"))
    }

}
