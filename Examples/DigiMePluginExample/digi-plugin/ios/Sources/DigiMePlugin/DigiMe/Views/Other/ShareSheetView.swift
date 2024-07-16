//
//  ShareSheetView.swift
//  DigiMeSDKExample
//
//  Created on 26/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
    let shareItems: [Any]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheetView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheetView>) {
    }
}
