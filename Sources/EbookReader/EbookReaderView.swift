//
//  EbookView.swift
//  iOS Epub Reader
//
//  Created by Daniel Carvajal on 13-11-22.
//

import Bookbinder
import SwiftUI

public struct EbookReaderView: View {
    private let ebookManager = EbookReaderManager.shared
    @State private var viewHeight: CGFloat = 0
    @State private var isLoadingBook: Bool = true
    @State private var percentageScrolled: CGFloat = 0
    @Environment(\.scenePhase) private var scenePhase

    public init() {}

    public var body: some View {
        content
            .onChange(of: scenePhase) { newValue in
                switch newValue {
                case .background:
                    ebookManager.savePagesOffset()
                default:
                    break
                }
            }
            .onReceive(ebookManager.isLoadingBook) { newValue in
                isLoadingBook = newValue
            }
            .onReceive(ebookManager.percentageScrolled) { newValue in
                percentageScrolled = newValue
            }
            .onDisappear {
                ebookManager.savePagesOffset()
                ebookManager.resetState()
            }
    }
}

private extension EbookReaderView {
    var content: some View {
        ebookReaderView
            .opacity(isLoadingBook || ebookManager.book == nil ? 0 : 1)
            .animation(.default, value: isLoadingBook)
            .overlay(emptyState)
    }

    @ViewBuilder
    var emptyState: some View {
        if isLoadingBook {
            ProgressView()
        } else if ebookManager.book == nil {
            Text("No book available to read :|")
                .padding()
                .background(Color.white.cornerRadius(10))
        }
    }

    var ebookReaderView: some View {
        HStack(alignment: .top, spacing: 0) {
            if ebookManager.config.indicatorType == .custom {
                Color.clear
                    .frame(width: 10)
            }
            ebookReaderWrapper
            if ebookManager.config.indicatorType == .custom {
                customScrollIndicatorView
            }
        }
        .background(heightReader)
    }

    @ViewBuilder
    var heightReader: some View {
        if ebookManager.config.indicatorType == .custom {
            GeometryReader { proxy in
                let height = proxy.size.height
                Color.clear
                    .onAppear {
                        self.viewHeight = height
                    }
                    .onChange(of: height) { newValue in
                        self.viewHeight = newValue
                    }
            }
        }
    }

    var customScrollIndicatorView: some View {
        Color(ebookManager.config.indicatorColor)
            .frame(width: 10, height: getOffsetHeight())
            .cornerRadius(5, corners: [.bottomLeft, .bottomRight])
            .animation(.default.speed(1.5), value: getOffsetHeight())
    }

    var ebookReaderWrapper: some View {
        WKWebViewWrapper()
    }
}

extension EbookReaderView {
    func getOffsetHeight() -> CGFloat {
        let offsetHeight = percentageScrolled * viewHeight
        return offsetHeight.clamped(to: 0 ... viewHeight)
    }
}
