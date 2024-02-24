//
//  SVGView.swift
//  DigiMeSDKExample
//
//  Created on 22/02/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI
import WebKit

struct SVGWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.backgroundColor = .clear
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard 
                let data = data,
                error == nil else {
                
                return
            }

            let svgContent = String(data: data, encoding: .utf8) ?? ""
            let htmlString = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <style>
                    body, html { margin: 0; padding: 0; overflow: hidden; }
                    svg { width: 100% !important; height: auto !important; }
                </style>
            </head>
            <body>
                \(svgContent)
            </body>
            </html>
            """
            DispatchQueue.main.async {
                webView.loadHTMLString(htmlString, baseURL: self.url.deletingLastPathComponent())
            }
        }.resume()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SVGWebView

        init(_ webView: SVGWebView) {
            self.parent = webView
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        }
    }
}

struct SVGWebViewPreview: View {
    let svgURL = URL(string: "https://securedownloads.digi.me/static/development/discovery/services/nhs/icon.svg")!

    var body: some View {
        ZStack {
            Color.blue

            SVGWebView(url: svgURL)
                .frame(width: 50, height: 50)
        }

    }
}

#Preview {
    SVGWebViewPreview()
}
