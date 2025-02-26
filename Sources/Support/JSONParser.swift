
//
//  JSONParser.swift
//  The Stratum Module
//
//  Created by Vaida on 8/17/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import Essentials


/// The parser that can handle json and throw detailed errors.
///
/// - Tip: When working with top-level arrays, use `[JSONParser](data:)` initializer.
///
/// ## Components
///
/// There are four different ways to access different components.
///
/// | Component | function |
/// | ----------- | ----------- |
/// | obtain value | ``value(_:type:)`` |
/// | obtain object | ``object(_:)`` |
/// | obtain array of values | ``array(_:type:)`` |
/// | obtain array of objects | ``array(_:)`` |
///
/// With ``subscript(_:_:)`` equivalent to ``value(_:type:)``.
///
/// > Example:
/// >
/// > Decoding a json tree.
/// > ```swift
/// > let json = {
/// >     "pi": 3.1415
/// > }
/// >
/// > let parser = try JSONParser(data: json.data())
/// > try parser.value("pi", type: .numeric.optional) // 3.1415?
/// > ```
///
/// > Throws:
/// > If there exists an error:
/// > ```swift
/// > try parser.value("pi", type: .bool)
/// > ```
/// > The parser would throw the error of ``ParserError/typeError(key:parentKey:type:actual:)``.
public final class JSONParser: CustomStringConvertible {
    
    private let key: String
    
    /// The dictionary that made up the object.
    private let dictionary: [String: Any]
    
    
    /// The pretty printed json object.
    public var description: String {
        guard let json = try? JSONSerialization.data(withJSONObject: self.dictionary, options: [.prettyPrinted]),
              let string = String(data: json, encoding: .utf8) else { return "Invalid JSON Parser Object" }
        return string
    }
    
    
    /// Creates the parser with the json data.
    ///
    /// - Parameters:
    ///   - data: A data object containing JSON data.
    ///   - options: Options for reading the JSON data and creating the Foundation objects.
    ///
    /// - throws: JSON parsing error, ``ParserError/notAnObject(key:)``
    public init(data: Data, options: JSONSerialization.ReadingOptions = []) throws {
        let object = try JSONSerialization.jsonObject(with: data, options: options)
        guard let dictionary = object as? [String: Any] else { throw ParserError.notAnObject(key: "root") }
        self.dictionary = dictionary
        self.key = "root"
    }
    
    /// Creates the parser with the json data.
    ///
    /// - Parameters:
    ///   - string: A data object containing JSON data.
    ///   - options: Options for reading the JSON data and creating the Foundation objects.
    ///
    /// - throws: JSON parsing error, ``ParserError/notAnObject(key:)``
    public init(string: String, options: JSONSerialization.ReadingOptions = []) throws {
        let object = try JSONSerialization.jsonObject(with: string.data(using: .utf8)!, options: options)
        guard let dictionary = object as? [String: Any] else { throw ParserError.notAnObject(key: "root") }
        self.dictionary = dictionary
        self.key = "root"
    }
    
    
    fileprivate init(key: String, dictionary: [String : Any]) {
        self.key = key
        self.dictionary = dictionary
    }
    
    
    /// Generates a JSON document using the container this parser.
    public func data() throws -> Data {
        try JSONSerialization.data(withJSONObject: self.dictionary)
    }
    
    
    /// Assume this element is an object, and returns the value associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "pi": 3.1415
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > try parser.value("pi", type: .numeric) // 3.1415
    /// > ```
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///   - type: The type of the returned value.
    ///
    /// - throws: ``ParserError/keyError(key:parentKey:)``, ``ParserError/typeError(key:parentKey:type:actual:)``
    public func value<T>(_ key: String, type: Object<T>) throws -> T {
        guard let value = dictionary[key] else { throw ParserError.keyError(key: key, parentKey: "root") }
        
        return try __parseOneValue(key: key, value: value, type: type)
    }
    
    private func __parseOneValue<T>(key: String, value: Any, type: Object<T>) throws -> T {
        if type.isOptional {
            if value is NSNull {
                switch type.key {
                case .string:
                    return Optional<String>.none as! T
                case .numeric:
                    return Optional<Double>.none as! T
                case .bool:
                    return Optional<Bool>.none as! T
                }
            } else {
                switch type.key {
                case .string:
                    guard let value = value as? String else { throw ParserError.typeError(key: key, parentKey: "root", type: type.key.rawValue, actual: "\(Swift.type(of: value))") }
                    return value as! T
                case .numeric:
                    guard let value = value as? Double else { throw ParserError.typeError(key: key, parentKey: "root", type: type.key.rawValue, actual: "\(Swift.type(of: value))") }
                    return value as! T
                case .bool:
                    guard let value = value as? Bool else { throw ParserError.typeError(key: key, parentKey: "root", type: type.key.rawValue, actual: "\(Swift.type(of: value))") }
                    return value as! T
                }
            }
        } else {
            guard let value = value as? T else { throw ParserError.typeError(key: key, parentKey: "root", type:type.key.rawValue, actual: "\(Swift.type(of: value))") }
            return value
        }
    }
    
    /// Assume this element is an object, and returns the object associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "Double" : {
    /// >         "pi": 3.1415
    /// >     }
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > try parser.object("Double") // { "pi": 3.1415 }
    /// > ```
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///
    /// - throws: ``ParserError/keyError(key:parentKey:)``, ``ParserError/notAnObject(key:)``
    public func object(_ key: String) throws -> JSONParser {
        guard let object = dictionary[key] else { throw ParserError.keyError(key: key, parentKey: "root") }
        guard let dictionary = object as? [String: Any] else { throw ParserError.notAnObject(key: key) }
        return JSONParser(key: key, dictionary: dictionary)
    }
    
