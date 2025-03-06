//
//  main.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import WebDriver


let driver = WebDriver.Firefox()
    .profile(location: "/Users/vaida/Library/Application Support/Firefox/Profiles/2hzm7hvo.Default User")
//    .profile(location: "/Users/vaida/Library/Caches/Firefox/Profiles/2hzm7hvo.Default User")

print("123")
let session = try await driver.linkSession()

do {
    
    
    print("All tests passed")
    
    try await Task.sleep(for: .seconds(3))
} catch {
    print(error)
}

try await session.close()
