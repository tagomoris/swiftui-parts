import SwiftUI

struct UsualButtonLabel: View {
    enum ButtonStyle {
        case submit
        case cancel
    }

    var title: String = "Button"
    var image: Image? = nil
    var style: ButtonStyle = .submit
    var disabled: Bool = false
    var width: CGFloat = 200.0
    var height: CGFloat = 50.0

    func baseRectanble(disabled: Bool) -> some View {
        switch style {
        case .submit:
            return AnyView(RoundedRectangle(cornerRadius: 20)
                .foregroundColor(buttonColor(disabled: disabled)))
        case .cancel:
            return AnyView(RoundedRectangle(cornerRadius: 20)
                .stroke(borderColor(disabled: disabled))
                .foregroundColor(buttonColor(disabled: disabled)))
        }
    }

    func buttonColor(disabled: Bool) -> Color {
        if disabled {
            return Color.gray
        }
        switch style {
        case .submit:
            return Color(uiColor: UIColor.tintColor)
        case .cancel:
            return Color.white
        }
    }

    func borderColor(disabled: Bool) -> Color {
        switch style {
        case .submit:
            return Color(uiColor: UIColor.tintColor)
        case .cancel:
            if disabled {
                return Color(uiColor: UIColor.darkGray)
            }
            return Color(uiColor: UIColor.tintColor)
        }
    }

    func label(disabled: Bool) -> some View {
        if let image {
            return AnyView(image
                .resizable()
                .scaledToFit()
                .foregroundColor(labelColor(disabled: disabled))
                .frame(width: width / 1.5, height: height / 1.5))
        } else {
            return AnyView(Text(title)
                .foregroundColor(labelColor(disabled: disabled))
                .bold())
        }
    }

    func labelColor(disabled: Bool) -> Color {
        switch style {
        case .submit:
            return Color.white
        case .cancel:
            if disabled {
                return Color(uiColor: UIColor.darkGray)
            }
            return Color(uiColor: UIColor.tintColor)
        }
    }

    var body: some View {
        ZStack {
            baseRectanble(disabled: disabled)
                .frame(width: width, height: height)
            label(disabled: disabled)
        }
    }
}

struct UsualButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UsualButtonLabel(
                title: "Create Account",
                style: .submit)
            UsualButtonLabel(
                title: "Cancel",
                style: .cancel)
            UsualButtonLabel(
                title: "Create Account",
                style: .submit,
                disabled: true)
            UsualButtonLabel(
                title: "Cancel",
                style: .cancel,
                disabled: true)
            UsualButtonLabel(
                image: Image(systemName: "checkmark.circle.fill"),
                style: .submit)
        }
    }
}