    /// Assume this element is an object, and returns the array of objects associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "values" : [{
    /// >         "pi": 3.1415
    /// >     }]
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > parser.array("values") // [{ "pi": 3.1415 }]
    /// > ```
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///
    /// - throws: ``ParserError/keyError(key:parentKey:)``, ``ParserError/notAnArray(key:)``
    public func array(_ key: String) throws -> [JSONParser] {
        guard let object = dictionary[key] else { throw ParserError.keyError(key: key, parentKey: "root") }
        guard let dictionaries = object as? [[String: Any]] else { throw ParserError.notAnArray(key: key) }
        return dictionaries.map { JSONParser(key: key, dictionary: $0) }
    }
    
    /// Assume this element is an object, and returns the array of `T` associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "values" : [
    /// >         3, 4, 5, 6
    /// >     ]
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > try parser.array("values", type: .numeric) // [3, 4, 5, 6]
    /// > ```
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///   - type: The type of each element in the array.
    ///
    /// - throws: ``ParserError/keyError(key:parentKey:)``, ``ParserError/notAnArray(key:)``, ``ParserError/typeError(key:parentKey:type:actual:)``
    public func array<T>(_ key: String, type: Object<T>) throws -> [T] {
        guard let object = dictionary[key] else { throw ParserError.keyError(key: key, parentKey: "root") }
        guard let dictionaries = object as? [Any] else { throw ParserError.notAnArray(key: key) }
        
        return try dictionaries.map { value in
            try __parseOneValue(key: key, value: value, type: type)
        }
    }
    
    /// Assume this element is an object, and returns the value associated with `key`.
    ///
    /// > Example:
    /// > ```swift
    /// > let json = {
    /// >     "pi": 3.1415
    /// > }
    /// >
    /// > let parser = try JSONParser(data: json.data())
    /// > try parser["pi", .numeric] // 3.1415
    /// > ```
    ///
    /// The is equivalent to ``value(_:type:)``, DO NOT use this to obtain a JSON Object.
    ///
    /// - Parameters:
    ///   - key: The key for the value.
    ///   - type: The type of the returned value.
    ///
    /// - throws: ``ParserError/keyError(key:parentKey:)``, ``ParserError/typeError(key:parentKey:type:actual:)``
    public subscript<T>(_ key: String, type: Object<T> = .string) -> T {
        get throws {
            try self.value(key, type: type)
        }
    }
    
    
    /// The only error thrown by ``JSONParser``.
    public enum ParserError: GenericError {
        
        /// The error when the given key to the dictionary is not fount.
        ///
        /// - Parameters:
        ///   - key: The key itself.
        ///   - parentKey: The key in its parent to this object.
        case keyError(key: String, parentKey: String)
        
        /// The error when the given key to the dictionary is not an object.
        ///
        /// - Parameters:
        ///   - key: The key itself.
        case notAnObject(key: String)
        
        /// The error when the given key to the dictionary is associated with a value, but the type does not match.
        ///
        /// - Parameters:
        ///   - key: The key itself.
        ///   - parentKey: The key in its parent to this object.
        ///   - type: The expected type.
        ///   - actual: The found type
        case typeError(key: String, parentKey: String, type: String, actual: String)
        
        /// The error when the given key to the dictionary is not an array.
        ///
        /// - Parameters:
        ///   - key: The key itself.
        case notAnArray(key: String)
        
        public var title: String {
            "JSON Parsing Error"
        }
        
        public var message: String {
            switch self {
            case let .keyError(key, parentKey):
                return "The key \"\(key)\" not found in the JSON object \"\(parentKey)\""
            case let .notAnObject(key):
                return "\"\(key)\" is not an JSON object"
            case let .typeError(key, parentKey, type, actual):
                if actual == "NSNull" {
                    return "The type associated with \"\(key)\" under \"\(parentKey)\" is `nil`."
                } else {
                    return "The type associated with \"\(key)\" under \"\(parentKey)\" is not \(type). Found: \(actual)."
                }
            case let .notAnArray(key):
                return "\"\(key)\" is not an array of JSON objects"
            }
        }
    }
    
    /// The type of objects extracted from JSON.
    public struct Object<T> {
        
        fileprivate let key: Key
        
        fileprivate let isOptional: Bool
        
        
        /// Indicating extraction of `String`.
        public static var string: Object<String> { .init(key: .string, isOptional: false) }
        
        /// Indicating extraction of `Double`.
        public static var numeric: Object<Double> { .init(key: .numeric, isOptional: false) }
        
        /// Indicating extraction of `Bool`.
        public static var bool: Object<Bool> { .init(key: .bool, isOptional: false) }
        
        
        /// Marks the object as `optional`.
        public var optional: Object<T?> {
            .init(key: self.key, isOptional: true)
        }
    }
    
    fileprivate enum Key: String, Equatable {
        case string
        case numeric
        case bool
    }
    
}


extension Array where Element == JSONParser {
    
    /// Creates the parser array with the json data.
    ///
    /// - Parameters:
    ///   - data: A data object containing JSON data.
    ///   - options: Options for reading the JSON data and creating the Foundation objects.
    public init(data: Data, options: JSONSerialization.ReadingOptions = []) throws {
        let object = try JSONSerialization.jsonObject(with: data, options: options)
        guard let dictionaries = object as? [[String: Any]] else { throw JSONParser.ParserError.notAnArray(key: "root") }
        self = dictionaries.map { JSONParser(key: "root", dictionary: $0) }
    }
    
}
