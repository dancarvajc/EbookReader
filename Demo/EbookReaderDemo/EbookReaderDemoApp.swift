//
//  EbookReaderDemoApp.swift
//  EbookReaderDemo
//
//  Created by Daniel Carvajal on 08-08-24.
//

import SwiftUI

@main
struct EbookReaderDemoApp: App {
    var body: some Scene {
        WindowGroup {
            EbookDemoView()
                .preferredColorScheme(.dark)
        }
    }
}
