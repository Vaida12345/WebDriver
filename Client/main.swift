//
//  main.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import WebDriver

let driver = WebDriver.Firefox()

let session = try await driver.startSession()


try await session.close()

print(try await session.status())
