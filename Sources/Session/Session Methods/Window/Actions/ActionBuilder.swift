//
//  ActionBuilder.swift
//  WebDriver
//
//  Created by Claude on 11/25/26.
//

import Foundation
import CoreGraphics
import Essentials


extension Session.Window {

    /// A sequence of keyboard, mouse, and scroll wheel actions, performed with ``perform(fileID:line:function:_:)``.
    ///
    /// Each method adds one step. Steps run in order, one after another.
    ///
    /// ```swift
    /// try await window.perform {
    ///     $0.move(to: source)
    ///     $0.pointerDown()
    ///     $0.move(to: target, duration: .milliseconds(250))
    ///     $0.pointerUp()
    /// }
    /// ```
    ///
    /// ## See Also
    /// - [W3C WebDriver Specification – Actions](https://www.w3.org/TR/webdriver2/#actions)
    public struct ActionBuilder: Sendable {

        private var steps: [Step] = []


        init() {}


        // MARK: - Keyboard

        /// Presses `key` down, without its modifiers.
        public mutating func keyDown(_ key: Key) {
            self.steps.append(Step(source: .keyboard, action: .keyDown(key.character)))
        }

        /// Releases `key`, without its modifiers.
        public mutating func keyUp(_ key: Key) {
            self.steps.append(Step(source: .keyboard, action: .keyUp(key.character)))
        }

        /// Presses and releases `key`, holding its modifiers.
        ///
        /// The modifiers are pressed first and released last, in reverse order.
        public mutating func press(_ key: Key) {
            let modifiers = key.modifiers.keyValues
            for modifier in modifiers {
                self.steps.append(Step(source: .keyboard, action: .keyDown(modifier)))
            }
            self.steps.append(Step(source: .keyboard, action: .keyDown(key.character)))
            self.steps.append(Step(source: .keyboard, action: .keyUp(key.character)))
            for modifier in modifiers.reversed() {
                self.steps.append(Step(source: .keyboard, action: .keyUp(modifier)))
            }
        }

        /// Types `text`, pressing and releasing each character in turn.
        public mutating func type(_ text: String) {
            for character in text {
                self.press(Key(character))
            }
        }


        // MARK: - Mouse

        /// Moves the mouse to the center of `element`, shifted by `offset`.
        public mutating func move(to element: Element, offset: CGPoint = .zero, duration: Duration = .zero) {
            self.steps.append(Step(source: .mouse, action: .pointerMove(origin: .element(element.id), x: offset.x, y: offset.y, duration: duration)))
        }

        /// Moves the mouse by `offset` from where it is.
        public mutating func move(by offset: CGPoint, duration: Duration = .zero) {
            self.steps.append(Step(source: .mouse, action: .pointerMove(origin: .pointer, x: offset.x, y: offset.y, duration: duration)))
        }

        /// Presses `button` down.
        public mutating func pointerDown(button: MouseButton = .left) {
            self.steps.append(Step(source: .mouse, action: .pointerDown(button)))
        }

        /// Releases `button`.
        public mutating func pointerUp(button: MouseButton = .left) {
            self.steps.append(Step(source: .mouse, action: .pointerUp(button)))
        }


        // MARK: - Scroll wheel

        /// Scrolls by `delta`, in CSS pixels, with the wheel over the center of `element`, or over the top left of the viewport when `element` is `nil`.
        public mutating func scroll(by delta: CGPoint, at element: Element? = nil, duration: Duration = .zero) {
            let origin: Origin = element.map { .element($0.id) } ?? .viewport
            self.steps.append(Step(source: .wheel, action: .scroll(origin: origin, deltaX: delta.x, deltaY: delta.y, duration: duration)))
        }


        // MARK: - Timing

        /// Waits for `duration` before the next step.
        public mutating func pause(_ duration: Duration) {
            self.steps.append(Step(source: .keyboard, action: .pause(duration)))
        }


        // MARK: - Serialization

