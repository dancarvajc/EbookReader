//
//  Extensions.swift
//  iOS Epub Reader
//
//  Created by Daniel Carvajal on 19-11-22.
//

import Foundation

// MARK: CGFloat

extension CGFloat {
    func clamped(to: ClosedRange<CGFloat>) -> CGFloat {
        return to.lowerBound > self ? to.lowerBound
            : to.upperBound < self ? to.upperBound
            : self
    }
}
