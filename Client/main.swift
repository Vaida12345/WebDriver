//
//  main.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import WebDriver


let driver = WebDriver.Firefox()

let session = try await driver.startSession()
do {
    try await session.set(timeout: Timeout(script: .seconds(1)))
    
    let timeout = try await session.timeout
    expect(timeout, equals: Timeout(script: .seconds(1), pageLoad: .seconds(300)))
    
    let url = URL(string: "https://www.google.com/")!
    try await session.open(url: url)
    try await expect(session.url, equals: url)
    
    try await expect(session.title, equals: "Google")
    
    
    let window = try await session.window
    let newWindow = try await session.makeWindow(type: .window)
    
    let _ = try await window.frame
    
    print("All tests passed")
    
    try await Task.sleep(for: .seconds(3))
} catch {
    print(error)
}

try await session.close()
