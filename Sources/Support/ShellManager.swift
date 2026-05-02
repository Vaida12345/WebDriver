//
//  ShellManager.swift
//  WebDriver
//
//  Created by Vaida on 2/26/25.
//

#if os(macOS)
import Foundation
import FinderItem
import Essentials


/// A convenient interface to run shell.
///
/// - Important: One `ShellManager` can only deal with one task at a time. Such task is terminated when a `ShellManager` is deallocated.
///
/// **Initialization**
///
/// There are several ways to create a manager.
///
/// ```swift
/// // You can run the static method directly.
/// let shellManager = ShellManager.run(executable: "folder/executable", arguments: "ls")
///
/// // If you want you use the default shell (`/bin/zsh`), you can run this by
/// shellManager.run(arguments: "ls")
/// ```
///
/// **Getting results**
///
/// The ways of waiting for result.
///
/// ```swift
/// // You can obtain the result by
/// await shellManager.output()!
///
/// // Or, if you are not interested in the output
/// await shellManager.wait()
/// ```
///
/// ## Topics
///
/// ### Initialization
///
/// - ``run(executable:arguments:workingDirectory:)-swift.type.method``
/// - ``runInTerminal(lines:)``
///
///
/// ### Inspect outputs
///
/// - ``bytes()``
/// - ``lines()``
/// - ``output()``
///
///
/// ### Control the execution
///
/// - ``terminate()``
/// - ``wait()``
/// - ``pause()``
/// - ``resume()``
/// - ``isRunning``
///
///
/// ### Additional setups
///
/// - ``init()``
/// - ``onTermination(handler:)``
/// - ``environment``
/// - ``run(executable:arguments:workingDirectory:)-swift.method``
@dynamicMemberLookup
internal final class ShellManager: Equatable, Hashable, Identifiable, @unchecked Sendable {
    
    /// The object that represents a subprocess of the current process.
    private var task: Process
    
    /// The one-way communications channel between related processes.
    private var standardInput: Pipe
    private var standardOutput: Pipe
    private var standardError: Pipe
    
    /// Indicates whether this manager has launched at least one process.
    private var hasLaunched = false
    
    /// Returns a boolean value indicating whether the task is running.
    public var isRunning: Bool {
        task.isRunning
    }
    
    /// The environment for the receiver.
    ///
    /// If this method isn’t used, the environment is inherited from the process that created the receiver. This method raises an `NSInvalidArgumentException` if the system has launched the receiver.
    public var environment: [String : String]? {
        get {
            self.task.environment
        }
        set {
            self.task.environment = newValue
        }
    }
    
    /// Initialize a shell Manager.
    public init() {
        self.task = Process()
        self.standardInput = Pipe()
        self.standardOutput = Pipe()
        self.standardError = Pipe()
        self.configureTask()
    }
    
    /// Tears down the managed process when this manager is deallocated.
    deinit {
        if task.isRunning {
            task.terminate()
        }
        task.terminationHandler = nil
        closePipeHandles()
    }
    
    /// Errors that can occur when starting a process.
    public enum RunError: GenericError {
        case alreadyRunning
        
        public var title: String {
            "cannot run shell task"
        }
        
        public var message: String {
            switch self {
            case .alreadyRunning:
                "This ShellManager is already running a process"
            }
        }
    }
    
    /// Configures stdio and baseline behavior for the current process.
    private func configureTask() {
        task.standardInput = standardInput
        task.standardOutput = standardOutput
        task.standardError = standardError
    }
    
    /// Closes all file handles attached to the current pipes.
    private func closePipeHandles() {
        standardInput.fileHandleForWriting.closeFile()
        standardInput.fileHandleForReading.closeFile()
        standardOutput.fileHandleForWriting.closeFile()
        standardOutput.fileHandleForReading.closeFile()
        standardError.fileHandleForWriting.closeFile()
        standardError.fileHandleForReading.closeFile()
    }
    
    /// Replaces process and pipes to make the manager reusable after a completed run.
    private func resetTask() {
        closePipeHandles()
        self.task = Process()
        self.standardInput = Pipe()
        self.standardOutput = Pipe()
        self.standardError = Pipe()
        self.configureTask()
    }
    
    /// Runs a task with a specified executable and arguments.
    ///
    /// - Parameters:
    ///   - executable: The optional executable file.
    ///   - arguments: The arguments passed to the executable or shell.
    ///   - workingDirectory: The optional working directory.
    /// - Throws: ``RunError`` if the manager is currently running a process, plus any system launch error.
    public func run(executable: FinderItem? = nil, arguments: String, workingDirectory: FinderItem? = nil) throws {
        guard !task.isRunning else { throw RunError.alreadyRunning }
        
        if hasLaunched {
            resetTask()
        }
        
        self.task.currentDirectoryURL = workingDirectory?.url
        
        if let item = executable {
            self.task.executableURL = item.url
            self.task.arguments = [arguments]
            try self.task.run()
        } else {
            self.task.executableURL = URL(filePath: "/bin/zsh")
            self.task.arguments = ["-c", arguments]
            try self.task.run()
        }
        
        hasLaunched = true
    }
    
