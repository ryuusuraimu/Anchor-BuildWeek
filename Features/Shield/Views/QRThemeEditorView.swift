import SwiftUI

struct QRThemeEditorView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var contactStore: EmergencyContactStore
  let config: ShieldConfig

  // State
  @State private var qrImage: UIImage? = nil
  @State private var selectedTheme: QRArtRenderer.Theme = .cloud
  @State private var isRegenerating = false

  var body: some View {
    ZStack {
      // Background (Dark)
      Color.black.ignoresSafeArea()

      VStack(spacing: 0) {
        // Header
        HStack {
          Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 32))
              .symbolRenderingMode(.hierarchical)
              .foregroundColor(.white.opacity(0.6))
          }
          Spacer()
          Text("QR Style")
            .font(DesignSystem.Fonts.headline())
            .foregroundColor(.white)
          Spacer()
          // Placeholder to balance
          Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)

        // Main Content
        ScrollView {
          VStack(spacing: 32) {

            // 1. Preview Area
            ZStack {
              if let image = qrImage {
                Image(uiImage: image)
                  .resizable()
                  .scaledToFit()
                  .frame(maxWidth: .infinity)
                  .cornerRadius(24)
                  .shadow(color: Color.white.opacity(0.1), radius: 20, x: 0, y: 10)
                  .overlay(
                    RoundedRectangle(cornerRadius: 24)
                      .stroke(Color.white.opacity(0.1), lineWidth: 1)
                  )
              } else {
                ProgressView()
                  .frame(width: 300, height: 500)
                  .background(Color.white.opacity(0.1))
                  .cornerRadius(24)
              }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)

            // 2. Controls
            VStack(spacing: 24) {

              // Theme Picker
              VStack(alignment: .leading, spacing: 12) {
                Text("Theme")
                  .font(DesignSystem.Fonts.caption())
                  .foregroundColor(.white.opacity(0.6))
                  .padding(.horizontal, 4)

                ScrollView(.horizontal, showsIndicators: false) {
                  HStack(spacing: 12) {
                    ForEach(QRArtRenderer.Theme.allCases) { theme in
                      Button(action: {
                        selectedTheme = theme
                        regenerateQR()
                      }) {
                        Text(theme.rawValue)
                          .font(DesignSystem.Fonts.body())
                          .padding(.horizontal, 16)
                          .padding(.vertical, 8)
                          .background(
                            selectedTheme == theme ? Color.white : Color.white.opacity(0.1)
                          )
                          .foregroundColor(selectedTheme == theme ? .black : .white)
                          .cornerRadius(20)
                      }
                    }
                  }
                  .padding(.horizontal, 4)
                }
              }
              .padding(.horizontal, 24)

              // Actions
              HStack(spacing: 16) {
                // Regenerate
                Button(action: {
                  regenerateQR()
                }) {
                  HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Regenerate")
                  }
                  .font(DesignSystem.Fonts.body())
                  .fontWeight(.medium)
                  .foregroundColor(.white)
                  .padding(.vertical, 16)
                  .frame(maxWidth: .infinity)
                  .background(Color.white.opacity(0.1))
                  .cornerRadius(16)
                }
              }
              .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
          }
        }
      }

    }
    .buttonStyle(NoSelectionButtonStyle())
    .onAppear {
      regenerateQR()
    }
  }

  // MARK: - Logic

  private func regenerateQR() {
    isRegenerating = true

    // 1. Build Payload (Offline SMS Draft)
    // Construct contact info from settings
    var supporter: ShieldQRPayload.SupporterContact? = nil
    if let contact = contactStore.contact {
      supporter = ShieldQRPayload.SupporterContact(
        name: contact.name,
        // CRITICAL: Force phone to nil to prevent numeric sequences in QR
        phone: nil
      )
    }

    let payload = ShieldQRPayload(
      situation: config.situationText,
      doText: config.doText,
      dontText: config.dontText,
      safetyText: config.safetyText,
      supporter: supporter
    )

    // Use Plain Text for maximum reliability
    let payloadString = payload.asPlainText(includePhone: false)

    // 2. Async Gen
    Task {
      // Basic QR
      guard let baseQR = QRGenerator.generate(from: payloadString) else { return }

      // Art Render
      // Each call to renderOptionA generates unique noise, so just calling it is enough for "Regenerate"
      // Passing selectedTheme
      let art = QRArtRenderer.renderOptionA(qr: baseQR, theme: selectedTheme)

      await MainActor.run {
        withAnimation {
          self.qrImage = art
          self.isRegenerating = false
        }
      }
    }
  }

}
