//
//  EbookReaderManager.swift
//  iOS Epub Reader
//
//  Created by Daniel Carvajal on 13-11-22.
//

import Bookbinder
import Combine
import WebKit

public final class EbookReaderManager: NSObject {

    // MARK: - Public properties

    public var percentageScrolled = PassthroughSubject<CGFloat, Never>()
    public var isLoadingBook = PassthroughSubject<Bool, Never>()
    public var config: EbookReaderViewConfiguration = .defaultConfig
    public var book: EPUBBook?

    // MARK: - Private properties

    private var currentPageIndex: Int = 0
    private var shouldEvaluateJSCode: Bool = true
    private var shouldUpdateScrollbar: Bool = false
    private var pagesOffset: [CGFloat] = []
    private let bookbinder = Bookbinder(
        configuration: BookbinderConfiguration(rootURL: K.SaveDirectory.fullURL))
    private var isBookInitialized: Bool {
        return book != nil
    }
    weak var wkWebView: WKWebView?

    // MARK: - Initialization

    public static let shared = EbookReaderManager()
    override private init() {}


    // MARK: - Public methods

    /// Load the book, parse it and load the pages offset.
    /// - Parameter bookURL:The book URL to load.
    public func loadBook(from bookURL: URL) {
        if isBookInitialized {
            resetState()
        }
        guard let book = bookbinder.bindBook(at: bookURL) else {
            isLoadingBook.send(false)
            return
        }
        self.book = book
        loadPagesOffset()
        reloadPage()
    }

    /// Parse the book and returns it
    public func processBook(url: URL) -> EPUBBook? {
        return bookbinder.bindBook(at: url)
    }

    /// Navigates to the forward page in the pages book.
    public func goForward() {
        guard isBookInitialized else { return }
        guard let count = book?.pages?.count, currentPageIndex + 1 < count else { return }
        currentPageIndex += 1
        shouldEvaluateJSCode = true
        reloadPage()
    }

    /// Navigates to the back page in the pages book.
    public func goBack() {
        guard isBookInitialized else { return }
        guard currentPageIndex - 1 >= 0 else { return }
        currentPageIndex -= 1
        shouldEvaluateJSCode = true
        reloadPage()
    }

    /// Scrolls up a portion of the current page.
    public func scrollUp() {
        guard isBookInitialized, let wkWebView else { return }
        let scrollCurrentOffset = wkWebView.scrollView.contentOffset.y
        let scrollFrame = wkWebView.scrollView.frame.height
        let nextOffset = scrollCurrentOffset - scrollFrame / 2.5

        wkWebView.scrollView.setContentOffset(CGPoint(x: 0, y: nextOffset), animated: true)
        wkWebView.scrollView.flashScrollIndicators()
    }

    /// Scrolls down a portion of the current page.
    public func scrollDown() {
        guard isBookInitialized, let wkWebView else { return }
        let scrollCurrentOffset = wkWebView.scrollView.contentOffset.y
        let scrollFrame = wkWebView.scrollView.frame.height
        let nextOffset = scrollCurrentOffset + scrollFrame / 2.5

        wkWebView.scrollView.setContentOffset(CGPoint(x: 0, y: nextOffset), animated: true)
        wkWebView.scrollView.flashScrollIndicators()
    }

    public func set(configuration: EbookReaderViewConfiguration) {
        config = configuration
    }

    /// Reset to the initial state. Used when the book is closed,
    public func resetState() {
        book = nil
        shouldUpdateScrollbar = false
        shouldEvaluateJSCode = true
        isLoadingBook.send(true)
        currentPageIndex = 0
        pagesOffset = []
    }

    /// Save the current state of the pages offset to UserDefaults.
    public func savePagesOffset() {
        if let uniqueID = book?.uniqueID {
            UserDefaults.standard.set(pagesOffset, forKey: uniqueID + "pagesOffset")
            UserDefaults.standard.set(currentPageIndex, forKey: uniqueID + "currentPageIndex")
        }
    }

    // MARK: - Private methods

    func reloadPage() {
        guard isBookInitialized else { return }
        guard let book, let page = book.pages?[currentPageIndex] else { return }
        wkWebView?.loadFileURL(page, allowingReadAccessTo: book.baseURL)
    }

    /// Load  the current state of the pages offset to UserDefaults.
    private func loadPagesOffset() {
        if let uniqueID = book?.uniqueID, let pagesOffset = UserDefaults.standard.array(forKey: uniqueID + "pagesOffset") as? [CGFloat] {
            currentPageIndex = UserDefaults.standard.integer(forKey: uniqueID + "currentPageIndex")
            self.pagesOffset = pagesOffset
        } else if let pagesNumber = book?.pages?.count  {
            pagesOffset = Array(repeating: CGFloat(0), count: pagesNumber)
        }
    }
}

// MARK: - WKWebView delegate

extension EbookReaderManager: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        DispatchQueue.main.async { [self] in
            guard shouldEvaluateJSCode else { return }
            shouldEvaluateJSCode = false
            let savedOffset = pagesOffset[currentPageIndex]

            webView.evaluateJavaScript(K.JavaScriptCode.scrollTo(savedOffset))
            pagesOffset[currentPageIndex] = webView.scrollView.contentOffset.y
            percentageScrolled.send(calculatePercentageScrolled(webView.scrollView))
            isLoadingBook.send(false)
            shouldUpdateScrollbar = true
        }
    }
}

// MARK: - UIScrollView delegate

extension EbookReaderManager: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldUpdateScrollbar else { return }
        let isBottomReached = scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
        let isTopReached = scrollView.contentOffset.y <= 0
        // Disable scroll beyond bottom content size
        if isBottomReached {
            scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.frame.size.height
        }
        if isTopReached {
            scrollView.contentOffset.y = 0
        }
        // Change scrollbar color
        let scrollBarIndex = scrollView.subviews.count - 1
        if scrollBarIndex >= 0, let scrollBar = scrollView.subviews[scrollBarIndex].subviews.first {
            scrollBar.backgroundColor = config.indicatorColor
        }

        pagesOffset[currentPageIndex] = scrollView.contentOffset.y
        percentageScrolled.send(calculatePercentageScrolled(scrollView))
    }

    private func calculatePercentageScrolled(_ scrollView: UIScrollView) -> CGFloat {
        let currentPercentageScrolled = scrollView.contentOffset.y / (scrollView.contentSize.height - scrollView.frame.size.height)
        let percentageScrolled = currentPercentageScrolled.isNaN ? 0 : abs(currentPercentageScrolled)
        return percentageScrolled
    }
}
