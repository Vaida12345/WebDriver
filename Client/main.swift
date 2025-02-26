//
//  main.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import WebDriver

let driver = WebDriver.Firefox()
    .headless()

let session = try await driver.startSession()

try await session.close()
