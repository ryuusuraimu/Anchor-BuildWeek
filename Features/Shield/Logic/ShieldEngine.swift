import AVFoundation
import Combine
import MediaPlayer
import SwiftUI
import UIKit

@MainActor
class ShieldEngine: NSObject, ObservableObject, @preconcurrency AVSpeechSynthesizerDelegate,
  @preconcurrency AVAudioPlayerDelegate
{
  enum CardState: CaseIterable {
    case situation
    case doAction
    case dontAction
    case safety
  }

  @Published var currentCard: CardState = .situation
  @Published var isAutoCycling = false
  @Published var isVoiceEnabled = false
  @Published var isSpeaking = false

  private let synthesizer = AVSpeechSynthesizer()
  private let activationFeedback = UIImpactFeedbackGenerator(style: .soft)
  private var cycleTimer: Timer?
  private var config: ShieldConfig

  // Lock Screen audio session used to keep Now Playing active
  private var lockScreenAudioPlayer: AVAudioPlayer?
  private var preparedSpeechPlayer: AVAudioPlayer?

  // Settings snapshot
  private var cycleInterval: Double = 5.0

  init(config: ShieldConfig) {
    self.config = config
    super.init()
    synthesizer.delegate = self
    // Setup Remote Controls for Lock Screen Now Playing (once per instance)
    setupRemoteTransportControls()
  }

  func start(
    speechEnabled: Bool, hapticsEnabled: Bool, autoCycleEnabled: Bool, cycleInterval: Double
  ) {

    // Setup Audio Session explicitly when starting
    UIApplication.shared.beginReceivingRemoteControlEvents()
    configureAudioSession()

    // Start the Lock Screen audio session so Now Playing can appear
    playLockScreenAudio()

    self.cycleInterval = cycleInterval

    // Reset Voice to OFF by default (User requirement)
    self.isVoiceEnabled = false

    // Step 2: Haptic confirmation if enabled
    if hapticsEnabled {
      activationFeedback.prepare()
      activationFeedback.impactOccurred(intensity: 0.65)
    }

    // Step 3: Start auto-cycle if enabled
    if autoCycleEnabled {
      startAutoCycle()
    }
    updateNowPlayingInfo()
    // iOS can ignore NowPlaying updates immediately after session activation; retry shortly.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
      self?.updateNowPlayingInfo()
    }
  }

  func stop() {
    stopAutoCycle()

    // Stop Shield audio and speech
    stopVoicePlayback()
    lockScreenAudioPlayer?.stop()
    lockScreenAudioPlayer = nil

    UIApplication.shared.endReceivingRemoteControlEvents()
    do {
      try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    } catch {
    }

    isVoiceEnabled = false
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
  }

  func nextCard() {
    withAnimation(.easeInOut(duration: 0.55)) {
      switch currentCard {
      case .situation: currentCard = .doAction
      case .doAction: currentCard = .dontAction
      case .dontAction: currentCard = .safety
      case .safety: currentCard = .situation
      }
    }
    updateNowPlayingInfo()
  }

  func previousCard() {
    withAnimation(.easeInOut(duration: 0.55)) {
      switch currentCard {
      case .situation: currentCard = .safety
      case .doAction: currentCard = .situation
      case .dontAction: currentCard = .doAction
      case .safety: currentCard = .dontAction
      }
    }
    updateNowPlayingInfo()
  }

  func speak(
    text: String,
    language: String = Locale.preferredLanguages.first ?? "en",
    preparedAudioURL: URL? = nil
  ) {
    guard !text.isEmpty, isVoiceEnabled else { return }

    stopVoicePlayback()

    if let preparedAudioURL, playPreparedSpeech(from: preparedAudioURL) {
      return
    }

    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: language)
    utterance.rate = 0.5  // Slower for clarity

    isSpeaking = true
    synthesizer.speak(utterance)
  }

  func toggleVoice(_ enabled: Bool) {
    isVoiceEnabled = enabled
    if !enabled {
      stopVoicePlayback()
    }
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didFinish utterance: AVSpeechUtterance
  ) {
    isSpeaking = false
    isVoiceEnabled = false
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didCancel utterance: AVSpeechUtterance
  ) {
    isSpeaking = false
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    guard player === preparedSpeechPlayer else { return }
    preparedSpeechPlayer = nil
    isSpeaking = false
    isVoiceEnabled = false
  }

  private func playPreparedSpeech(from url: URL) -> Bool {
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.delegate = self
      player.prepareToPlay()
      guard player.play() else { return false }
      preparedSpeechPlayer = player
      isSpeaking = true
      return true
    } catch {
      return false
    }
  }

  private func stopVoicePlayback() {
    synthesizer.stopSpeaking(at: .immediate)
    preparedSpeechPlayer?.stop()
    preparedSpeechPlayer = nil
    isSpeaking = false
  }

  private func startAutoCycle() {
    isAutoCycling = true
    cycleTimer?.invalidate()
    cycleTimer = Timer.scheduledTimer(withTimeInterval: cycleInterval, repeats: true) {
      [weak self] _ in
      Task { @MainActor in
        self?.nextCard()
      }
    }
  }

  private func stopAutoCycle() {
    cycleTimer?.invalidate()
    cycleTimer = nil
  }
  private func configureAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
    }
  }

  private func playLockScreenAudio() {
    // Build a valid WAV file in memory (1 second of silence)
    // AVAudioPlayer requires properly formatted audio data, not raw bytes.
    let sampleRate: UInt32 = 44100
    let numChannels: UInt16 = 1
    let bitsPerSample: UInt16 = 16
    let numSamples: UInt32 = sampleRate  // 1 second
    let dataSize: UInt32 = numSamples * UInt32(numChannels) * UInt32(bitsPerSample / 8)
    let byteRate: UInt32 = sampleRate * UInt32(numChannels) * UInt32(bitsPerSample / 8)
    let blockAlign: UInt16 = numChannels * (bitsPerSample / 8)

    var wavData = Data()

    // RIFF header
    wavData.append(contentsOf: [0x52, 0x49, 0x46, 0x46])  // "RIFF"
    var chunkSize = 36 + dataSize
    wavData.append(Data(bytes: &chunkSize, count: 4))
    wavData.append(contentsOf: [0x57, 0x41, 0x56, 0x45])  // "WAVE"

    // fmt sub-chunk
    wavData.append(contentsOf: [0x66, 0x6D, 0x74, 0x20])  // "fmt "
    var subchunk1Size: UInt32 = 16
    wavData.append(Data(bytes: &subchunk1Size, count: 4))
    var audioFormat: UInt16 = 1  // PCM
    wavData.append(Data(bytes: &audioFormat, count: 2))
    var channels = numChannels
    wavData.append(Data(bytes: &channels, count: 2))
    var rate = sampleRate
    wavData.append(Data(bytes: &rate, count: 4))
    var bRate = byteRate
    wavData.append(Data(bytes: &bRate, count: 4))
    var bAlign = blockAlign
    wavData.append(Data(bytes: &bAlign, count: 2))
    var bps = bitsPerSample
    wavData.append(Data(bytes: &bps, count: 2))

    // data sub-chunk
    wavData.append(contentsOf: [0x64, 0x61, 0x74, 0x61])  // "data"
    var dSize = dataSize
    wavData.append(Data(bytes: &dSize, count: 4))
    // Append silence (zeros)
    wavData.append(Data(count: Int(dataSize)))

    do {
      // Prefer file-backed playback on device for maximum reliability.
      let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(
        "anchor_silence.wav")
      try wavData.write(to: tmpURL, options: .atomic)

      do {
        lockScreenAudioPlayer = try AVAudioPlayer(contentsOf: tmpURL)
      } catch {
        // Fallback: in-memory playback
        lockScreenAudioPlayer = try AVAudioPlayer(data: wavData)
      }

      lockScreenAudioPlayer?.numberOfLoops = -1  // Infinite loop
      lockScreenAudioPlayer?.volume = 0.01  // Low-volume support audio for Now Playing
      lockScreenAudioPlayer?.prepareToPlay()
      lockScreenAudioPlayer?.play()
    } catch {
    }
  }

  // MARK: - Lock Screen Now Playing (MPNowPlayingInfoCenter)

  private func setupRemoteTransportControls() {
    let commandCenter = MPRemoteCommandCenter.shared()

    // Enable skip controls for Shield card navigation
    commandCenter.nextTrackCommand.isEnabled = true
    commandCenter.nextTrackCommand.addTarget { [weak self] _ in
      Task { @MainActor in
        self?.nextCard()
      }
      return .success
    }
    commandCenter.previousTrackCommand.isEnabled = true
    commandCenter.previousTrackCommand.addTarget { [weak self] _ in
      Task { @MainActor in
        self?.previousCard()
      }
      return .success
    }

    // Play/pause: keep enabled with no-op handlers (required for Now Playing status)
    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget { _ in .success }
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget { _ in .success }

    // Disable unused commands to simplify the UI
    commandCenter.changePlaybackRateCommand.isEnabled = false
    commandCenter.seekForwardCommand.isEnabled = false
    commandCenter.seekBackwardCommand.isEnabled = false
    commandCenter.skipForwardCommand.isEnabled = false
    commandCenter.skipBackwardCommand.isEnabled = false
  }

  private func updateNowPlayingInfo() {
    // Ensure this runs on the main queue
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      var nowPlayingInfo = [String: Any]()
      let content = self.getContentForLockScreen()

      // Ensure the Lock Screen audio session is actually running, otherwise iOS may drop Now Playing.
      if self.lockScreenAudioPlayer?.isPlaying != true {
        self.playLockScreenAudio()
      }

      nowPlayingInfo[MPMediaItemPropertyTitle] = content.title
      nowPlayingInfo[MPMediaItemPropertyArtist] = content.text

      // Generate rich card-style artwork for the lock screen
      let artworkImage = self.renderLockScreenArtwork(content: content)
      nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size)
      { _ in artworkImage }

      // These fields help iOS treat this as an active "Now Playing" session.
      nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
      nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] =
        self.lockScreenAudioPlayer?.currentTime ?? 0
      if let duration = self.lockScreenAudioPlayer?.duration {
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
      }

      MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
      MPNowPlayingInfoCenter.default().playbackState = .playing
    }
  }

  private func renderLockScreenArtwork(
    content: (title: String, text: String, icon: String, color: UIColor)
  ) -> UIImage {
    let size = CGSize(width: 600, height: 600)
    let renderer = UIGraphicsImageRenderer(size: size)

    return renderer.image { ctx in
      let cgContext = ctx.cgContext

      // --- Gradient Background ---
      let baseColor = content.color
      var h: CGFloat = 0
      var s: CGFloat = 0
      var b: CGFloat = 0
      var a: CGFloat = 0
      baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
      let darkColor = UIColor(
        hue: h, saturation: min(s + 0.1, 1.0),
        brightness: max(b - 0.3, 0.05), alpha: 1.0)

      let colors = [darkColor.cgColor, baseColor.cgColor] as CFArray
      if let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0])
      {
        cgContext.drawLinearGradient(
          gradient,
          start: CGPoint(x: 0, y: 0),
          end: CGPoint(x: size.width, y: size.height),
          options: []
        )
      }

      // --- Icon + Title row at top ---
      let iconConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
      if let icon = UIImage(systemName: content.icon, withConfiguration: iconConfig)?
        .withTintColor(.white.withAlphaComponent(0.9), renderingMode: .alwaysOriginal)
      {
        let titleText = content.title
        let titleAttrs: [NSAttributedString.Key: Any] = [
          .font: UIFont.systemFont(ofSize: 20, weight: .heavy),
          .foregroundColor: UIColor.white.withAlphaComponent(0.7),
          .kern: 3.0,
        ]
        let titleSize = (titleText as NSString).size(withAttributes: titleAttrs)
        let iconSize = icon.size
        let gap: CGFloat = 10
        let totalW = iconSize.width + gap + titleSize.width
        let startX = (size.width - totalW) / 2
        let rowY: CGFloat = 40

        icon.draw(at: CGPoint(x: startX, y: rowY))
        (titleText as NSString).draw(
          at: CGPoint(
            x: startX + iconSize.width + gap, y: rowY + (iconSize.height - titleSize.height) / 2),
          withAttributes: titleAttrs)
      }

      // --- QR Code (center) ---
      let qrPayload = self.buildQRPayload()
      let qrSide: CGFloat = 300
      let qrX = (size.width - qrSide) / 2
      let qrY: CGFloat = 100

      // White rounded-rect background behind QR
      let qrBgRect = CGRect(x: qrX - 20, y: qrY - 20, width: qrSide + 40, height: qrSide + 40)
      let qrBgPath = UIBezierPath(roundedRect: qrBgRect, cornerRadius: 20)
      UIColor.white.setFill()
      qrBgPath.fill()

      if let qrImage = QRGenerator.generate(from: qrPayload, scale: 10) {
        qrImage.draw(in: CGRect(x: qrX, y: qrY, width: qrSide, height: qrSide))
      }

      // --- "Scan to read" label below QR ---
      let scanStyle = NSMutableParagraphStyle()
      scanStyle.alignment = .center
      let scanAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 15, weight: .medium),
        .foregroundColor: UIColor.white.withAlphaComponent(0.5),
        .paragraphStyle: scanStyle,
      ]
      ("SCAN TO READ" as NSString).draw(
        in: CGRect(x: 0, y: qrY + qrSide + 30, width: size.width, height: 22),
        withAttributes: scanAttrs)

      // --- Body Text ---
      let bodyStyle = NSMutableParagraphStyle()
      bodyStyle.alignment = .center
      bodyStyle.lineSpacing = 4
      let bodyAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: UIColor.white,
        .paragraphStyle: bodyStyle,
      ]
      let bodyString = NSString(string: content.text)
      let bodyRect = CGRect(x: 40, y: qrY + qrSide + 60, width: size.width - 80, height: 140)
      bodyString.draw(in: bodyRect, withAttributes: bodyAttrs)

      // --- Bottom branding ---
      let brandStyle = NSMutableParagraphStyle()
      brandStyle.alignment = .center
      let brandAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 13, weight: .medium),
        .foregroundColor: UIColor.white.withAlphaComponent(0.2),
        .paragraphStyle: brandStyle,
        .kern: 2.0,
      ]
      ("ANCHOR" as NSString).draw(
        in: CGRect(x: 0, y: size.height - 36, width: size.width, height: 20),
        withAttributes: brandAttrs)
    }
  }

  private func buildQRPayload() -> String {
    let payload = ShieldQRPayload(
      situation: config.situationText,
      doText: config.doText,
      dontText: config.dontText,
      safetyText: config.safetyText
    )
    return payload.asPlainText(includePhone: false)
  }

  private func getContentForLockScreen() -> (
    title: String, text: String, icon: String, color: UIColor
  ) {
    switch currentCard {
    case .situation:
      return (
        "SITUATION", config.situationText, "exclamationmark.triangle.fill",
        UIColor(red: 0.85, green: 0.45, blue: 0.35, alpha: 1.0)
      )
    case .doAction:
      return (
        "PLEASE DO", config.doText, "checkmark.circle.fill",
        UIColor(red: 0.25, green: 0.55, blue: 0.45, alpha: 1.0)
      )
    case .dontAction:
      return (
        "PLEASE DON'T", config.dontText, "hand.raised.fill",
        UIColor(red: 0.55, green: 0.35, blue: 0.60, alpha: 1.0)
      )
    case .safety:
      return (
        "SAFETY", config.safetyText ?? "", "cross.case.fill",
        UIColor(red: 0.30, green: 0.50, blue: 0.70, alpha: 1.0)
      )
    }
  }
}
