import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private init() {}

    private var audioPlayer: AVAudioPlayer?

    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.volume = 0.25
        audioPlayer?.play()
    }
}
