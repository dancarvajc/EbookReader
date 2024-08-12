//
//  Constants.swift
//  iOS Epub Reader
//
//  Created by Daniel Carvajal on 19-11-22.
//

import Foundation
import UIKit

struct K {
    enum JavaScriptCode {
        static func fontColor(color: (r: Int, g: Int, b: Int)) -> String {
            return "document.getElementsByTagName('body')[0].style.color='rgb(\(color.r), \(color.g), \(color.b))';"
        }

        static func scrollTo(_ position: CGFloat = 0) -> String {
            return "window.scrollTo(0, \(position));"
        }

        static let imgAdjust = "var style = document.createElement('style');style.innerHTML = 'img { display: inline;height: auto;max-width: 100%; }';document.getElementsByTagName('head')[0].appendChild(style);"

        static let viewAdjust = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, shrink-to-fit=yes'); document.getElementsByTagName('head')[0].appendChild(meta);"

        static let transparentBackground = "var style = document.createElement('style'); style.innerHTML = 'body { background-color: transparent !important; }'; document.head.appendChild(style);"
    }

    enum Color {
        static func getRGB(_ color: UIColor) -> (Int, Int, Int) {
            let ciColor = CIColor(color: color)
            return (Int(ciColor.red) * 255, 
                    Int(ciColor.green) * 255,
                    Int(ciColor.blue) * 255)
        }
    }

    enum SaveDirectory {
        static let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        static let folder = "Books/Cache"
        static let fullURL = baseURL.appendingPathComponent(folder, isDirectory: true)
    }
}
