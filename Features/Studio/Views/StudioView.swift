import SwiftUI

struct StudioView: View {
  @Environment(SettingsStore.self) private var settings
  @EnvironmentObject var contactStore: EmergencyContactStore
  @EnvironmentObject var router: AppRouter
  @State private var viewModel = StudioViewModel()
  @State private var showPreview = false
  @State private var contactSheet: StudioContactSheet?
  @State private var showContactOptions = false
  @State private var showSaveAlert = false
  @State private var showHistory = false
  @State private var showSavePrompt = false
  @State private var showShareSheet = false

  enum StudioContactSheet: Identifiable {
    case picker, editor
    var id: Int { hashValue }
  }

  @State private var saveNote = ""
  @State private var contactDraft = EmergencyContactDraft()

  var body: some View {
    NavigationStack {
      ZStack {
        // Background
        OrganicBackgroundView()

        VStack(spacing: 0) {
          // Custom Header
          HStack {
            Text("Studio")
              .font(DesignSystem.Fonts.hero())
              .foregroundColor(DesignSystem.Colors.deepText)
              .lineLimit(1)
              .minimumScaleFactor(0.8)

            Spacer()

            HStack(spacing: 8) {
              // Setup Wizard
              Button(action: {
                router.showSetupWizard = true
              }) {
                Image(systemName: "wand.and.stars")
                  .font(.title3)
                  .frame(width: DesignSystem.Layout.minTouchTarget, height: DesignSystem.Layout.minTouchTarget)
              }
              .foregroundColor(DesignSystem.Colors.softText)

              Button(action: { showHistory = true }) {
                Image(systemName: "clock.arrow.circlepath")
                  .font(.title3)
                  .frame(width: DesignSystem.Layout.minTouchTarget, height: DesignSystem.Layout.minTouchTarget)
              }
              .foregroundColor(DesignSystem.Colors.softText)

              // Separator
              Rectangle()
                .fill(DesignSystem.Colors.softText.opacity(0.3))
                .frame(width: 1, height: 16)

              Button(action: { showShareSheet = true }) {
                Image(systemName: "square.and.arrow.up")
                  .font(.system(size: 17, weight: .semibold))
                  .foregroundColor(DesignSystem.Colors.calmTeal)
                  .frame(width: DesignSystem.Layout.minTouchTarget, height: DesignSystem.Layout.minTouchTarget)
              }

              // Separator
              Rectangle()
                .fill(DesignSystem.Colors.softText.opacity(0.3))
                .frame(width: 1, height: 16)

              Button("Save") {
                saveNote = ""  // Reset note
                showSavePrompt = true
              }
              .font(.system(size: 17, weight: .semibold))
              .foregroundColor(DesignSystem.Colors.calmTeal)
              .frame(minWidth: DesignSystem.Layout.minTouchTarget, minHeight: DesignSystem.Layout.minTouchTarget)
            }
            .layoutPriority(1)  // prioritize buttons over title width
          }
          .padding(.horizontal, DesignSystem.Layout.screenPadding)
          .padding(.top, 24)
          .padding(.bottom, 16)

          ScrollView {
            VStack(spacing: DesignSystem.Layout.sectionSpacing) {

              // 2. Situation
              StudioSection(
                title: "Situation",
                icon: "exclamationmark.bubble.fill",
                guideText:
                  "Briefly describe what is happening so others understand the context.\n\nExamples: Panicking, Overwhelmed, Sensory overload.",
                learnCategory: .helpingNow,
                onLearnTap: { activeLearnCategory = $0 }
              ) {
                StudioTextField(
                  placeholder: "What is happening?", text: $viewModel.config.situationText)
                SuggestedChips(
                  options: ["Panicking", "Overwhelmed", "Need quiet", "Cannot speak clearly"],
                  binding: $viewModel.config.situationText
                )
              }

              // 3. Please Do
              StudioSection(
                title: "Please Do",
                icon: "hand.raised.fingers.spread.fill",
                guideText:
                  "Specific actions that help you recover.\n\nExamples: Speak softly, Count with me, Stay close.",
                learnCategory: .communication,
                onLearnTap: { activeLearnCategory = $0 }
              ) {
                StudioTextField(placeholder: "How to help?", text: $viewModel.config.doText)
                SuggestedChips(
                  options: ["Give space", "Speak softly", "Stay close", "Count with me"],
                  binding: $viewModel.config.doText
                )
              }

              // 4. Please Don't
              StudioSection(
                title: "Please Don't",
                icon: "xmark.circle.fill",
                guideText:
                  "Actions that might make things worse.\n\nExamples: No touching, Too many questions, Crowding.",
                learnCategory: .space,
                onLearnTap: { activeLearnCategory = $0 }
              ) {
                StudioTextField(placeholder: "What to avoid?", text: $viewModel.config.dontText)
                SuggestedChips(
                  options: [
                    "No touch", "Few questions", "Don't stare", "Don't crowd me",
                  ],
                  binding: $viewModel.config.dontText
                )
              }

              // 5. Safety
              StudioSection(
                title: "Safety",
                icon: "cross.case.fill",
                guideText:
                  "Important instructions for your safety.\n\nExamples: Call local emergency services if injured, Don't leave me alone.",
                learnCategory: .safety,
                onLearnTap: { activeLearnCategory = $0 }
              ) {
                let safetyBinding = Binding(
                  get: { viewModel.config.safetyText ?? "" },
                  set: { viewModel.config.safetyText = $0.isEmpty ? nil : $0 }
                )

                VStack(spacing: 8) {
                  StudioTextField(placeholder: "Safety instructions...", text: safetyBinding)
                  SuggestedChips(
                    options: [
                      "Call local emergency services if I am injured", "Don't leave me alone",
                      "I have medication in my bag",
                      "Call my support contact",
                    ],
                    binding: safetyBinding
                  )
                }
              }

              // 6. Support Relay
              StudioSection(
                title: "Support Relay",
                icon: "phone.fill",
                guideText:
                  "Trusted people who can be called in order from the Shield screen."
              ) {
                if !contactStore.contacts.isEmpty {
                  VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(contactStore.contacts.prefix(3).enumerated()), id: \.element.id) { index, contact in
                      HStack(spacing: 10) {
                        Text("\(index + 1)")
                          .font(.system(size: 13, weight: .bold, design: .rounded))
                          .foregroundColor(index == 0 ? .white : DesignSystem.Colors.activeAction)
                          .frame(width: 30, height: 30)
                          .background(
                            index == 0
                              ? DesignSystem.Colors.activeAction
                              : DesignSystem.Colors.calmTeal.opacity(0.14),
                            in: Circle()
                          )

                        VStack(alignment: .leading, spacing: 3) {
                          Text(contact.name)
                            .font(DesignSystem.Fonts.headline())
                            .foregroundColor(DesignSystem.Colors.deepText)
                            .lineLimit(1)

                          HStack(spacing: 4) {
                            Text(contact.phone)
                            if let label = contact.phoneLabel {
                              Text("(\(label))")
                            }
                          }
                          .font(DesignSystem.Fonts.caption())
                          .foregroundColor(DesignSystem.Colors.softText)
                          .lineLimit(1)
                          .minimumScaleFactor(0.6)
                        }
                      }
                    }

                    if contactStore.contacts.count > 3 {
                      Text("+ \(contactStore.contacts.count - 3) more")
                        .font(DesignSystem.Fonts.caption())
                        .foregroundColor(DesignSystem.Colors.softText)
                    }

                    HStack(spacing: 12) {
                      Button(action: {
                        contactDraft = EmergencyContactDraft(from: nil)
                        contactSheet = .editor
                      }) {
                        Label("Add", systemImage: "plus.circle.fill")
                          .font(DesignSystem.Fonts.caption().weight(.bold))
                          .frame(minHeight: DesignSystem.Layout.minTouchTarget)
                      }

                      Button(action: {
                        contactDraft = EmergencyContactDraft(from: contactStore.contact)
                        contactSheet = .editor
                      }) {
                        Label("Edit First", systemImage: "pencil.circle.fill")
                          .font(DesignSystem.Fonts.caption().weight(.bold))
                          .frame(minHeight: DesignSystem.Layout.minTouchTarget)
                      }
                    }
                    .foregroundColor(DesignSystem.Colors.calmTeal)
                  }
                } else {
                  Button(action: { showContactOptions = true }) {
                    VStack(alignment: .leading, spacing: 4) {
                      Text("Add Contact")
                        .font(DesignSystem.Fonts.title())
                        .foregroundColor(DesignSystem.Colors.calmTeal)
                      Text("Add trusted people for Support Relay.")
                        .font(DesignSystem.Fonts.caption())
                        .foregroundColor(DesignSystem.Colors.softText)
                    }
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                  }
                  .padding()
                  .background(DesignSystem.Colors.calmTeal.opacity(0.1))
                  .cornerRadius(12)
                  .foregroundColor(DesignSystem.Colors.calmTeal)
                }
              }

              // 7. Preview Button
              Button(action: {
                showPreview = true
              }) {
                HStack {
                  Image(systemName: "shield.fill")
                  Text("Create Shield")
                    .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                  Capsule()
                    .fill(DesignSystem.Colors.calmTeal)
                    .shadow(color: DesignSystem.Colors.calmTeal.opacity(0.4), radius: 8, y: 4)
                )
              }
              .padding(.horizontal, DesignSystem.Layout.screenPadding)
            }
            .padding(.top, 20)
            .padding(.bottom, 132)
          }
          .scrollIndicators(.hidden)
        }
      }
      .buttonStyle(.plain)
      .navigationBarHidden(true)
      .sheet(isPresented: $showSavePrompt) {
        SaveVersionSheet { title, note, icon, color in
          viewModel.saveVersion(
            title: title,
            note: note.isEmpty ? nil : note,
            icon: icon,
            themeColor: color
          )
          showSaveAlert = true
        }
      }
      .alert("Saved", isPresented: $showSaveAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text("Your version has been saved to history.")
      }
      .sheet(isPresented: $showHistory) {
        HistoryView { oldItem in
          viewModel.restore(oldItem)
        }
      }
      .sheet(isPresented: $showPreview) {
        ShieldView(config: viewModel.config)
      }
      // MARK: - Contact Sheets
      .confirmationDialog("Add Support Contact", isPresented: $showContactOptions) {
        Button("Pick from Contacts") {
          contactDraft = EmergencyContactDraft(from: nil)
          contactSheet = .picker
        }
        Button("Enter Manually") {
          contactDraft = EmergencyContactDraft(from: nil)  // Ensure clean draft
          contactSheet = .editor
        }
        Button("Cancel", role: .cancel) {}
      }
      .sheet(item: $contactSheet) { sheet in
        switch sheet {
        case .picker:
          ContactPicker(
            onSelect: { name, phone, label in
              contactDraft.name = name
              contactDraft.phone = phone
              contactDraft.phoneLabel = label ?? ""
              contactStore.upsert(contactDraft.toEmergencyContact())
              contactSheet = nil
            },
            onCancel: {
              contactSheet = nil
            }
          )
        case .editor:
          NavigationStack {
            EmergencyContactEditor(
              draft: $contactDraft,
              isEditing: contactDraft.id != nil,
              onPickFromContacts: {
                contactSheet = .picker
              },
              onSave: {
                contactStore.upsert(contactDraft.toEmergencyContact())
                contactSheet = nil
              },
              onCancel: {
                contactSheet = nil
              },
              onRemove: (contactDraft.id != nil)
                ? {
                  if let id = contactDraft.id {
                    contactStore.remove(id: id)
                  }
                  contactSheet = nil
                } : nil
            )
          }
        }
      }
      .onDisappear {
        viewModel.persistCurrentState()
      }
      .sheet(item: $activeLearnCategory) { category in
        LearnCategorySheet(category: category)
      }
      .sheet(isPresented: $showShareSheet) {
        ShareActivityView(activityItems: [exportText])
      }
    }
  }

  // Learn Sheet State
  @State private var activeLearnCategory: LearnCategory?

  private var exportText: String {
    """
    ANCHOR Support Protocol

    [SITUATION]
    \(viewModel.config.situationText)

    [PLEASE DO]
    \(viewModel.config.doText)

    [PLEASE DON'T]
    \(viewModel.config.dontText)

    [SAFETY]
    \(viewModel.config.safetyText ?? "None")
    """
  }
}