        /// The `actions` parameter of the Perform Actions command.
        ///
        /// Each step is a tick: its action is on its own input source, and the other sources pause.
        func makeJSON() -> [[String : Any]] {
            Source.allCases.compactMap { source in
                guard self.steps.contains(where: { $0.source == source }) else { return nil }

                var json = source.parameters
                json["actions"] = self.steps.map { step in
                    step.source == source ? step.action.json : ["type": "pause", "duration": 0]
                }
                return json
            }
        }


        /// A mouse button.
        public enum MouseButton: Int, Sendable {
            case left = 0
            case middle = 1
            case right = 2
        }


        private struct Step: Sendable {
            let source: Source
            let action: Action
        }

        private enum Source: CaseIterable, Sendable {
            case keyboard
            case mouse
            case wheel

            var parameters: [String : Any] {
                switch self {
                case .keyboard:
                    ["type": "key", "id": "keyboard"]
                case .mouse:
                    ["type": "pointer", "id": "mouse", "parameters": ["pointerType": "mouse"]]
                case .wheel:
                    ["type": "wheel", "id": "wheel"]
                }
            }
        }

        private enum Origin: Sendable {
            case viewport
            case pointer
            case element(String)

            var json: Any {
                switch self {
                case .viewport: "viewport"
                case .pointer: "pointer"
                case .element(let id): ["element-6066-11e4-a52e-4f735466cecf": id]
                }
            }
        }

        private enum Action: Sendable {
            case keyDown(String)
            case keyUp(String)
            case pointerMove(origin: Origin, x: Double, y: Double, duration: Duration)
            case pointerDown(MouseButton)
            case pointerUp(MouseButton)
            case scroll(origin: Origin, deltaX: Double, deltaY: Double, duration: Duration)
            case pause(Duration)

            var json: [String : Any] {
                switch self {
                case .keyDown(let value):
                    ["type": "keyDown", "value": value]
                case .keyUp(let value):
                    ["type": "keyUp", "value": value]
                case .pointerMove(let origin, let x, let y, let duration):
                    ["type": "pointerMove", "origin": origin.json, "x": Int(x.rounded()), "y": Int(y.rounded()), "duration": duration.milliseconds]
                case .pointerDown(let button):
                    ["type": "pointerDown", "button": button.rawValue]
                case .pointerUp(let button):
                    ["type": "pointerUp", "button": button.rawValue]
                case .scroll(let origin, let deltaX, let deltaY, let duration):
                    ["type": "scroll", "origin": origin.json, "x": 0, "y": 0, "deltaX": Int(deltaX.rounded()), "deltaY": Int(deltaY.rounded()), "duration": duration.milliseconds]
                case .pause(let duration):
                    ["type": "pause", "duration": duration.milliseconds]
                }
            }
        }

    }


    /// Performs a sequence of keyboard, mouse, and scroll wheel actions.
    ///
    /// All keys and buttons are released afterward, even if performing the actions fails.
    ///
    /// > First Responder:
    /// > The first responder is switched to `self`.
    public func perform(fileID: StaticString = #fileID, line: Int = #line, function: StaticString = #function, _ build: @Sendable (inout ActionBuilder) -> Void) async throws {
        var builder = ActionBuilder()
        build(&builder)
        let context = SwiftContext(fileID: fileID, line: line, function: function)

        try await self.becomeFirstResponder(context: context)

        do {
            let _ = try await self.session.data(.post, "session/\(self.session.id)/actions", json: ["actions": builder.makeJSON()],
                                                context: context, origin: .window(self), invoker: #function)
        } catch {
            try? await self.releaseActions(context: context)
            throw error
        }
        try await self.releaseActions(context: context)
    }

    /// Releases all keys and buttons held down by ``perform(fileID:line:function:_:)``.
    private func releaseActions(context: SwiftContext) async throws {
        let _ = try await self.session.data(.delete, "session/\(self.session.id)/actions", data: nil,
                                            context: context, origin: .window(self), invoker: "perform(fileID:line:function:_:)")
    }

}


private extension Duration {

    /// The duration in whole milliseconds, as WebDriver actions use.
    var milliseconds: Int {
        Int(self.components.seconds * 1_000 + self.components.attoseconds / 1_000_000_000_000_000)
    }

}
