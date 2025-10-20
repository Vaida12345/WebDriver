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
            return try await self.parser(.get, "selected", context: .unavailable)!["value", .bool]
        }
    }
    
    /// Returns whether the element is enabled.
    public var isEnabled: Bool {
        get async throws {
            try await self.parser(.get, "enabled", context: .unavailable)!["value", .bool]
        }
    }
    
    /// Returns whether the element is displayed.
    public var isVisible: Bool {
        get async throws {
            try await self.parser(.get, "displayed", context: .unavailable)!["value", .bool]
        }
    }
    
    public var isClickable: Bool {
        get async throws {
            let script = """
        var e = arguments[0],
            st = window.getComputedStyle(e),
            r  = e.getBoundingClientRect(),
            cx = r.left + r.width/2,
            cy = r.top  + r.height/2,
            topEl = document.elementFromPoint(cx, cy);
        return !e.disabled
        && st.display!=\"none\"
        && st.visibility!=\"hidden\"
        && r.width>0 && r.height>0
        && (e===topEl || e.contains(topEl));
      """
            
            return try await self.window.execute(script, args: [["element-6066-11e4-a52e-4f735466cecf" : self.id]])["value", .bool]
        }
    }
    
}
