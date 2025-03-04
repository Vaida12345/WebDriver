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
try await session.set(timeout: Timeout(script: .seconds(1)))

let timeout = try await session.timeout
expect(timeout, equals: Timeout(script: .seconds(1), pageLoad: .seconds(300)))

let url = URL(string: "https://www.google.com/")!
try await session.open(url: url)
try await expect(session.url, equals: url)

try await expect(session.title, equals: "Google")

//try await session.closeWindow()
try await session.windowHandle
try await session.new(.window)
try await session.windowHandle


print("All tests passed")

try await Task.sleep(for: .seconds(5))

try await session.windowHandle

try await session.close()
