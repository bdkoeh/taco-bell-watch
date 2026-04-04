import AVFoundation
import WatchKit

class SoundPlayer {
    private var player: AVAudioPlayer?
    private var lastPlayTime: Date = .distantPast
    private let cooldown: TimeInterval = 2.0

    init() {
        guard let url = Bundle.main.url(forResource: "taco_bell_bong", withExtension: "wav") else {
            print("Sound file not found")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print("Failed to load sound: \(error)")
        }
    }

    func play() {
        guard Date().timeIntervalSince(lastPlayTime) >= cooldown else { return }
        lastPlayTime = Date()
        player?.currentTime = 0
        player?.play()
        WKInterfaceDevice.current().play(.success)
    }
}
