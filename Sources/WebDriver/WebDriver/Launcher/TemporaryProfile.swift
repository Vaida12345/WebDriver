//
//  TemporaryProfile.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Foundation
import FinderItem
import OSLog


/// Copies the profile at `template` to a new temporary location, for a session started with ``WebDriverInitializationFlags/copyProfileOnLaunch``.
///
/// - Returns: The path of the copy.
func makeTemporaryProfile(from template: String) throws -> String {
    let copy = FinderItem.temporaryDirectory/"\(UUID()).tempprofile"
    try FinderItem(at: template).copy(to: copy)
    return copy.path
}

/// Deletes a profile copied by ``makeTemporaryProfile(from:)``, logging a failure.
func removeTemporaryProfile(at path: String?) {
    guard let path else { return }
    do {
        try FileManager.default.removeItem(atPath: path)
    } catch {
        Logger(subsystem: "WebDriver", category: "Profile").fault("Failed to delete temporary profile at \(path): \(error)")
    }
}
