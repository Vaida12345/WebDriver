//
//  Key.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//


extension Session.Window {

    /// A key, with the modifier keys held while it is pressed.
    ///
    /// Modeled on SwiftUI's `KeyboardShortcut`, a key can carry modifiers:
    ///
    /// ```swift
    /// try await field.press(.init("a", modifiers: .command))
    /// try await field.press(.init(.enter, modifiers: [.command, .shift]))
    /// ```
    ///
    /// Unlike `KeyboardShortcut`, a key has no modifiers by default.
    ///
    /// ## See Also
    /// - [W3C WebDriver Specification – Keyboard Actions](https://www.w3.org/TR/webdriver2/#keyboard-actions)
    public struct Key: Sendable, Hashable {

        /// The key value sent to the driver, a character or a code point from the W3C range `U+E000`–`U+E03D`.
        public let character: String

        /// The modifier keys held while the key is pressed.
        public let modifiers: Modifiers


        /// Creates a key for a character.
        public init(_ character: Character, modifiers: Modifiers = []) {
            self.character = String(character)
            self.modifiers = modifiers
        }

        /// Creates a key with modifiers, adding them to those of `key`.
        public init(_ key: Key, modifiers: Modifiers = []) {
            self.character = key.character
            self.modifiers = key.modifiers.union(modifiers)
        }

        private init(code: String) {
            self.character = code
            self.modifiers = []
        }


        /// The modifier keys.
        public struct Modifiers: OptionSet, Sendable, Hashable {

            public let rawValue: Int

            public init(rawValue: Int) {
                self.rawValue = rawValue
            }

            public static let shift = Modifiers(rawValue: 1 << 0)

            public static let control = Modifiers(rawValue: 1 << 1)

            /// The Option key, also known as Alt.
            public static let option = Modifiers(rawValue: 1 << 2)

            /// The Command key, also known as Meta.
            public static let command = Modifiers(rawValue: 1 << 3)

            /// The key values of the modifiers, in the order they are pressed.
            var keyValues: [String] {
                var values: [String] = []
                if self.contains(.shift) { values.append("\u{E008}") }
                if self.contains(.control) { values.append("\u{E009}") }
                if self.contains(.option) { values.append("\u{E00A}") }
                if self.contains(.command) { values.append("\u{E03D}") }
                return values
            }
        }


        public static let cancel = Key(code: "\u{E001}")
        public static let help = Key(code: "\u{E002}")
        public static let backspace = Key(code: "\u{E003}")
        public static let tab = Key(code: "\u{E004}")
        public static let clear = Key(code: "\u{E005}")
        public static let `return` = Key(code: "\u{E006}")
        public static let enter = Key(code: "\u{E007}")
        public static let pause = Key(code: "\u{E00B}")
        public static let escape = Key(code: "\u{E00C}")
        public static let space = Key(code: "\u{E00D}")
        public static let pageUp = Key(code: "\u{E00E}")
        public static let pageDown = Key(code: "\u{E00F}")
        public static let end = Key(code: "\u{E010}")
        public static let home = Key(code: "\u{E011}")
        public static let leftArrow = Key(code: "\u{E012}")
        public static let upArrow = Key(code: "\u{E013}")
        public static let rightArrow = Key(code: "\u{E014}")
        public static let downArrow = Key(code: "\u{E015}")
        public static let insert = Key(code: "\u{E016}")
        public static let delete = Key(code: "\u{E017}")
        
        /// The Shift key on its own, for ``ActionBuilder/keyDown(_:)`` and ``ActionBuilder/keyUp(_:)``. To press a key with Shift held, use ``Modifiers-swift.struct/shift`` instead.
        public static let shift = Key(code: "\u{E008}")
        /// The Control key on its own.
        public static let control = Key(code: "\u{E009}")
        /// The Option key on its own.
        public static let option = Key(code: "\u{E00A}")
        /// The Command key on its own.
        public static let command = Key(code: "\u{E03D}")
        
        public static let f1 = Key(code: "\u{E031}")
        public static let f2 = Key(code: "\u{E032}")
        public static let f3 = Key(code: "\u{E033}")
        public static let f4 = Key(code: "\u{E034}")
        public static let f5 = Key(code: "\u{E035}")
        public static let f6 = Key(code: "\u{E036}")
        public static let f7 = Key(code: "\u{E037}")
        public static let f8 = Key(code: "\u{E038}")
        public static let f9 = Key(code: "\u{E039}")
        public static let f10 = Key(code: "\u{E03A}")
        public static let f11 = Key(code: "\u{E03B}")
        public static let f12 = Key(code: "\u{E03C}")

    }

}
