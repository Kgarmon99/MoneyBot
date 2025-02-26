
import SwiftUI

struct VisualContent {
    let image: String
    let title: String
    let description: String
    let likes: Int = Int.random(in: 100...1000)
    let comments: Int = Int.random(in: 10...100)
    let timePosted: String = "\(Int.random(in: 1...23))h ago"
}

struct VisualCard: View {
    let index: Int
    let visualContent: [VisualContent]
    @State private var isLiked = false
    @State private var isSaved = false
    @State private var showComments = false
    
    var currentContent: VisualContent {
        visualContent[index]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image("new-moneybot-logo")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("Moneybot")
                        .font(.system(size: 14, weight: .semibold))
                    Text(currentContent.timePosted)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Image
            Image(currentContent.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipped()
            
            // Actions
            HStack(spacing: 20) {
                Button(action: { isLiked.toggle() }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .primary)
                        .font(.system(size: 22))
                }
                
                Button(action: { showComments.toggle() }) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 22))
                }
                
                Button(action: {}) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 22))
                }
                
                Spacer()
                
                Button(action: { isSaved.toggle() }) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 22))
                }
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Likes
            HStack {
                Text("\(currentContent.likes + (isLiked ? 1 : 0)) likes")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal)
            
            // Caption
            VStack(alignment: .leading, spacing: 4) {
                Text("Moneybot")
                    .font(.system(size: 14, weight: .semibold)) +
                Text(" \(currentContent.description)")
                    .font(.system(size: 14))
                
                Text("View all \(currentContent.comments) comments")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(0)
    }
}
