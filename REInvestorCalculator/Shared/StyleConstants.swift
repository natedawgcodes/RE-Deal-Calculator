import SwiftUI

public enum Spacing {
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
}

public enum CornerRadius {
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    public static let large: CGFloat = 16
}

public struct CardModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(Spacing.medium)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(CornerRadius.medium)
            .shadow(radius: 2)
    }
}

extension View {
    public func cardStyle() -> some View {
        modifier(CardModifier())
    }
} 