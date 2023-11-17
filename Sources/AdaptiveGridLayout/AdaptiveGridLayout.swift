//
//  AdaptiveGridLayout.swift
//  AdaptiveGridLayout
//
//  Created by Cenk Bilgen on 2023-11-17.
//

import SwiftUI


public struct AdaptiveVerticalGrid: Layout {
    public let spacing: CGFloat

    // in prep for work on rows with irregular vertical sized items, keep fixed for now
    public let minItemWidth: CGFloat = .zero
    public let itemAnchor: UnitPoint = .topLeading

    public init(spacing: CGFloat = 6) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var width: CGFloat = minItemWidth
        var height: CGFloat = .zero
        var currentRowWidth: CGFloat = .zero

        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            if currentRowWidth + size.width > proposal.width ?? .infinity {
                // Move to next row
                height += size.height + spacing
                currentRowWidth = .zero
            }

            currentRowWidth += max(size.width, minItemWidth) + spacing
            width = max(width, currentRowWidth)
        }

        height += subviews.last?.sizeThatFits(proposal).height ?? .zero
        return CGSize(width: width + spacing, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = .zero
        var currentY: CGFloat = .zero

        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            if currentX + max(minItemWidth, size.width) > bounds.width {
                // move to next row
                currentX = .zero
                currentY += size.height + spacing
            }

            subview.place(at: CGPoint(x: bounds.minX + currentX, y: bounds.minY + currentY), anchor: itemAnchor, proposal: proposal)
            currentX += max(minItemWidth, size.width) + spacing
        }
    }
}
