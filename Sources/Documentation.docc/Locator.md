# Locator

Element Locator.

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
