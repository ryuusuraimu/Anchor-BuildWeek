import SwiftUI
import UIKit

struct ShieldQRCodeView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.scenePhase) private var scenePhase
  @Environment(SettingsStore.self) private var settings
  @EnvironmentObject private var contactStore: EmergencyContactStore

  let config: ShieldConfig
  private let contactsOverride: [EmergencyContact]?

  @State private var qrImage: UIImage?
  @State private var generationFailed = false
  @State private var brightness = BrightnessService()

  init(config: ShieldConfig, contactsOverride: [EmergencyContact]? = nil) {
    self.config = config
    self.contactsOverride = contactsOverride
  }

  var body: some View {
    ZStack {
      BuildWeekDesign.Signal.background
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          header

          Text("SHARE SUPPORT CARD")
            .font(.caption.weight(.bold))
            .fontDesign(.rounded)
            .tracking(1.3)
            .foregroundStyle(BuildWeekDesign.Signal.action)
            .dynamicTypeSize(.xSmall ... .accessibility2)
            .padding(.top, 28)

          Text("Scan to read my support instructions.")
            .font(.title.bold())
            .fontDesign(.default)
            .tracking(-0.35)
            .foregroundStyle(BuildWeekDesign.Signal.ivory)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 10)
            .accessibilityAddTraits(.isHeader)

          qrCard
            .padding(.top, 24)

          VStack(alignment: .leading, spacing: 10) {
            Label("No internet required", systemImage: "wifi.slash")
            Label("Phone numbers are not included", systemImage: "lock.fill")
          }
          .font(.body.weight(.semibold))
          .fontDesign(.default)
          .foregroundStyle(BuildWeekDesign.Signal.support)
          .padding(.top, 22)
          .accessibilityElement(children: .combine)

          Text("The QR contains the same prepared guidance shown on Shield.")
            .font(.footnote.weight(.semibold))
            .fontDesign(.default)
            .foregroundStyle(BuildWeekDesign.Signal.ivory.opacity(0.66))
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .padding(.horizontal, BuildWeekDesign.Metric.screenPadding)
      }
      .scrollIndicators(.hidden)
    }
    .statusBar(hidden: true)
    .buttonStyle(.plain)
    .onAppear {
      regenerateQR()
      updateBrightness()
    }
    .onChange(of: settings.increaseBrightnessOnShieldCard) { _, _ in
      updateBrightness()
    }
    .onChange(of: scenePhase) { _, newPhase in
      if newPhase != .active {
        brightness.restore()
      } else {
        updateBrightness()
      }
    }
    .onDisappear {
      brightness.restore()
    }
  }

  private var header: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 2) {
        Text("ANCHOR SHIELD")
          .font(.caption.weight(.bold))
          .fontDesign(.rounded)
          .tracking(1.2)

        Text("Offline support card")
          .font(.caption2.weight(.medium))
          .fontDesign(.rounded)
          .foregroundStyle(BuildWeekDesign.Signal.ivory.opacity(0.62))
      }
      .foregroundStyle(BuildWeekDesign.Signal.ivory)
      .dynamicTypeSize(.xSmall ... .accessibility1)

      Spacer(minLength: 0)

      Button(action: { dismiss() }) {
        Label("Done", systemImage: "xmark")
          .font(.subheadline.bold())
          .fontDesign(.rounded)
          .foregroundStyle(BuildWeekDesign.Signal.ivory)
          .padding(.horizontal, 14)
          .frame(minHeight: BuildWeekDesign.Metric.shieldUtility)
          .background(
            BuildWeekDesign.Signal.surface,
            in: RoundedRectangle(cornerRadius: 15, style: .continuous)
          )
          .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
              .stroke(BuildWeekDesign.Signal.line, lineWidth: 1)
          }
      }
      .accessibilityLabel("Close QR support card")
      .dynamicTypeSize(.xSmall ... .accessibility2)
    }
    .padding(.top, 14)
    .padding(.bottom, 14)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(BuildWeekDesign.Signal.line)
        .frame(height: 1)
    }
  }

  @ViewBuilder
  private var qrCard: some View {
    VStack(spacing: 14) {
      if let qrImage {
        Image(uiImage: qrImage)
          .interpolation(.none)
          .resizable()
          .scaledToFit()
          .accessibilityLabel("QR code containing the prepared Shield instructions")
      } else if generationFailed {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 42, weight: .semibold))
          .foregroundStyle(BuildWeekDesign.Signal.action)
          .padding(.top, 28)

        Text("The QR could not be created.")
          .font(.headline)
          .fontDesign(.default)
          .foregroundStyle(BuildWeekDesign.Signal.background)
          .multilineTextAlignment(.center)

        Button(action: regenerateQR) {
          Label("Try again", systemImage: "arrow.clockwise")
            .font(.body.bold())
            .fontDesign(.rounded)
            .foregroundStyle(BuildWeekDesign.Signal.ivory)
            .padding(.horizontal, 18)
            .frame(minHeight: BuildWeekDesign.Metric.shieldUtility)
            .background(
              BuildWeekDesign.Signal.background,
              in: RoundedRectangle(cornerRadius: 15, style: .continuous)
            )
        }
        .padding(.bottom, 20)
      } else {
        ProgressView("Creating QR…")
          .font(.body.weight(.semibold))
          .fontDesign(.default)
          .tint(BuildWeekDesign.Signal.background)
          .foregroundStyle(BuildWeekDesign.Signal.background)
          .frame(minHeight: 232)
      }
    }
    .padding(18)
    .frame(maxWidth: 288)
    .background(
      BuildWeekDesign.Signal.ivory,
      in: RoundedRectangle(cornerRadius: 18, style: .continuous)
    )
    .frame(maxWidth: .infinity)
  }

  private var primaryContact: EmergencyContact? {
    if let contactsOverride {
      return contactsOverride.first
    }
    return contactStore.contact
  }

  private func regenerateQR() {
    generationFailed = false
    qrImage = nil

    let supporter = primaryContact.map {
      ShieldQRPayload.SupporterContact(name: $0.name, phone: nil)
    }
    let payload = ShieldQRPayload(
      situation: config.situationText,
      doText: config.doText,
      dontText: config.dontText,
      safetyText: config.safetyText,
      supporter: supporter
    )
    let payloadString = payload.asPlainText(includePhone: false)

    Task {
      let image = QRGenerator.generate(from: payloadString, correctionLevel: "L")
      await MainActor.run {
        qrImage = image
        generationFailed = image == nil
      }
    }
  }

  private func updateBrightness() {
    brightness.restore()
    brightness.applyEmergencyBrightness(enabled: settings.increaseBrightnessOnShieldCard)
  }
}
