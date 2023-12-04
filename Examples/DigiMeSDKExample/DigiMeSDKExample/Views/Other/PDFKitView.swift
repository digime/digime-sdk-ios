//
//  PDFKitView.swift
//  DigiMeSDKExample
//
//  Created on 23/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import PDFKit
import SwiftUI

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(data: data)
    }
    
    static func isPDF(data: Data) -> Bool {
        guard data.count > 4 else {
            return false
        }
        
        // '%PDF' in ASCII
        let pdfHeader: [UInt8] = [0x25, 0x50, 0x44, 0x46]
        
        var dataHeader = [UInt8](repeating: 0, count: 4)
        data.copyBytes(to: &dataHeader, count: 4)
        
        return dataHeader == pdfHeader
    }
}
