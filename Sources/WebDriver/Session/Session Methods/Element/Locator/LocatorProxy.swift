//
//  LocatorProxy.swift
//  WebDriver
//
//  Created by Vaida on 3/6/25.
//


extension Session.Window.Element {
    
    public struct LocatorProxy {
        
        /// The id of the element.
        ///
        /// This is the fastest way of locating an element.
        public var id: some Locator {
            IDLocator()
        }
        
    }
    
}
