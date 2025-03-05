//
//  Testing.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//


func expect<T>(_ lhs: T, equals rhs: T, line: UInt = #line) where T: Equatable {
    guard lhs != rhs else { return }
    print("Line \(line): Exception failed: \"\(lhs)\" != \"\(rhs)\"")
}
