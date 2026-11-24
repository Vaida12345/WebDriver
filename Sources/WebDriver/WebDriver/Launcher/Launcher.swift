//
//  WebDriverLauncher.swift
//  WebDriver
//
//  Created by Vaida on 3/4/25.
//

import Foundation


protocol WebDriverLauncher<Driver> {
    
    var driver: Driver { get }

    /// The host of the WebDriver server, without a scheme or port.
    var host: String { get }

    var port: UInt16 { get }

    /// Tells the launcher the id of the session created on its server, so it can end the session if it is dropped without being closed.
    func attach(sessionID: String)

    /// Stops the server and cleans up after it. Calling it again does nothing.
    func stop() async

    associatedtype Driver: WebDriverProtocol

}


extension WebDriverLauncher {

    var baseURL: URL {
        makeBaseURL(host: self.host, port: self.port)!
    }
}


/// Returns `http://host:port`, or `nil` if `host` is not a valid host.
internal func makeBaseURL(host: String, port: UInt16) -> URL? {
    var components = URLComponents()
    components.scheme = "http"
    components.host = host
    components.port = Int(port)
    return components.url
}


/// Returns an ephemeral TCP port that is available at allocation time.
internal func generateRandomPort() -> UInt16 {
    let descriptor = socket(AF_INET, Int32(SOCK_STREAM), 0)
    guard descriptor >= 0 else {
        fatalError("Unable to create socket for port generation: \(String(cString: strerror(errno))).")
    }
    defer { close(descriptor) }
    
    // Bind to loopback to avoid selecting a non-local interface address.
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = in_port_t(0)
    address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))
    
    let bindResult = withUnsafePointer(to: &address) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            bind(descriptor, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
    guard bindResult == 0 else {
        fatalError("Unable to bind socket for port generation: \(String(cString: strerror(errno))).")
    }
    
    var boundAddress = sockaddr_in()
    var boundAddressLength = socklen_t(MemoryLayout<sockaddr_in>.size)
    let nameResult = withUnsafeMutablePointer(to: &boundAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            getsockname(descriptor, $0, &boundAddressLength)
        }
    }
    guard nameResult == 0 else {
        fatalError("Unable to read generated socket port: \(String(cString: strerror(errno))).")
    }
    
    let port = UInt16(bigEndian: boundAddress.sin_port)
    return port
}
