//
//  main.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import WebDriver


let driver = WebDriver.Firefox()

let session = try await driver.linkSession()
do {
    try await session.set(timeout: Timeout(script: .seconds(1)))
    
    let timeout = try await session.timeout
    expect(timeout, equals: Timeout(script: .seconds(1), pageLoad: .seconds(300)))
    
    let url = URL(string: "https://www.google.com/")!
    try await session.open(url: url)
    try await expect(session.url, equals: url)
    
    try await expect(session.title, equals: "Google")
    
    
    let window = try await session.window
    
    let _ = try await window.frame
    try await window.setFrame(x: 0, y: 0, width: 100, height: 100)
    try await Task.sleep(for: .seconds(1))
    
    try await window.maximize()
    try await Task.sleep(for: .seconds(1))
    
    print("All tests passed")
    
    try await Task.sleep(for: .seconds(3))
} catch {
    print(error)
}

try await session.close()
