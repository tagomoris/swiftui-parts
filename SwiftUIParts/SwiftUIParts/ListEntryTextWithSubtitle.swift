import SwiftUI

struct ListEntryTextWithSubtitle: View {
    var title: String
    var subtitle: String
    var titleFont: Font = .headline
    var subtitleFont: Font = .footnote
    var backgroundColor: Color = .white

    var body: some View {
        VStack(alignment: .leading, spacing: 0.2) {
            Text(title)
                .font(titleFont)
            Text(subtitle)
                .font(subtitleFont)
        }
        .background(backgroundColor)
    }
}

struct ListEntryTextWithSubtitle_Previews: PreviewProvider {
    static var previews: some View {
        ListEntryTextWithSubtitle(title: "Title", subtitle: "This is a subtitle...")
    }
}
