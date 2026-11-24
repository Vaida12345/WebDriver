# WebDriver

Similar to Selenium, this package is a Swift wrapper for the WebDriver protocol, allowing browser automations.


## 101

Let's start by defining the driver we would like to use, along with the parameters.

```swift
let driver = WebDriver.Firefox()
    .pageLoadStrategy(.eager)
```

Safari works the same way with `WebDriver.Safari()`. Its driver comes with macOS, but you need to allow remote automation once, with `safaridriver --enable` or Safari's Develop menu.

Launch the driver and create a new session. All interactions with the driver will be conducted through this session.

```swift
let session = try await driver.startSession()
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

## Locator

Contrasting the type-safe implementation introduced by Swift, the *css selector* and *XPath* do not seem to fit seamlessly. This is why we will avoid direct interactions with them.

In this implementation, locators are encapsulated within a single function, utilizing a closure as a predicate. For example:
```swift
window.findElements {
    $0.tag == "div" && $0.title.contains("Git")
}
```
Internally, this package translates the predicate into a format that the `WebDriver` protocol can recognize. As an added bonus, it automatically selects the most efficient representation, i.e., using the efficient `css_selector` when possible and only falling back to `XPath` when necessary.

It supports all common attributes, including
- tag
- id
- title
- text
- ...

functions including
- `contains`
- `hasPrefix`
- `hasSuffix`
- `==`
- `!=`

And boolean operations, including
- `&&`
- `||`
- `!`


## Beyond the Basics

Dialogs opened by `alert`, `confirm`, or `prompt` are handled through the window.
```swift
try await window.wait(until: .alertPresent, timeout: .seconds(5))
print(try await window.alert.text)
try await window.alert.accept()
```

Elements inside an `iframe` are found through the frame's content.
```swift
let frame = try await window.findElement(where: { $0.tag == "iframe" })
let content = window.content(of: frame)
try await content.findElement(where: { $0.text == "Pay" }).click()
```

Elements inside a web component are found through its shadow root.
```swift
let host = try await window.findElement(where: { $0.tag == "my-component" })
let button = try await host.shadowRoot.findElement(where: { $0.tag == "button" })
```

Keyboard and mouse actions are available on elements, and as custom sequences.
```swift
try await menu.hover()
try await field.press(.init("a", modifiers: .command))
try await card.drag(to: column)

try await window.perform {
    $0.keyDown(.shift)
    $0.move(to: last)
    $0.pointerDown()
    $0.pointerUp()
    $0.keyUp(.shift)
}
```


## Running the Tests

The unit tests run against an in-process mock browser, and need no browser installed.
```bash
swift test --skip Integration
```

The integration tests drive real browsers, and only run when enabled.
```bash
GECKO_INTEGRATION=1 swift test --filter "Gecko Integration"
```
```bash
SAFARI_INTEGRATION=1 swift test --filter "Safari Integration"
```
The Gecko tests need `geckodriver` and Firefox installed. The Safari tests need remote automation allowed once, with `safaridriver --enable`.


## Getting Started

`WebDriver` uses [Swift Package Manager](https://www.swift.org/documentation/package-manager/) as its build tool. If you want to import in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://www.github.com/Vaida12345/WebDriver.git", branch: "main")
]
```
and then adding the appropriate module to your target dependencies.

### Using Xcode Package support

You can add this framework as a dependency to your Xcode project by clicking File -> Swift Packages -> Add Package Dependency. The package is located at:
```
https://www.github.com/Vaida12345/WebDriver
```


## Documentation

This package uses [DocC](https://www.swift.org/documentation/docc/) for documentation. [View on Github Pages](https://vaida12345.github.io/WebDriver/documentation/webdriver/)


## Credits

- [Subprocess](https://github.com/swiftlang/swift-subprocess)
