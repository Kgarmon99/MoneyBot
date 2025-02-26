import SwiftUI

struct ChatbotView: View {
    @StateObject private var moneybotService = MoneybotService.shared
    
    var body: some View {
        // We'll simply use our existing MoneybotChatView which already has OpenAI integration
        MoneybotChatView()
    }
}

//
//  ChatbotWebview.swift
//  Moneybot
//
//  Created by Kahlil Garmon on 2/13/25.
//  Updated to use native OpenAI integration
//
