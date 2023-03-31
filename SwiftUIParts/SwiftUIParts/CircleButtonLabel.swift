import SwiftUI

struct CircleButtonLabel: View {
    var image: Image
    var size: CGFloat = 40
    var imageSizeRatio: CGFloat = 0.6
    var disabled: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.black)
                .background(Circle().fill(Color.white).shadow(radius: 1, y: 2))
                .frame(width: size, height: size)
            image
                .resizable()
                .scaledToFit()
                .frame(width: size * imageSizeRatio, height: size * imageSizeRatio)
            if disabled {
                Circle()
                    .fill(Color.gray)
                    .opacity(0.4)
                    .frame(width: size, height: size)
            }
        }

    }
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CircleButtonLabel(image: Image(systemName: "gearshape"))
            CircleButtonLabel(image: Image(systemName: "gearshape"), size: 60, disabled: true)
        }
    }
}
