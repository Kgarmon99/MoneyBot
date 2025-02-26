import SwiftUI
import WebKit

struct ChatbotView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <script async type="module" src="https://interfaces.zapier.com/assets/web-components/zapier-interfaces/zapier-interfaces.esm.js"></script>
        </head>
        <body>
            <zapier-interfaces-chatbot-embed 
                is-popup="true" 
                chatbot-id="cm08ttupf0005yvzh163ldfcu" 
                height="600px" 
                width="400px">
            </zapier-interfaces-chatbot-embed>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlString, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
//
//  ChatbotWebview.swift
//  Moneybot
//
//  Created by Kahlil Garmon on 2/13/25.
//

