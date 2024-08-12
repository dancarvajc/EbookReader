//
//  EbookReaderViewConfiguration.swift
//  iOS Epub Reader
//
//  Created by Daniel Carvajal on 19-11-22.
//

import Foundation
import UIKit

public struct EbookReaderViewConfiguration {
    let fontSize: CGFloat
    let fontColor: String
    let backgroundColor: UIColor
    let indicatorType: Indicator
    let indicatorColor: UIColor

    public init(fontSize: CGFloat = 20,
                fontColor: UIColor = .black,
                backgroundColor: UIColor = .white,
                indicatorType: Indicator = .custom,
                indicatorColor: UIColor = .yellow)
    {
        self.fontSize = fontSize
        self.fontColor = K.JavaScriptCode.fontColor(color: K.Color.getRGB(fontColor))
        self.backgroundColor = backgroundColor
        self.indicatorType = indicatorType
        self.indicatorColor = indicatorColor
    }

    static let defaultConfig = EbookReaderViewConfiguration()
}

public extension EbookReaderViewConfiguration {
    enum Indicator {
        case custom, native, hidden
    }
}
