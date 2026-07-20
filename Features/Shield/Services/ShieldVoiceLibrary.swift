import AVFoundation
import CryptoKit
import Foundation
import Observation

@Observable
@MainActor
final class ShieldVoiceLibrary: NSObject, @preconcurrency AVAudioPlayerDelegate {
  static let shared = ShieldVoiceLibrary()

  enum VoiceError: LocalizedError {
    case proxyNotConfigured
    case proxyUnavailable
    case quotaExhausted
    case invalidResponse
    case requestFailed

    var errorDescription: String? {
      switch self {
      case .proxyNotConfigured:
        return "Voice generation is not configured for this build."
      case .proxyUnavailable:
        return
          "The voice service cannot be reached. Start VoiceProxy on the Mac for Simulator, "
          + "or use a reachable HTTPS proxy on iPhone. Shield will use the iOS voice until "
          + "a saved reading is ready."
      case .quotaExhausted:
        return
          "OpenAI voice quota is unavailable right now. Add API credits or continue "
          + "with the iOS voice."
      case .invalidResponse:
        return "The voice service returned an unreadable response."
      case .requestFailed:
        return "Voice generation is unavailable right now. Try again when you are online."
      }
    }
  }

  private(set) var isGenerating = false
  private(set) var previewingVoice: OpenAIVoice?
  private(set) var errorMessage: String?

  private var previewPlayer: AVAudioPlayer?
  private let fileManager = FileManager.default

  private override init() {
    super.init()
  }

  func cachedSpeechURL(text: String, voice: OpenAIVoice) -> URL? {
    let url = cacheDirectory.appendingPathComponent(cacheFileName(text: text, voice: voice))
    return fileManager.fileExists(atPath: url.path) ? url : nil
  }

  func hasPreparedShieldVoice(config: ShieldConfig, voice: OpenAIVoice) -> Bool {
    cachedSpeechURL(text: ShieldSpeechText.make(from: config), voice: voice) != nil
  }

  @discardableResult
  func generateShieldVoice(config: ShieldConfig, voice: OpenAIVoice) async throws -> URL {
    try await generate(text: ShieldSpeechText.make(from: config), voice: voice)
  }

  func preview(_ voice: OpenAIVoice) async throws {
    if previewingVoice == voice {
      stopPreview()
      return
    }

    stopPreview()
    let previewText = "I am safe. I need a quiet moment. Please give me space and speak softly."
    let url = try await generate(text: previewText, voice: voice)

    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
      try AVAudioSession.sharedInstance().setActive(true)
      let player = try AVAudioPlayer(contentsOf: url)
      player.delegate = self
      player.prepareToPlay()
      guard player.play() else { throw VoiceError.invalidResponse }
      previewPlayer = player
      previewingVoice = voice
    } catch let error as VoiceError {
      throw error
    } catch {
      throw VoiceError.invalidResponse
    }
  }

  func stopPreview() {
    previewPlayer?.stop()
    previewPlayer = nil
    previewingVoice = nil
  }

  func clearAllCachedAudio() {
    stopPreview()
    try? fileManager.removeItem(at: cacheDirectory)
    errorMessage = nil
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    previewPlayer = nil
    previewingVoice = nil
  }

  private func generate(text: String, voice: OpenAIVoice) async throws -> URL {
    if let cached = cachedSpeechURL(text: text, voice: voice) {
      errorMessage = nil
      return cached
    }

    guard let endpoint = Self.proxyEndpoint else {
      throw VoiceError.proxyNotConfigured
    }

    isGenerating = true
    errorMessage = nil
    defer { isGenerating = false }

    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.timeoutInterval = 60
    request.cachePolicy = .reloadIgnoringLocalCacheData
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
    request.httpBody = try JSONEncoder().encode(
      SpeechRequest(text: text, voice: voice.rawValue)
    )

    do {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.timeoutIntervalForRequest = 60
      configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
      let (data, response) = try await URLSession(configuration: configuration).data(for: request)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw VoiceError.requestFailed
      }

      guard httpResponse.statusCode == 200 else {
        if let proxyError = try? JSONDecoder().decode(ProxyError.self, from: data),
          proxyError.code == "insufficient_quota"
        {
          throw VoiceError.quotaExhausted
        }
        throw VoiceError.requestFailed
      }

      guard data.count > 128,
        httpResponse.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("audio/") == true
      else {
        throw VoiceError.invalidResponse
      }

      try fileManager.createDirectory(
        at: cacheDirectory,
        withIntermediateDirectories: true
      )
      var destination = cacheDirectory.appendingPathComponent(
        cacheFileName(text: text, voice: voice)
      )
      try data.write(to: destination, options: .atomic)
      var resourceValues = URLResourceValues()
      resourceValues.isExcludedFromBackup = true
      try? destination.setResourceValues(resourceValues)
      return destination
    } catch let error as VoiceError {
      errorMessage = error.localizedDescription
      throw error
    } catch let error as URLError {
      let voiceError: VoiceError
      switch error.code {
      case .cannotConnectToHost, .cannotFindHost, .networkConnectionLost, .timedOut:
        voiceError = .proxyUnavailable
      default:
        voiceError = .requestFailed
      }
      errorMessage = voiceError.localizedDescription
      throw voiceError
    } catch {
      let voiceError = VoiceError.requestFailed
      errorMessage = voiceError.localizedDescription
      throw voiceError
    }
  }

  private var cacheDirectory: URL {
    let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    return
      base
      .appendingPathComponent("Anchor", isDirectory: true)
      .appendingPathComponent("PreparedVoices", isDirectory: true)
  }

  private func cacheFileName(text: String, voice: OpenAIVoice) -> String {
    let source = "gpt-4o-mini-tts|\(voice.rawValue)|\(text)"
    let digest = SHA256.hash(data: Data(source.utf8))
    return digest.map { String(format: "%02x", $0) }.joined() + ".aac"
  }

  private static var proxyEndpoint: URL? {
    if let configured = Bundle.main.object(forInfoDictionaryKey: "AnchorVoiceProxyURL") as? String,
      let url = URL(string: configured),
      !configured.isEmpty
    {
      return url
    }

    #if DEBUG
      let arguments = ProcessInfo.processInfo.arguments
      if let index = arguments.firstIndex(of: "-voiceProxyURL"),
        arguments.indices.contains(index + 1),
        let url = URL(string: arguments[index + 1])
      {
        return url
      }
      return URL(string: "http://127.0.0.1:8787/v1/speech")
    #else
      return nil
    #endif
  }

  private struct SpeechRequest: Encodable {
    let text: String
    let voice: String
  }

  private struct ProxyError: Decodable {
    let code: String?
  }
}
