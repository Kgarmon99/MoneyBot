import SwiftUI
import AVFoundation

struct AudioCard: View {
    let audio: AudioContent
    @Environment(\.colorScheme) var colorScheme
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var isAnimating = false

    // Initialize audio session
    func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func initializePlayer(fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
            print("Could not find audio file: \(fileName)")
            return
        }

        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error initializing player: \(error)")
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Animated waveform container
            ZStack {
                // Glowing background
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [colorScheme == .dark ? Color.purple.opacity(0.3) : Color.purple.opacity(0.1), colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 20)

                // Waveform visualization
                HStack(spacing: 4) {
                    ForEach(0..<20) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.purple)
                            .frame(width: 3, height: isPlaying ? CGFloat.random(in: 10...50) : 20)
                            .animation(
                                Animation.easeInOut(duration: 0.5)
                                    .repeatForever()
                                    .delay(Double(index) * 0.05),
                                value: isPlaying
                            )
                    }
                }
                .frame(height: 60)
            }
            .frame(height: 120)
            .padding()

            VStack(spacing: 12) {
                Text(audio.title)
                    .font(.title2) // Increased font size for better readability
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .shadow(radius: 3) //added shadow

                Text(audio.speaker)
                    .font(.headline) //Slightly bigger font
                    .foregroundColor(.secondary)
                    .shadow(radius: 3)

                Text(audio.description)
                    .font(.subheadline) //Slightly bigger font
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .shadow(radius: 3)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 4)
                    }
                    .cornerRadius(2)
                }
                .frame(height: 4)
                .padding(.vertical)

                HStack {
                    Text("0:00")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(audio.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Play button
                Button(action: {
                    if let player = audioPlayer {
                        if player.isPlaying {
                            player.pause()
                            isPlaying = false
                        } else {
                            player.play()
                            isPlaying = true
                            // Update progress
                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                                if let player = audioPlayer {
                                    progress = player.currentTime / player.duration
                                    if !player.isPlaying {
                                        timer.invalidate()
                                    }
                                }
                            }
                        }
                    } else {
                        // Initialize audio player
                        let audioFileName = switch audio.speaker {
                        case "Michael Jordan": "Michael Jordan success"
                        case "Kobe Bryant": "KobeDream"
                        case "Warren Buffett": "Buffett(Customers)"
                        default: "SteveJobsThinkDifferent"
                        }

                        setupAudio()
                        initializePlayer(fileName: audioFileName)

                        audioPlayer?.play()
                        isPlaying = true
                        // Update progress
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                            if let player = audioPlayer {
                                progress = player.currentTime / player.duration
                                if !player.isPlaying {
                                    timer.invalidate()
                                    isPlaying = false
                                }
                            }
                        }
                    }
                }) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        )
                        .shadow(color: .purple.opacity(0.3), radius: 10)
                }
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .purple.opacity(0.2), radius: 15)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.5), .blue.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding()
        .onAppear {
            setupAudio()
            isAnimating = true
        }
        .onChange(of: audio.id) { _ in
            audioPlayer?.stop()
            audioPlayer = nil
            isPlaying = false
            progress = 0
        }
        .onDisappear {
            audioPlayer?.stop()
            audioPlayer = nil
            isPlaying = false
            progress = 0

            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
        }
    }
}