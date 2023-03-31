import SwiftUI

struct TextFieldClearButton: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundStyle(.gray)
                }
                .padding(.trailing, 8)
            }
        }
    }
}

extension View {
    func clearButton(text: Binding<String>) -> some View {
        modifier(TextFieldClearButton(text: text))
    }
}

struct TextFieldClearButton_Previews: PreviewProvider {
    @State static var text: String = "Writing text"

    static var previews: some View {
        TextField("placeholder", text: $text)
            .clearButton(text: $text)
            .border(Color.gray)
            .frame(width: 300)
    }
}
