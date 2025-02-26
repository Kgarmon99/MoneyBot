
import Foundation

struct AudioContent: Identifiable {
    let id = UUID()
    let title: String
    let speaker: String
    let duration: String
    let description: String
    let category: AudioCategory
}

enum AudioCategory: String, CaseIterable {
    case investing = "Investing"
    case entrepreneurship = "Entrepreneurship"
    case mindset = "Mindset"
    case crypto = "Crypto"
    case technology = "Technology"
}