// MARK: - Components

struct StudioSection<Content: View>: View {
  let title: String
  let icon: String
  let guideText: String?
  let learnCategory: LearnCategory?
  var onLearnTap: ((LearnCategory) -> Void)?
  let content: Content
  @State private var showGuide = false

  init(
    title: String,
    icon: String,
    guideText: String? = nil,
    learnCategory: LearnCategory? = nil,
    onLearnTap: ((LearnCategory) -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.icon = icon
    self.guideText = guideText
    self.learnCategory = learnCategory
    self.onLearnTap = onLearnTap
    self.content = content()
  }

  var body: some View {
    GlassCard {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Label(title, systemImage: icon)
            .font(DesignSystem.Fonts.headline())
            .foregroundColor(DesignSystem.Colors.deepText)

          Spacer()

          if let learnCategory = learnCategory, let onLearnTap = onLearnTap {
            Button(action: { onLearnTap(learnCategory) }) {
              Image(systemName: "info.circle")
                .foregroundColor(DesignSystem.Colors.calmTeal)
            }
          } else if guideText != nil {
            Button(action: { showGuide = true }) {
              Image(systemName: "info.circle")
                .foregroundColor(DesignSystem.Colors.calmTeal)
            }
          }
        }
        content
      }
    }
    .padding(.horizontal, DesignSystem.Layout.screenPadding)
    .alert(title, isPresented: $showGuide, actions: { Button("OK", role: .cancel) {} }) {
      if let guideText {
        Text(guideText)
      }
    }
  }
}

