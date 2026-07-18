import SwiftUI

struct EmergencyContactCard: View {
  @ObservedObject var store: EmergencyContactStore

  var onAdd: () -> Void
  var onEdit: (EmergencyContact) -> Void
  var onPick: () -> Void

  var body: some View {
    GlassCard {
      if store.contacts.isEmpty {
        emptyStateView
      } else {
        contactsView
      }
    }
  }

  private var contactsView: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Support Relay")
            .font(DesignSystem.Fonts.caption())
            .fontWeight(.bold)
            .foregroundColor(DesignSystem.Colors.softText)

          Text("\(store.contacts.count) contact\(store.contacts.count == 1 ? "" : "s") ready")
            .font(DesignSystem.Fonts.title())
            .foregroundColor(DesignSystem.Colors.deepText)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
        }

        Spacer()

        Button(action: onAdd) {
          Image(systemName: "plus")
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 44, height: 44)
            .background(DesignSystem.Colors.calmTeal, in: Circle())
        }
        .accessibilityLabel("Add support contact")
      }

      VStack(spacing: 10) {
        ForEach(Array(store.contacts.enumerated()), id: \.element.id) { index, contact in
          contactRow(contact, index: index)
        }
      }
    }
    .padding(.vertical, 8)
  }

  private func contactRow(_ contact: EmergencyContact, index: Int) -> some View {
    HStack(spacing: 12) {
      Text("\(index + 1)")
        .font(.system(size: 15, weight: .bold, design: .rounded))
        .foregroundColor(index == 0 ? .white : DesignSystem.Colors.activeAction)
        .frame(width: 34, height: 34)
        .background(
          index == 0
            ? DesignSystem.Colors.activeAction
            : DesignSystem.Colors.calmTeal.opacity(0.14),
          in: Circle()
        )
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 3) {
        Text(contact.name)
          .font(DesignSystem.Fonts.headline())
          .foregroundColor(DesignSystem.Colors.deepText)
          .lineLimit(1)
          .minimumScaleFactor(0.78)

        HStack(spacing: 4) {
          Text(contact.phone)
          if let label = contact.phoneLabel {
            Text("(\(label))")
          }
        }
        .font(DesignSystem.Fonts.caption())
        .foregroundColor(DesignSystem.Colors.softText)
        .lineLimit(1)
        .minimumScaleFactor(0.7)

        if index == 0 {
          Text("First call")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(DesignSystem.Colors.activeAction)
        }
      }

      Spacer(minLength: 0)

      HStack(spacing: 6) {
        Button(action: {
          if let url = URL(string: "tel://\(sanitizePhone(contact.phone))") {
            UIApplication.shared.open(url)
          }
        }) {
          Image(systemName: "phone.fill")
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 44, height: 44)
            .background(DesignSystem.Colors.calmTeal, in: Circle())
        }
        .accessibilityLabel("Call \(contact.name)")

        if store.contacts.count > 1 {
          VStack(spacing: 4) {
            Button(action: { move(contact, direction: -1) }) {
              Image(systemName: "chevron.up")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DesignSystem.Colors.softText)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.05), in: Circle())
            }
            .disabled(index == 0)
            .opacity(index == 0 ? 0.35 : 1)
            .accessibilityLabel("Move \(contact.name) earlier")

            Button(action: { move(contact, direction: 1) }) {
              Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DesignSystem.Colors.softText)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.05), in: Circle())
            }
            .disabled(index == store.contacts.count - 1)
            .opacity(index == store.contacts.count - 1 ? 0.35 : 1)
            .accessibilityLabel("Move \(contact.name) later")
          }
        }

        Button(action: { onEdit(contact) }) {
          Image(systemName: "pencil")
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(DesignSystem.Colors.softText)
            .frame(width: 44, height: 44)
            .background(Color.black.opacity(0.05), in: Circle())
        }
        .accessibilityLabel("Edit \(contact.name)")
      }
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 10)
    .background(Color.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
    )
  }

  private var emptyStateView: some View {
    Button(action: onAdd) {
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Support Relay")
            .font(DesignSystem.Fonts.caption())
            .fontWeight(.bold)
            .foregroundColor(DesignSystem.Colors.softText)

          Text("Add Support Contacts")
            .font(DesignSystem.Fonts.title())
            .foregroundColor(DesignSystem.Colors.calmTeal)

          Text("Add trusted people, then call them in order from Shield.")
            .font(DesignSystem.Fonts.caption())
            .foregroundColor(DesignSystem.Colors.softText)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer()

        Image(systemName: "plus.circle.fill")
          .font(.title)
          .foregroundColor(DesignSystem.Colors.calmTeal)
      }
      .padding(.vertical, 8)
    }
    .accessibilityLabel("Add support relay contacts")
    .accessibilityHint("Adds trusted people that can be called in order.")
  }

  private func sanitizePhone(_ phone: String) -> String {
    phone.filter { "0123456789+".contains($0) }
  }

  private func move(_ contact: EmergencyContact, direction: Int) {
    guard let index = store.contacts.firstIndex(where: { $0.id == contact.id }) else { return }
    let newIndex = index + direction
    guard store.contacts.indices.contains(newIndex) else { return }

    var updated = store.contacts
    updated.swapAt(index, newIndex)
    store.contacts = updated
  }
}
