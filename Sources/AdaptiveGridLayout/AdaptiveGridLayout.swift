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

public struct FixedVGrid: Layout {
    public let columns: Int
    public let spacing: CGFloat
    public let itemAnchor: UnitPoint

    public init(columns: Int, spacing: CGFloat = .zero, itemAnchor: UnitPoint = .center) {
        self.columns = columns
        self.spacing = spacing
        self.itemAnchor = itemAnchor
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

public struct FixedVGridBalanced: Layout {
    let columns: Int
    let spacing: CGFloat
    let itemAnchor: UnitPoint

    public init(columns: Int, spacing: CGFloat = .zero, itemAnchor: UnitPoint = .center) {
        self.columns = columns
        self.spacing = spacing
        self.itemAnchor = itemAnchor
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var heights: [CGFloat] = Array(repeating: .zero, count: columns)
        var nextIndex = 0
        for (index, subview) in subviews.enumerated() {
            let columnIndex = heights.enumerated().min { $0.element < $1.element }?.offset ?? nextIndex
            nextIndex = (nextIndex + 1) % heights.count
            heights[columnIndex] += subview.sizeThatFits(proposal).height
        }
        return CGSize(width: proposal.width ?? .zero, height: heights.max() ?? .zero)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = .zero
        var currentHeights: [CGFloat] = Array(repeating: .zero, count: columns)
        let columnWidth = bounds.width/CGFloat(columns)

        var nextIndex = 0
        for (index, subview) in subviews.enumerated() {
            let columnIndex = currentHeights.enumerated().min { $0.element < $1.element }?.offset ?? nextIndex
            nextIndex = (nextIndex + 1) % currentHeights.count
            let x = columnWidth * CGFloat(columnIndex)
            let y = currentHeights[columnIndex]
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(width: columnWidth, height: nil))
            currentHeights[columnIndex] += subview.sizeThatFits(proposal).height
        }
    }
}



