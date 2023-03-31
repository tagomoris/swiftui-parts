import SwiftUI

struct LoadingCover: View {
    @Binding var isLoading: Bool

    var text: String? = nil
    var textFont: Font = .title
    var textPadding: CGFloat = 25.0

    var body: some View {
        if isLoading {
            ZStack {
                Color(.gray.withAlphaComponent(0.4))
                    .edgesIgnoringSafeArea(.all)
                if let t = self.text {
                    VStack {
                        ActivityIndicator()
                        Text(t)
                            .font(textFont)
                            .padding(textPadding)
                    }
                } else {
                    ActivityIndicator()
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct LoadingCover_Previews: PreviewProvider {
    @State static var isLoading: Bool = true

    static var previews: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(.green)
                .frame(width: 200, height: 200)
            LoadingCover(isLoading: $isLoading, text: "Loading ...")
        }
    }
}
