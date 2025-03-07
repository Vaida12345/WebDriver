# WebDriver

Similar to Selenium, this package is a Swift wrapper for the WebDriver protocol, allowing browser automations.

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

