//
//  AdaptiveGridLayout.swift
//  AdaptiveGridLayout
//
//  Created by Cenk Bilgen on 2023-11-17.
//

import SwiftUI

// MARK: Vertical

public struct AdaptiveVGrid: Layout {
    public let spacing: CGFloat
    public let itemAnchor: UnitPoint

    public init(spacing: CGFloat = 0, itemAnchor: UnitPoint = .center) {
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
                height += currentRowHeight + spacing/2 // size.height
                currentRowWidth = .zero
                currentRowHeight = size.height // use this item height as initial for row
            }
            currentRowWidth += size.width + spacing
            width = max(width, currentRowWidth)
        }

        height += currentRowHeight
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

public struct FixedWidthVerticalGrid: Layout {
    let columns: Int
    public let spacing: CGFloat = .zero
    public let itemAnchor: UnitPoint = .center

    public init(columns: Int) {
        self.columns = columns
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var heights: [CGFloat] = Array(repeating: .zero, count: columns)
        for (index, subview) in subviews.enumerated() {
            let columnIndex = index.remainderReportingOverflow(dividingBy: columns).partialValue
            heights[columnIndex] += subview.sizeThatFits(proposal).height
        }
        return CGSize(width: proposal.width ?? .zero, height: heights.max() ?? .zero)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = .zero
        var currentHeights: [CGFloat] = Array(repeating: .zero, count: columns)
        let columnWidth = bounds.width/CGFloat(columns)

        for (index, subview) in subviews.enumerated() {
            let columnIndex = index.remainderReportingOverflow(dividingBy: columns).partialValue
            let x = columnWidth * CGFloat(columnIndex)
            let y = currentHeights[columnIndex]
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(width: columnWidth, height: nil))
            currentHeights[columnIndex] += subview.sizeThatFits(proposal).height
        }
    }
}



