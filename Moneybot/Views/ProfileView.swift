
import SwiftUI

struct ProfileView: View {
    @Binding var user: User
    @State private var showingSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Enhanced Profile Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .shadow(color: Color.green.opacity(0.3), radius: 10)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Level \(user.level)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Text("\(user.xp) XP")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("/")
                                .foregroundColor(.secondary)
                            
                            Text("200 XP")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Enhanced Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: geometry.size.width, height: 8)
                                .opacity(0.1)
                                .foregroundColor(.green)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: min(CGFloat(user.xp) / 200 * geometry.size.width, geometry.size.width), height: 8)
                                .foregroundColor(.green)
                                .animation(.spring(), value: user.xp)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 15)
                )
                .padding(.horizontal)
                
                // Enhanced Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    EnhancedStatBox(title: "Streak", value: "\(user.streak)", subtitle: "days", icon: "flame.fill", color: .orange)
                    EnhancedStatBox(title: "Goals", value: "\(user.activeGoals.count)", subtitle: "active", icon: "target", color: .blue)
                    EnhancedStatBox(title: "Level", value: "\(user.level)", subtitle: "current", icon: "star.fill", color: .yellow)
                    EnhancedStatBox(title: "XP", value: "\(user.xp)", subtitle: "points", icon: "bolt.fill", color: .green)
                }
                .padding(.horizontal)
                
                // Enhanced Achievements Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Achievements")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("\(user.achievements.filter { $0.unlocked }.count)/\(user.achievements.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(user.achievements) { achievement in
                                EnhancedAchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Enhanced Settings Button
                Button(action: { showingSettings = true }) {
                    HStack {
                        Image(systemName: "gear")
                            .font(.system(size: 20))
                        Text("Settings")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.green.opacity(0.3), radius: 10)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showingSettings) {
                    EnhancedSettingsView(user: $user)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Profile")
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct EnhancedStatBox: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

struct EnhancedAchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.unlocked ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 30))
                    .foregroundColor(achievement.unlocked ? .green : .gray)
            }
            
            Text(achievement.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if achievement.unlocked {
                Label("Unlocked", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .frame(width: 140, height: 180)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
        .opacity(achievement.unlocked ? 1 : 0.7)
    }
}

struct EnhancedSettingsView: View {
    @Binding var user: User
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Settings")) {
                    Toggle("Enable Notifications", isOn: Binding(
                        get: { user.notificationManager.notificationsEnabled },
                        set: { newValue in
                            user.notificationManager.notificationsEnabled = newValue
                            if newValue {
                                user.notificationManager.requestPermission()
                            }
                        }
                    ))
                }
                
                Section(header: Text("App Settings")) {
                    HStack {
                        Text("Theme")
                        Spacer()
                        Text("Light Mode")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: {}) {
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {}) {
                        Text("Terms of Service")
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}
