//
//  EbookDemoView.swift
//  EbookReaderDemo
//
//  Created by Daniel Carvajal on 19-11-22.
//

import EbookReader
import SwiftUI

struct EbookDemoView: View {
    @StateObject private var viewModel = EbookDemoViewModel()

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Button("", systemImage: "arrow.left") {
                        viewModel.ebookGoBack()
                    }
                    Button("", systemImage: "arrow.right") {
                        viewModel.ebookGoForward()
                    }
                }
                HStack {
                    Button("", systemImage: "arrow.up") {
                        viewModel.ebookScrollUp()
                    }
                    Button("", systemImage: "arrow.down") {
                        viewModel.ebookScrollDown()
                    }
                }
            }.padding(.bottom)

            EbookReaderView()
        }
        .onAppear {
            viewModel.setBook()
        }
    }
}

struct TesView_Previews: PreviewProvider {
    static var previews: some View {
        EbookDemoView()
    }
}
