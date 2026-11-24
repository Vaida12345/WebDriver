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
    query { predicate($0).makeQuery() }
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

    @Test func textHasSuffix() async throws {
        let query = query {
            $0.text.hasSuffix("abc")
        }

        #expect(query == Query(locator: .xpath, value: "//*[substring(text(), string-length(text()) - string-length(\"abc\") + 1)=\"abc\"]"))
    }

    @Test func attributeHasSuffixInXPath() async throws {
        let query = query {
            $0.title.hasSuffix("abc") && $0.text == "x"
        }

        #expect(query == Query(locator: .xpath, value: "//*[(substring(@title, string-length(@title) - string-length(\"abc\") + 1)=\"abc\" and text()=\"x\")]"))
    }

    @Test func xpathDoubleQuote() async throws {
        let query = query {
            $0.text == "say \"hi\""
        }

        #expect(query == Query(locator: .xpath, value: "//*[text()='say \"hi\"']"))
    }

    @Test func xpathBothQuotes() async throws {
        let query = query {
            $0.text == "it's \"hi\""
        }

        #expect(query == Query(locator: .xpath, value: "//*[text()=concat(\"it's \", '\"', \"hi\", '\"', \"\")]"))
    }

    @Test func cssEscaping() async throws {
        let query = query {
            $0.title == "a\"b\\c"
        }

        #expect(query == Query(locator: .css, value: "[title=\"a\\\"b\\\\c\"]"))
    }

    @Test func textContent() async throws {
        let query = query {
            $0.textContent == "a"
        }

        #expect(query == Query(locator: .xpath, value: "//*[string(.)=\"a\"]"))
    }

    @Test func customAttribute() async throws {
        let query = query {
            $0.attribute("data-testid") == "save"
        }

        #expect(query == Query(locator: .css, value: "[data-testid=\"save\"]"))
    }

    @Test func ariaLabel() async throws {
        let query = query {
            $0.ariaLabel == "Close"
        }

        #expect(query == Query(locator: .css, value: "[aria-label=\"Close\"]"))
    }

    @Test func role() async throws {
        let query = query {
            $0.role == "dialog"
        }

        #expect(query == Query(locator: .css, value: "[role=\"dialog\"]"))
    }

    @Test func attributeContainsCaseInsensitive() async throws {
        let query = query {
            $0.title.contains("Abc", caseInsensitive: true)
        }

        #expect(query == Query(locator: .css, value: "[title*=\"Abc\" i]"))
    }

    @Test func textContainsCaseInsensitive() async throws {
        let query = query {
            $0.text.contains("OK", caseInsensitive: true)
        }

        #expect(query == Query(locator: .xpath, value: "//*[contains(translate(text(), \"ABCDEFGHIJKLMNOPQRSTUVWXYZ\", \"abcdefghijklmnopqrstuvwxyz\"), \"ok\")]"))
    }

    @Test func classesContains() async throws {
        let query = query {
            $0.classes.contains("btn")
        }

        #expect(query == Query(locator: .css, value: "[class~=\"btn\"]"))
    }

    @Test func classesContainsInXPath() async throws {
        let query = query {
            $0.classes.contains("btn") && $0.text == "OK"
        }

        #expect(query == Query(locator: .xpath, value: "//*[(contains(concat(\" \", normalize-space(@class), \" \"), \" btn \") and text()=\"OK\")]"))
    }

    
}