struct StudioTextField: View {
  let placeholder: String
  @Binding var text: String

  var body: some View {
    TextField(placeholder, text: $text, axis: .vertical)
      .font(DesignSystem.Fonts.body())
      .padding()
      .frame(minHeight: 58, alignment: .topLeading)
      .background(Color.white.opacity(0.5))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
      )
  }
}

struct SuggestedChips: View {
  let options: [String]
  @Binding var binding: String

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(options, id: \.self) { option in
          Button(action: {
            if option.hasPrefix("http") {
              binding = option
            } else {
              if binding.isEmpty {
                binding = option
              } else if !binding.contains(option) {
                binding += ", " + option
              }
            }
          }) {
            Text(option)
              .font(DesignSystem.Fonts.caption())
              .lineLimit(1)
              .minimumScaleFactor(0.85)
              .padding(.horizontal, 12)
              .padding(.vertical, 8)
              .background(DesignSystem.Colors.glassSurface, in: Capsule())
              .overlay(Capsule().stroke(DesignSystem.Colors.glassBorder, lineWidth: 1))
              .foregroundColor(DesignSystem.Colors.deepText)
          }
        }
      }
      .padding(.vertical, 4)
    }
  }
}

#Preview {
  StudioView()
    .environment(SettingsStore())
    .environmentObject(EmergencyContactStore())
    .environmentObject(AppRouter.shared)
}
