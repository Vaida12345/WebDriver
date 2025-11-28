//
//  main.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import WebDriver
import FinderItem


func main() async throws {
    let driver = try await WebDriver.Firefox()
        .pageLoadStrategy(.eager)
        .profile(location: "/Users/vaida/Library/Application Support/Firefox/Profiles/2hzm7hvo.Default User")
    
    let session = try await driver.startSession()
    print(session)
    
    let code = WebDriverError.ErrorCode.no_such_element
    assert(code == .no_such_element)
    print(code == .no_such_element)
    
    do {
        try await session.open(url: URL(string: "https://www.google.com")!)
        let window = try await session.window
        let element = try await window.findElement(where: { $0.tag == "textarea" && $0.title == "Search" })
        try await element.write("Swift")
        let child = try await window.wait(until: .elementPresence, timeout: .seconds(60), where: { $0.tag == "213456" })
        
        //    try await Task.sleep(for: .seconds(10))
    } catch {
        print(String(reflecting: error))
    }
    
    try await session.close()
}

try await main()
