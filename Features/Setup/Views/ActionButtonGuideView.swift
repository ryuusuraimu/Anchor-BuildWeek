import SwiftUI

struct ActionButtonGuideView: View {
  private let steps: [TutorialStep] = [
    TutorialStep(
      id: 0, imageName: "AB_0GotoShortcuts",
      instruction: "Open the **Shortcuts** app and ensure you have the **Deploy Shield** shortcut."
    ),
    TutorialStep(
      id: 1, imageName: "AB_1GotoSettings",
      instruction: "Open the **Settings** app on your iPhone."
    ),
    TutorialStep(
      id: 2, imageName: "AB_2Select",
      instruction: "Go to **Action Button** and swipe to select **Shortcut**."
    ),
    TutorialStep(
      id: 3, imageName: "AB_3ChoseAnchor",
      instruction: "Tap the shortcut selector and choose **Deploy Shield**."
    ),
    TutorialStep(
      id: 4, imageName: "AB_4Success",
      instruction: "Done! Your Action Button is now configured to deploy Shield instantly."
    ),
  ]

  var body: some View {
    TutorialCardSwiper(
      title: "Action Button",
      subtitle: "iPhone 15 Pro and later — press and hold to deploy Shield",
      icon: "button.programmable",
      steps: steps
    )
  }
}

#Preview {
  ActionButtonGuideView()
}
