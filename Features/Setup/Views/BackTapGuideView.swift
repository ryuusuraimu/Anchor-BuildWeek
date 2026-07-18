import SwiftUI

struct BackTapGuideView: View {
  private let steps: [TutorialStep] = [
    TutorialStep(
      id: 0, imageName: "BackTapTutorial/0GotoShortcuts",
      instruction: "Open the **Shortcuts** app on your iPhone."
    ),
    TutorialStep(
      id: 1, imageName: "BackTapTutorial/1InApp",
      instruction: "Tap on **Shortcuts** in the bottom tab bar if not already selected."
    ),
    TutorialStep(
      id: 2, imageName: "BackTapTutorial/2CreateSetup",
      instruction:
        "Ensure you have the **Deploy Shield** shortcut. If not, create it or download it."
    ),
    TutorialStep(
      id: 3, imageName: "BackTapTutorial/3DeployShield",
      instruction: "This is the shortcut that will be triggered by Back Tap."
    ),
    TutorialStep(
      id: 4, imageName: "BackTapTutorial/4Setup",
      instruction: "Now that the shortcut is ready, let's set up the trigger."
    ),
    TutorialStep(
      id: 5, imageName: "BackTapTutorial/5GotoSettings",
      instruction: "Open the **Settings** app on your iPhone."
    ),
    TutorialStep(
      id: 6, imageName: "BackTapTutorial/6Accessibility",
      instruction: "Go to **Accessibility**."
    ),
    TutorialStep(
      id: 7, imageName: "BackTapTutorial/7Touch",
      instruction: "Tap on **Touch**."
    ),
    TutorialStep(
      id: 8, imageName: "BackTapTutorial/8BackTap",
      instruction: "Scroll down and select **Back Tap**."
    ),
    TutorialStep(
      id: 9, imageName: "BackTapTutorial/9DoubleTap",
      instruction:
        "Choose **Double Tap** (or Triple Tap) and select **Deploy Shield** from the list."
    ),
  ]

  var body: some View {
    TutorialCardSwiper(
      title: "Back Tap",
      subtitle: "Tap the back of your iPhone to deploy Shield instantly",
      icon: "hand.tap",
      steps: steps
    )
  }
}

#Preview {
  BackTapGuideView()
}
