//
//  main.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import WebDriver
import FinderItem


let driver = WebDriver.Firefox()
    .profile(location: "/Users/vaida/Library/Application Support/Firefox/Profiles/2hzm7hvo.Default User")
//    .profile(location: "/Users/vaida/Library/Caches/Firefox/Profiles/2hzm7hvo.Default User")

let session = try await driver.linkSession()

do {
    try await session.open(url: URL(string: "https://www.google.com")!)
    let window = try await session.window
    let element = try await window.findElement(where: { $0.tag == "textarea" && $0.title == "Search" })
    
    try await element.screenshot().write(to: .desktopDirectory/"file.png")
    
    
    try await print(window.cookies["NID"])
    
    print("All tests passed")
    
    try await Task.sleep(for: .seconds(10))
} catch {
    print(error)
}

try await session.close()
