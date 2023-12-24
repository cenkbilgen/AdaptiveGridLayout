//
//  File.swift
//  
//
//  Created by Cenk Bilgen on 2023-12-17.
//

import SwiftUI



public struct CenteredLayout: Layout {
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
