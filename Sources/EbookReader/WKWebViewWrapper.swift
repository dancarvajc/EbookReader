//
//  WKWebViewWrapper.swift
//
//
//  Created by Daniel Carvajal on 18-10-23.
//

import SwiftUI
import WebKit

public struct WKWebViewWrapper: UIViewRepresentable {
    public func makeUIView(context _: Context) -> WKWebView {
        let wkWebView = setupWKWebView()
        wkWebView.navigationDelegate = EbookReaderManager.shared
        wkWebView.scrollView.delegate = EbookReaderManager.shared
        EbookReaderManager.shared.wkWebView = wkWebView
        return wkWebView
    }

    public func updateUIView(_: WKWebView, context _: Context) {}

    private func setupWKWebView() -> WKWebView {
        let preferences = WKPreferences()
        preferences.minimumFontSize = EbookReaderManager.shared.config.fontSize

        // Set font color and also img and view adjust for WKWebView component
        let userContentController = WKUserContentController()
        let fontColorScript = WKUserScript(source: EbookReaderManager.shared.config.fontColor, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let imgAdjustScript = WKUserScript(source: K.JavaScriptCode.imgAdjust, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let viewAdjustScript = WKUserScript(source: K.JavaScriptCode.viewAdjust, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let transparentScript = WKUserScript(source: K.JavaScriptCode.transparentBackground, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        userContentController.addUserScript(fontColorScript)
        userContentController.addUserScript(imgAdjustScript)
        userContentController.addUserScript(viewAdjustScript)
        userContentController.addUserScript(transparentScript)

        let pref = WKWebpagePreferences()
        pref.preferredContentMode = .mobile

        let webConfig = WKWebViewConfiguration()
        webConfig.preferences = preferences
        webConfig.userContentController = userContentController
        webConfig.defaultWebpagePreferences = pref

        let wkwebview = WKWebView(frame: .zero, configuration: webConfig)
        wkwebview.isOpaque = false
        wkwebview.backgroundColor = EbookReaderManager.shared.config.backgroundColor

        // Scroll config
        wkwebview.scrollView.showsVerticalScrollIndicator = EbookReaderManager.shared.config.indicatorType == .native
        wkwebview.scrollView.showsHorizontalScrollIndicator = false

        return wkwebview
    }
}
