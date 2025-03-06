//
//  State.swift
//  WebDriver
//
//  Created by Vaida on 3/7/25.
//

import Essentials


extension Element {
    
    /// Whether the element is selected.
    ///
    /// - term If element is an input element with a type attribute in the `Checkbox-` or `Radio Button` state: Returns the result of element's `checkedness`.
    /// - term If element is an option element: Returns the result of element's `selectedness`.
    /// - term Otherwise: `false`.
    public var isSelected: Bool {
        get async throws {
            return try await self.parser(.get, "selected")!["value", .bool]
        }
    }
    
}
