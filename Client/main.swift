//
//  main.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import WebDriver
import FinderItem


let driver = try await WebDriver.Firefox()
    .pageLoadStrategy(.eager)
    .profile(location: "/Users/vaida/Library/Application Support/Firefox/Profiles/2hzm7hvo.Default User")

let session = try await driver.startSession()

do {
    try await session.open(url: URL(string: "https://www.google.com")!)
    let window = try await session.window
    let element = try await window.findElement(where: { $0.tag == "textarea1234567" && $0.title == "Search" })
    try await element.write("Swift")
    
//    try await Task.sleep(for: .seconds(10))
} catch {
    print(error)
}

try await session.close()
