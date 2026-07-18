import SwiftUI

enum BuildWeekDesign {
  enum HumanSignal {
    static let background = Color(hex: "F4F0E7")
    static let backgroundWarm = Color(hex: "FAF7F0")
    static let surface = Color(hex: "FBF8F1").opacity(0.82)
    static let ink = Color(hex: "123136")
    static let secondaryInk = Color(hex: "5E6C6C")
    static let action = Color(hex: "0D3739")
    static let actionPressed = Color(hex: "17484A")
    static let line = Color(hex: "CFC9BF")
    static let seaGlass = Color(hex: "9EC8C1")
    static let lilac = Color(hex: "C8B7CE")
    static let coral = Color(hex: "EA8065")
  }

  enum Shelter {
    static let background = Color(hex: "F8F5EE")
    static let surface = Color(hex: "FFFDF8")
    static let surfaceQuiet = Color(hex: "EDF1EB")
    static let surfaceEmphasis = Color(hex: "DCE9E1")
    static let ink = Color(hex: "173033")
    static let secondaryInk = Color(hex: "5D6B6B")
    static let teal = Color(hex: "1F5B5E")
    static let coral = Color(hex: "ED8573")
    static let line = Color(hex: "CCD3CC")
  }

  enum Signal {
    static let background = Color(hex: "12100E")
    static let surface = Color(hex: "1B1815")
    static let ivory = Color(hex: "F5EFE7")
    static let action = Color(hex: "E9957F")
    static let support = Color(hex: "B8CFC4")
    static let line = Color(hex: "3A322C")
  }

  enum Metric {
    static let screenPadding: CGFloat = 20
    static let sectionGap: CGFloat = 24
    static let cardPadding: CGFloat = 20
    static let cardRadius: CGFloat = 12
    static let controlRadius: CGFloat = 14
    static let minimumTouch: CGFloat = 44
    static let shieldUtility: CGFloat = 48
    static let primaryAction: CGFloat = 64
    static let crisisAction: CGFloat = 72
  }
}

struct ResponsiveShelterPalette {
  let backgroundTop: Color
  let backgroundBottom: Color
  let surface: Color
  let surfaceBorder: Color
  let primaryText: Color
  let secondaryText: Color
  let accent: Color
  let fieldPrimary: Color
  let fieldSecondary: Color
  let fieldLight: Color
  let fieldSeam: Color
}

extension AppTheme {
  var shelterPalette: ResponsiveShelterPalette {
    switch self {
    case .grounded:
      return ResponsiveShelterPalette(
        backgroundTop: Color(hex: "062326"),
        backgroundBottom: Color(hex: "0A3436"),
        surface: Color(hex: "163B3D").opacity(0.88),
        surfaceBorder: Color(hex: "73908D").opacity(0.68),
        primaryText: Color(hex: "F7F3EC"),
        secondaryText: Color(hex: "B8C5C3"),
        accent: Color(hex: "ED7B5C"),
        fieldPrimary: Color(hex: "26383B"),
        fieldSecondary: Color(hex: "6F7F7E"),
        fieldLight: Color(hex: "C9D2CC"),
        fieldSeam: Color(hex: "D97752")
      )

    case .luminous:
      return ResponsiveShelterPalette(
        backgroundTop: Color(hex: "071B28"),
        backgroundBottom: Color(hex: "0A3040"),
        surface: Color(hex: "142F3C").opacity(0.90),
        surfaceBorder: Color(hex: "728A99").opacity(0.70),
        primaryText: Color(hex: "FBF8F2"),
        secondaryText: Color(hex: "C7CDD8"),
        accent: Color(hex: "ED8163"),
        fieldPrimary: Color(hex: "8FA5B8"),
        fieldSecondary: Color(hex: "C5B3C8"),
        fieldLight: Color(hex: "F1E7D6"),
        fieldSeam: Color(hex: "E5A184")
      )
    }
  }
}

struct ShelterCard<Content: View>: View {
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding(BuildWeekDesign.Metric.cardPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(BuildWeekDesign.Shelter.surface)
      .clipShape(
        RoundedRectangle(
          cornerRadius: BuildWeekDesign.Metric.cardRadius,
          style: .continuous
        )
      )
      .overlay(
        RoundedRectangle(
          cornerRadius: BuildWeekDesign.Metric.cardRadius,
          style: .continuous
        )
        .stroke(BuildWeekDesign.Shelter.line, lineWidth: 1)
      )
  }
}