    /// Reads results from the `Process`.
    public func output() -> String? {
        guard let data = try? self.standardOutput.fileHandleForReading.readToEnd() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Reads `stderr` from the `Process`.
    public func error() -> String? {
        guard let data = try? self.standardError.fileHandleForReading.readToEnd() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// The bytes that made up the `stdout`.
    ///
    /// - SeeAlso: ``lines()``.
    public func bytes() -> FileHandle.AsyncBytes {
        self.standardOutput.fileHandleForReading.bytes
    }
    
    /// The lines of `stdout`.
    ///
    /// > Example:
    /// > To access the individual asynchronous lines,
    /// >
    /// > ```swift
    /// > for try await line in manager.lines() {
    /// >     // do something with `line`
    /// > }
    /// > ```
    public func lines() -> AsyncLineSequence<FileHandle.AsyncBytes> {
        self.standardOutput.fileHandleForReading.bytes.lines
    }
    
    /// Writes a string to stdin.
    ///
    /// - throws: ``WritingError``
    ///
    /// ## Topics
    /// ### Potential Error
    /// - ``WritingError``
    public func write(_ value: String) throws {
        guard let data = value.data(using: .utf8) else { throw WritingError.cannotFormDataFromString }
        try self.write(data)
    }
    
    public enum WritingError: GenericError {
        case cannotFormDataFromString
        case processNotRunning
        
        public var title: String {
            "cannot write to `stdin`"
        }
        
        public var message: String {
            switch self {
            case .cannotFormDataFromString:
                "Cannot form data from given string"
            case .processNotRunning:
                "Cannot write because no running process is attached"
            }
        }
    }
    
    /// Writes data to stdin.
    ///
    /// - Parameter value: The bytes to send to the running process.
    /// - Throws: ``WritingError/processNotRunning`` when no process is active, or any `FileHandle` write error.
    public func write(_ value: some DataProtocol) throws {
        guard task.isRunning else { throw WritingError.processNotRunning }
        try self.standardInput.fileHandleForWriting.write(contentsOf: value)
    }
    
    /// Waits until the managed process exits.
    ///
    /// - Returns: The process termination status, or `-1` if no process has been launched yet.
    @discardableResult
    public func wait() -> Int32 {
        guard hasLaunched else { return -1 }
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    /// Suspends execution of the receiver task.
    ///
    /// Multiple ``pause()`` messages can be sent, but they must be balanced with an equal number of ``resume()`` messages before the task resumes execution.
    public func pause() {
        task.suspend()
    }
    
    /// Resumes execution of a suspended task.
    ///
    /// Multiple ``pause()`` messages can be sent, but they must be balanced with an equal number of ``resume()`` messages before the task resumes execution.
    public func resume() {
        task.resume()
    }
    
    /// Requests the managed process to terminate if it is currently running.
    ///
    /// This method avoids sending signals when no child process is active.
    public func terminate() {
        guard task.isRunning else { return }
        task.terminate()
    }
    
    /// A completion block the system invokes when the task completes.
    public func onTermination(handler: @Sendable @escaping (Process) -> Void) {
        task.terminationHandler = handler
    }
    
    /// Creates the hash value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.task)
    }
    
    
    /// Creates and runs a task with a specified executable and arguments.
    ///
    /// - Parameters:
    ///   - executable: The optional executable file
    ///   - arguments: The arguments
    ///   - workingDirectory: Specify the optional working directory
    public static func run(executable: FinderItem? = nil, arguments: String, workingDirectory: FinderItem? = nil) throws -> ShellManager {
        let manager = ShellManager()
        try manager.run(executable: executable, arguments: arguments, workingDirectory: workingDirectory)
        return manager
    }
    
    
    public struct ScriptError: GenericError {
        public let title: String
        public let message: String
    }
    
    
    /// Compares two managers.
    public static func == (lhs: ShellManager, rhs: ShellManager) -> Bool {
        lhs.task == rhs.task && lhs.id == rhs.id
    }
    
    /// The implementation of dynamic callable.
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Process, Subject>) -> Subject {
        get { self.task[keyPath: keyPath] }
        set { self.task[keyPath: keyPath] = newValue }
    }
    
    /// The implementation of dynamic callable.
    public subscript<Subject>(dynamicMember keyPath: KeyPath<Process, Subject>) -> Subject {
        self.task[keyPath: keyPath]
    }
    
}
#endif
