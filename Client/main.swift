//
//  main.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import WebDriver

let driver = WebDriver.Firefox()

let session = try await driver.startSession()
try await session.set(timeout: Session<GeckoLauncher>.Timeout(script: .seconds(1)))
try await print(session.timeout)

try await session.close()
