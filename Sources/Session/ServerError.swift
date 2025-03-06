//
//  ServerError.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

import Foundation
import Essentials


/// Indicates the error received from server.
public struct ServerError: GenericError, @unchecked Sendable {
    
    /// The error code defined by the web driver protocol.
    public let code: ErrorCode
    
    /// The HTTP code.
    public let statusCode: Int
    
    /// The error message provided by the server.
    public let message: String
    
    /// The stack trace provided by the server.
    public let stackTrace: String
    
    public let data: JSONParser?
    
    public var title: String? {
        self.code.description
    }
    
    
    public func write(to stream: inout some TextOutputStream) {
        if let title {
            stream.write("\(title): \(message)")
        } else {
            stream.write(message)
        }
        
        if !stackTrace.isEmpty {
            stream.write("\n\tStack trace:\n")
            stream.write(stackTrace)
        }
    }
    
    public var description: String {
        var result = ""
        self.write(to: &result)
        return result
    }
    
    
    init(parser: JSONParser, response: HTTPURLResponse) throws {
        self.statusCode = response.statusCode
        self.code = try ErrorCode(rawValue: parser["error"])
        self.message = try parser["message"]
        self.stackTrace = try parser["stacktrace"]
        self.data = try? parser.object("data")
    }
    
    
    public static func == (_ lhs: ServerError, _ rhs: ServerError) -> Bool {
        lhs.statusCode == rhs.statusCode &&
        lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.stackTrace == rhs.stackTrace
    }
    
}


extension ServerError {
    
    /// The error code defined by the web driver protocol.
    public enum ErrorCode: Equatable, CustomStringConvertible {
        
        /// The Element Click command could not be completed because the element receiving the events is obscuring the element that was requested clicked.
        case element_click_intercepted
        
        /// A command could not be completed because the element is not pointer- or keyboard interactable.
        case element_not_interactable
        
        /// Navigation caused the user agent to hit a certificate warning, which is usually the result of an expired or invalid TLS certificate.
        case insecure_certificate
        
        /// The arguments passed to a command are either invalid or malformed.
        case invalid_argument
        
        /// An illegal attempt was made to set a cookie under a different domain than the current page.
        case invalid_cookie_domain
        
        /// A command could not be completed because the element is in an invalid state, e.g. attempting to clear an element that isn't both editable and resettable.
        case invalid_element_state
        
        /// Argument was an invalid selector.
        case invalid_selector
        
        /// Occurs if the given session id is not in the list of active sessions, meaning the session either does not exist or that it's not active.
        case invalid_session_id
        
        /// An error occurred while executing JavaScript supplied by the user.
        case javascript_error
        
        /// The target for mouse interaction is not in the browser's viewport and cannot be brought into that viewport.
        case move_target_out_of_bounds
        
        /// An attempt was made to operate on a modal dialog when one was not open.
        case no_such_alert
        
        /// No cookie matching the given path name was found amongst the associated cookies of session's current browsing context's active document.
        case no_such_cookie
        
        /// An element could not be located on the page using the given search parameters.
        case no_such_element
        
        /// A command to switch to a frame could not be satisfied because the frame could not be found.
        case no_such_frame
        
        /// A command to switch to a window could not be satisfied because the window could not be found.
        case no_such_window
        
        /// The element does not have a shadow root.
        case no_such_shadow_root
        
        /// A script did not complete before its timeout expired.
        case script_timeout
        
        /// A new session could not be created.
        case session_not_created
        
        /// A command failed because the referenced element is no longer attached to the DOM.
        case stale_element_reference
        
        /// A command failed because the referenced shadow root is no longer attached to the DOM.
        case detached_shadow_root
        
        /// An operation did not complete before its timeout expired.
        case timeout
        
        /// A command to set a cookie's value could not be satisfied.
        case unable_to_set_cookie
        
        /// A screen capture was made impossible.
        case unable_to_capture_screen
        
        /// A modal dialog was open, blocking this operation.
        case unexpected_alert_open
        
        /// A command could not be executed because the remote end is not aware of it.
        case unknown_command
        
        /// An unknown error occurred in the remote end while processing the command.
        case unknown_error
        
        /// The requested command matched a known URL but did not match any method for that URL.
        case unknown_method
        
        /// Indicates that a command that should have executed properly cannot be supported for some reason.
        case unsupported_operation
        
        /// An error that is not defined by the W3C WebDriver Protocol.
        case unknown(String)
        
        
        public var description: String {
            switch self {
            case .element_click_intercepted:
                "element click intercepted"
            case .element_not_interactable:
                "element not interactable"
            case .insecure_certificate:
                "insecure certificate"
            case .invalid_argument:
                "invalid argument"
            case .invalid_cookie_domain:
                "invalid cookie domain"
            case .invalid_element_state:
                "invalid element state"
            case .invalid_selector:
                "invalid selector"
            case .invalid_session_id:
                "invalid session id"
            case .javascript_error:
                "javascript error"
            case .move_target_out_of_bounds:
                "move target out of bounds"
            case .no_such_alert:
                "no such alert"
            case .no_such_cookie:
                "no such cookie"
            case .no_such_element:
                "no such element"
            case .no_such_frame:
                "no such frame"
            case .no_such_window:
                "no such window"
            case .no_such_shadow_root:
                "no such shadow root"
            case .script_timeout:
                "script timeout"
            case .session_not_created:
                "session not created"
            case .stale_element_reference:
                "stale element reference"
            case .detached_shadow_root:
                "detached shadow root"
            case .timeout:
                "timeout"
            case .unable_to_set_cookie:
                "unable to set cookie"
            case .unable_to_capture_screen:
                "unable to capture screen"
            case .unexpected_alert_open:
                "unexpected alert open"
            case .unknown_command:
                "unknown command"
            case .unknown_error:
                "unknown error"
            case .unknown_method:
                "unknown method"
            case .unsupported_operation:
                "unsupported operation"
            case .unknown(let string):
                string
            }
        }
        
        
        public init(rawValue: String) {
            switch rawValue {
            case "element click intercepted":
                self = .element_click_intercepted
            case "element not interactable":
                self = .element_not_interactable
            case "insecure certificate":
                self = .insecure_certificate
            case "invalid argument":
                self = .invalid_argument
            case "invalid cookie domain":
                self = .invalid_cookie_domain
            case "invalid element state":
                self = .invalid_element_state
            case "invalid selector":
                self = .invalid_selector
            case "invalid session id":
                self = .invalid_session_id
            case "javascript error":
                self = .javascript_error
            case "move target out of bounds":
                self = .move_target_out_of_bounds
            case "no such alert":
                self = .no_such_alert
            case "no such cookie":
                self = .no_such_cookie
            case "no such element":
                self = .no_such_element
            case "no such frame":
                self = .no_such_frame
            case "no such window":
                self = .no_such_window
            case "no such shadow root":
                self = .no_such_shadow_root
            case "script timeout":
                self = .script_timeout
            case "session not created":
                self = .session_not_created
            case "stale element reference":
                self = .stale_element_reference
            case "detached shadow root":
                self = .detached_shadow_root
            case "timeout":
                self = .timeout
            case "unable to set cookie":
                self = .unable_to_set_cookie
            case "unable to capture screen":
                self = .unable_to_capture_screen
            case "unexpected alert open":
                self = .unexpected_alert_open
            case "unknown command":
                self = .unknown_command
            case "unknown error":
                self = .unknown_error
            case "unknown method":
                self = .unknown_method
            case "unsupported operation":
                self = .unsupported_operation
                
            default:
                self = .unknown(rawValue)
            }
        }
        
    }
    
}

