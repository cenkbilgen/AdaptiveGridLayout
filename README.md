# AdaptiveGridLayout

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcenkbilgen%2FAdaptiveGridLayout%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/cenkbilgen/AdaptiveGridLayout)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcenkbilgen%2FAdaptiveGridLayout%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/cenkbilgen/AdaptiveGridLayout)

A SwiftUI Package for arranging subviews in an width-adaptive grid pattern expanding vertically, such as for a set of Tags.

At first, it seemed like the built-in `LazyVStack` could do it, but although it can make adaptive columns, that size is fixed for all rows. 

Minimum target is `macOS 13` or `iOS 16` (for `Layout`). 

## 1. Layout Example

```swift
import SwiftUI
import AdaptiveGridLayout

struct SampleView: View {

    let itemHeight: CGFloat = 50

    @State var items: [(width: CGFloat, color: Color)] = (0..<40).map { _ in
        (CGFloat.random(in: 10..<120),
         Color(hue: .random(in: 0..<1.0),
               saturation: .random(in: 0.1..<0.8),
               brightness:.random( in: 0.5..<0.9))
        )
    }

    var body: some View {
        AdaptiveVGrid(spacing: 2) { // <------------

            ForEach(items.indices, id: \.self) { index in
                Rectangle()
                    .fill(items[index].color)
                    .frame(width: items[index].width, height: itemHeight)
                    .overlay { Text(index, format: .number) }
            }

        }
        .border(.blue)
        .containerRelativeFrame(.vertical)
    }

}
```
<img width="613" alt="Adaptive Layout Sample 1" src="https://github.com/cenkbilgen/AdaptiveGridLayout/assets/6772018/56039db3-ea54-4b51-8ec1-672328957ac4">

## 2. TagsView Example

```swift
import SwiftUI
import AdaptiveGridLayout

// MARK: View

struct TagsView: View {
    var model = FoodModel()
    var body: some View {
        AdaptiveVGrid(spacing: 6) {
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
<img width="613" alt="Adaptive Layout Example 2" src="https://github.com/cenkbilgen/AdaptiveGridLayout/assets/6772018/78b7a7ce-6be3-4824-9e38-04fc51b5c95c">

## Animation

Elements handle their own animation. The easiest way to add some animation to adding and removing elements is with `matchedGeometry`. 
For the sample above, add `.matchedGeometryEffect(id: fruit.id, in: namespace)` to each element then `.animation(.spring, value: model.fruits)`.

![looping_output](https://github.com/cenkbilgen/AdaptiveGridLayout/assets/6772018/6af635e6-ee0a-43a4-9837-88bda5f1331f)

