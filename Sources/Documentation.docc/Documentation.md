# ``WebDriver``

The Swift wrapper for W3C HTTP WebDriver Protocol. 

## Overview

The WebDriver Protocol allows browser automation.


### Getting Started

Let's start by defining the driver we would like to use, along with the parameters.

```swift
let driver = WebDriver.Firefox()
    .pageLoadStrategy(.eager)
```

Launch the driver and create a new session. All interactions with the driver will be conducted through this session.

```swift
let session = try await driver.linkSession()
```

Let's head to Google, and search for a beautiful language.
```swift
// Navigate to Google
try await session.open(url: URL(string: "https://www.google.com")!)

// Obtain the window of focus
let window = try await session.window

// Locate the element on the window using the most natural way to any Swift developer.
let element = try await window.findElement(where: { $0.tag == "textarea" && $0.title == "Search" })

// Write "Swift", the `terminator` automatically hits enter for you.
try await element.write("Swift")
```

When you are done with the exploration, don't forget to close the session.
```swift
try await session.close()
```


## Topics

### WebDrivers

- ``WebDriver/Firefox``
- ``WebDriverProtocol``
- ``WebDriver``

### Endpoints

- ``Session``
- ``Session/Window``
- ``Session/Window/Element``

### Error Handling

- ``ServerError``
