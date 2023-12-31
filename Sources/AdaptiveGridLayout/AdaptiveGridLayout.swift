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

    public init(spacing: CGFloat = .zero) {
        self.spacing = spacing
        let itemAlignment: VerticalAlignment = .top // NOTE: Fix for now
        self.itemAnchor = switch itemAlignment {
            case .bottom, .firstTextBaseline, .lastTextBaseline: // treat all text baselines as bottom
                UnitPoint(x: 0, y: 1)
            case .top:
                UnitPoint(x: 0, y: 0)
            default:
                UnitPoint(x: 0, y: 0.5) // center
        }
    }

    // TODO: Retry `func spacing(subviews: Subviews, cache: inout ())`

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
                height += currentRowHeight + spacing // size.height
                currentRowWidth = .zero
                currentRowHeight = size.height // use this item height as initial for row
            }
            // don't add spacing if new row
            currentRowWidth += size.width + (currentRowWidth.isZero ? .zero : spacing)
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
                currentY += currentRowMaxY + spacing // MARKING
                currentRowMaxY = size.height
            }

            let rowProposal = ProposedViewSize(width: proposal.width, height: currentRowMaxY + spacing/2)
            subview.place(at: CGPoint(x: bounds.minX + currentX, y: bounds.minY + currentY + itemAnchor.y*currentRowMaxY),
                          anchor: itemAnchor,
                          proposal: rowProposal)
            currentX += size.width + spacing
        }
    }
}