struct AnchorWordmark: View {
  var body: some View {
    Text("Anchor")
      .font(.title2.bold())
      .fontDesign(.default)
      .tracking(-0.3)
      .foregroundStyle(BuildWeekDesign.Shelter.ink)
      .dynamicTypeSize(.xSmall ... .accessibility1)
      .accessibilityAddTraits(.isHeader)
  }
}

struct ShelterSectionLabel: View {
  let text: String

  var body: some View {
    Text(text.uppercased())
      .font(.caption.weight(.bold))
      .fontDesign(.default)
      .tracking(1.2)
      .foregroundStyle(BuildWeekDesign.Shelter.secondaryInk)
      .dynamicTypeSize(.xSmall ... .accessibility2)
  }
}

struct ReadinessDot: View {
  let isComplete: Bool

  var body: some View {
    Image(systemName: isComplete ? "checkmark" : "circle")
      .font(.system(size: 12, weight: .bold))
      .foregroundStyle(
        isComplete ? Color.white : BuildWeekDesign.Shelter.secondaryInk
      )
      .frame(width: 24, height: 24)
      .background(
        isComplete
          ? BuildWeekDesign.Shelter.teal
          : BuildWeekDesign.Shelter.surfaceQuiet,
        in: Circle()
      )
  }
}

struct TactileChoiceChip: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 18, weight: .semibold))
          .frame(width: 24)
        Text(title)
          .fixedSize(horizontal: false, vertical: true)

        Spacer(minLength: 0)
      }
      .font(.body.weight(.semibold))
      .fontDesign(.default)
      .foregroundStyle(
        isSelected ? Color.white : BuildWeekDesign.Shelter.ink
      )
      .padding(.horizontal, 14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(minHeight: 52)
      .background(
        isSelected
          ? BuildWeekDesign.Shelter.teal
          : BuildWeekDesign.Shelter.surfaceQuiet,
        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .stroke(
            isSelected ? BuildWeekDesign.Shelter.teal : BuildWeekDesign.Shelter.line,
            lineWidth: 1
          )
      }
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

struct ShelterPageHeader: View {
  let section: String

  var body: some View {
    ViewThatFits(in: .horizontal) {
      HStack(spacing: 16) {
        AnchorWordmark()
        Spacer(minLength: 8)
        sectionLabel
      }

      VStack(alignment: .leading, spacing: 8) {
        AnchorWordmark()
        sectionLabel
      }
    }
    .accessibilityElement(children: .contain)
  }

  private var sectionLabel: some View {
    Text(section.uppercased())
      .font(.caption.weight(.bold))
      .fontDesign(.default)
      .tracking(1.3)
      .foregroundStyle(BuildWeekDesign.Shelter.secondaryInk)
      .lineLimit(1)
      .dynamicTypeSize(.xSmall ... .accessibility2)
  }
}

struct ShelterInlineNote: View {
  let text: String
  var icon = "sparkles"

  var body: some View {
    Label {
      Text(text)
        .fixedSize(horizontal: false, vertical: true)
    } icon: {
      Image(systemName: icon)
    }
    .font(.footnote.weight(.semibold))
    .fontDesign(.default)
    .foregroundStyle(BuildWeekDesign.Shelter.secondaryInk)
    .padding(.top, 12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .overlay(alignment: .top) {
      Rectangle()
        .fill(BuildWeekDesign.Shelter.line)
        .frame(height: 1)
    }
    .accessibilityElement(children: .combine)
  }
}

struct SignalSafetyBand: View {
  let text: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Safety")
        .font(.caption.weight(.bold))
        .tracking(1.1)
        .textCase(.uppercase)
        .foregroundStyle(BuildWeekDesign.Signal.action)
        .dynamicTypeSize(.xSmall ... .accessibility2)

      Text(text)
        .font(.body.weight(.semibold))
        .fontDesign(.default)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(BuildWeekDesign.Signal.ivory)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
  }
}

struct SignalGuidanceSheet: View {
  let doText: String
  let dontText: String

  var body: some View {
    VStack(alignment: .leading, spacing: 28) {
      SignalGuidanceSection(
        title: "What helps",
        text: doText,
        color: BuildWeekDesign.Signal.support
      )

      SignalGuidanceSection(
        title: "Please avoid",
        text: dontText,
        color: BuildWeekDesign.Signal.action
      )
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct SignalGuidanceSection: View {
  let title: String
  let text: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title.uppercased())
        .font(.caption.weight(.bold))
        .fontDesign(.default)
        .tracking(1.1)
        .foregroundStyle(color)
        .dynamicTypeSize(.xSmall ... .accessibility2)

      Text(text)
        .font(.body.weight(.semibold))
        .fontDesign(.default)
        .foregroundStyle(BuildWeekDesign.Signal.ivory)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
  }
}
