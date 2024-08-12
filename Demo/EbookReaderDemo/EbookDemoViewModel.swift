//
//  EbookDemoView.swift
//  EbookReaderDemo
//
//  Created by Daniel Carvajal on 19-11-22.
//

import EbookReader
import Foundation
import UIKit

class EbookDemoViewModel: ObservableObject {
    private let ebookManager: EbookReaderManager
    private let julietaBook = Bundle.main.url(forResource: "julieta", withExtension: "epub")!
    private let aliceBook = Bundle.main.url(forResource: "alice", withExtension: "epub")!

    init(ebookManager: EbookReaderManager = EbookReaderManager.shared) {
        let configuration = EbookReaderViewConfiguration(fontSize: 20,
                                                fontColor: .white,
                                                backgroundColor: .black,
                                                indicatorType: .custom,
                                                indicatorColor: .yellow)
        self.ebookManager = ebookManager
        self.ebookManager.set(configuration: configuration)
    }

    func setBook() {
        ebookManager.loadBook(from: aliceBook)
    }

    func ebookGoForward() {
        ebookManager.goForward()
    }

    func ebookGoBack() {
        ebookManager.goBack()
    }

    func ebookScrollUp() {
        ebookManager.scrollUp()
    }

    func ebookScrollDown() {
        ebookManager.scrollDown()
    }
}
