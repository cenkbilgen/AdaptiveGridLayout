# AdaptiveGridLayout

A SwiftUI Package for arranging subviews in an width-adaptive grid pattern expanding vertically, such as for a set of Tags.

At first, it seemed like the built-in `LazyVStack` could do it, but although it can make adaptive columns, that size is fixed for all rows. 

Minimum target is `macOS 13` or `iOS 16` (for `Layout`). 

## 1. Layout Example

```swift
import SwiftUI
import AdaptiveGridLayout

struct SampleView: View {
    var body: some View {
        AdaptiveVerticalGrid {
            ForEach(0..<100) { _ in
                Rectangle()
                    .frame(width: .random(in: 10..<120),
                           height: 30)
                    .foregroundColor(.random)
            }
        }
    }
}

extension Color {
    static var random: Color {
        Color(hue: .random(in: 0..<1.0), 
              saturation: .random(in: 0.1..<0.8),
              brightness:.random( in: 0.5..<0.9))
    }
}
```
![Simulator Screenshot - iPhone 15 Pro - 2023-11-17 at 13 41 48](https://github.com/cenkbilgen/AdaptiveGridLayout/assets/6772018/636ee501-1df1-4066-bfe4-5d9cbe9fbbe0)

## 2. TagsView Example

```swift
import SwiftUI
import AdaptiveGridLayout

// MARK: View

struct TagsView: View {
    var model = FoodModel()
    var body: some View {
        AdaptiveVerticalGrid(spacing: 6) {
            ForEach(model.fruits) { fruit in
                TagView(word: LocalizedStringKey(fruit.name))
            }
        }
    }
    
    struct TagView: View {
        let word: LocalizedStringKey
        var body: some View {
            Text(word)
                .font(.body.weight(.semibold).monospaced())
                .padding(.vertical, 4)
                .padding(.horizontal)
                .background(Color.red, in: Capsule(style: .circular))
                .foregroundStyle(.background)
        }
    }
}

// MARK: Model

// real app would be Observable/ObservedObject and use orderedSet
class FoodModel {
    var fruits: [Fruit] = ["Tangerine", "Honeydew", "Fig", "Zucchini", "Orange", "Cherry", "Papaya", "Dragon Fruit", "Dates", "Lemon", "Apple", "Nectarine", "Raspberry", "Banana"]

    struct Fruit: Identifiable, ExpressibleByStringLiteral {
        let name: String
        var id: String { name }
        init(stringLiteral value: StringLiteralType) {
            name = value
        }
    }
}
```
![Simulator Screenshot - iPhone 15 Pro - 2023-11-17 at 13 42 22](https://github.com/cenkbilgen/AdaptiveGridLayout/assets/6772018/44331ce3-5d18-4a5b-882c-5d81008aedb3)
