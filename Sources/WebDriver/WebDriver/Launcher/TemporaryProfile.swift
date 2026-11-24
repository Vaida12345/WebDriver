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

/// Copies the profile at `template` like ``makeTemporaryProfile(from:)``, off the cooperative thread pool, as a profile can be large.
///
/// If the task is cancelled meanwhile, the copy is deleted and `CancellationError` is thrown.
func copyTemporaryProfile(from template: String) async throws -> String {
    let copy = try await Task.detached { try makeTemporaryProfile(from: template) }.value
    if Task.isCancelled {
        removeTemporaryProfile(at: copy)
        throw CancellationError()
    }
    return copy
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
