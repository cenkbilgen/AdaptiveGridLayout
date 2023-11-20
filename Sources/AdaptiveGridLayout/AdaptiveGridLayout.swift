//
//  AdaptiveGridLayout.swift
//  AdaptiveGridLayout
//
//  Created by Cenk Bilgen on 2023-11-17.
//

import SwiftUI


public struct AdaptiveVerticalGrid: Layout {
    public let spacing: CGFloat
    public let itemAnchor: UnitPoint

    public init(spacing: CGFloat = 10, itemAnchor: UnitPoint = .center) {
        self.spacing = spacing
        self.itemAnchor = itemAnchor
    }

    // NOTE: Trying to use protocol's `func spacing(subviews: Subviews, cache: inout ())` added unnecessary complexity
    // use spacing in the sizing and placing

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var width: CGFloat = .zero
        var height: CGFloat = .zero
        var currentRowWidth: CGFloat = .zero
        var currentRowHeight: CGFloat = .zero

        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            currentRowHeight = max(currentRowHeight, size.height)
            if currentRowWidth + size.width > proposal.width ?? .infinity {
                // Move to next row
                height += currentRowHeight // size.height
                currentRowWidth = .zero
                currentRowHeight = size.height // use this item height as initial for row
            }
            currentRowWidth += size.width + spacing
            width = max(width, currentRowWidth)
        }

        height += currentRowHeight + spacing/2
        return CGSize(width: width, height: height)
    }


    // TODO: Deal with items wider than the entire proposed width, it will double new row them currently
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = .zero
        var currentY: CGFloat = .zero
        var currentRowMaxY: CGFloat = .zero

        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            currentRowMaxY = max(currentRowMaxY, size.height)
            if currentX + size.width > bounds.width {
                // move to next row
                currentX = .zero
                currentY += currentRowMaxY + spacing/2
                currentRowMaxY = size.height
            }

            let rowProposal = ProposedViewSize(width: proposal.width, height: currentRowMaxY + spacing/2)
            subview.place(at: CGPoint(x: bounds.minX + currentX, y: bounds.minY + currentY),
                          anchor: .topLeading,
                          proposal: rowProposal)
            currentX += size.width + spacing
        }
    }
}
