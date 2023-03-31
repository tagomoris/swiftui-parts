import SwiftUI

fileprivate class BoxState {
    enum DraggingMode {
        case body
        case leftTop
        case rightTop
        case rightBottom
        case leftBottom
        case top
        case bottom
        case left
        case right
    }

    private var _mode: DraggingMode? = nil
    private var _size: CGSize = .zero
    private var _origin: CGPoint = .zero
    private var _minLength: CGFloat = .zero

    var mode: DraggingMode? { _mode }
    var size: CGSize { _size }
    var origin: CGPoint { _origin }
    var minLength: CGFloat { _minLength }

    var resizeOriginFenceXMax: CGFloat {
        _origin.x + _size.width - _minLength
    }

    var resizeOriginFenceYMax: CGFloat {
        _origin.y + size.height - minLength
    }

    func start(mode: DraggingMode, size: CGSize, origin: CGPoint, minLength: CGFloat) {
        self._mode = mode
        self._size = size
        self._origin = origin
        self._minLength = minLength
    }

    func stop() {
        self._mode = nil
    }

    func transform(width: CGFloat? = nil, height: CGFloat? = nil, x: CGFloat? = nil, y: CGFloat? = nil) -> ResizeableBoxGeometry {
        var newWidth = _size.width + (width ?? 0)
        if newWidth < minLength {
            newWidth = minLength
        }
        var newHeight = _size.height + (height ?? 0)
        if newHeight < minLength {
            newHeight = minLength
        }

        var newX = _origin.x + (x ?? 0)
        if newX > resizeOriginFenceXMax {
            newX = resizeOriginFenceXMax
        }
        var newY = _origin.y + (y ?? 0)
        if newY > resizeOriginFenceYMax {
            newY = resizeOriginFenceYMax
        }

        let size = CGSize(width: newWidth, height: newHeight)
        let origin = CGPoint(x: newX, y: newY)
        return ResizeableBoxGeometry(size: size, origin: origin)
    }
}

fileprivate class BoxStates {
    static let shared = BoxStates()

    private var states: [String:BoxState] = [:]

    func state(name: String) -> BoxState {
        if let s = states[name] {
            return s
        }
        let s = BoxState()
        states[name] = s
        return s
    }
}

struct ResizeableBoxGeometry {
    // Having just 1 state to avoid triggering re-rendering twice
    // by updating size and position independently

    let size: CGSize
    let origin: CGPoint
    let isFloating: Bool

    // The initial position is ignored
    init(size: CGSize, origin: CGPoint? = nil) {
        self.size = size
        if let origin {
            self.origin = origin
            self.isFloating = false
        } else {
            self.origin = .zero
            self.isFloating = true
        }
    }

    func satisfySize(_ minLength: CGFloat) -> Bool {
        size.width >= minLength && size.height >= minLength
    }

    var position: CGPoint {
        CGPoint(x: origin.x + size.width / 2.0, y: origin.y + size.height / 2.0)
    }

    func updateOrigin(origin: CGPoint) -> ResizeableBoxGeometry {
        return ResizeableBoxGeometry(size: self.size, origin: origin)
    }
}

fileprivate struct CorneredBox: View {
    var backgroundColor: Color
    var backgroundOpacity: CGFloat
    var borderColor: Color
    var borderWidth: CGFloat
    var cornerSize: CGFloat
    var cornerVisible: Bool

    var geometry: ResizeableBoxGeometry
    var inPlaceCallback: (CGPoint) -> Void

    private func corners() -> some View {
        Path { path in
            let width = geometry.size.width
            let height = geometry.size.height
            let mergin = borderWidth * 2
            // left top
            path.move(to: .init(x: mergin, y: cornerSize))
            path.addLine(to: .init(x: mergin, y: mergin))
            path.addLine(to: .init(x: cornerSize, y: mergin))
            // right top
            path.move(to: .init(x: width - cornerSize, y: mergin))
            path.addLine(to: .init(x: width - mergin, y: mergin))
            path.addLine(to: .init(x: width - mergin, y: cornerSize))
            // right bottom
            path.move(to: .init(x: width - mergin, y: height - cornerSize))
            path.addLine(to: .init(x: width - mergin, y: height - mergin))
            path.addLine(to: .init(x: width - cornerSize, y: height - mergin))
            // left bottom
            path.move(to: .init(x: cornerSize, y: height - mergin))
            path.addLine(to: .init(x: mergin, y: height - mergin))
            path.addLine(to: .init(x: mergin, y: height - cornerSize))
        }
        .stroke(lineWidth: borderWidth)
        .fill(borderColor)
    }

    private func centerOf(_ geometry: GeometryProxy) -> CGPoint {
        let f = geometry.frame(in: .global)
        let x = f.size.width / 2.0
        let y = f.size.height / 2.0
        return CGPoint(x: x, y: y)
    }

    var body: some View {
        let body = ZStack {
            GeometryReader { viewGeometry in
                Rectangle()
                    .strokeBorder(backgroundColor, lineWidth: borderWidth)
                    .background(Rectangle().fill(backgroundColor.opacity(backgroundOpacity)))
                    .onAppear {
                        if self.geometry.isFloating {
                            let frame = viewGeometry.frame(in: .global)
                            inPlaceCallback(CGPoint(x: frame.minX, y: frame.minY))
                        }
                    }
            }
            if cornerVisible {
                corners()
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)

        if !geometry.isFloating {
            return AnyView(body.position(geometry.position))
        }
        return AnyView(body)
    }
}

struct ResizeableBox: View {
    var name: String // mandatory for the case having 2 or more ResizeableBox in this app
    var backgroundColor: Color = Color.green
    var backgroundOpacity: CGFloat = 0.4
    var borderColor: Color = Color.green
    var borderWidth: CGFloat = 3.0
    var cornerSize: CGFloat = 30.0
    var cornerVisible: Bool = true

    @Binding var geometry: ResizeableBoxGeometry

    private func changedGeometry(_ translation: CGSize, for state: BoxState) -> ResizeableBoxGeometry {
        guard let mode = state.mode else {
            debugPrint("BUG: operate should never be called in .stopping")
            return geometry
        }
        switch mode {
        case .body:
            return state.transform(x: translation.width, y: translation.height)
        case .leftTop:
            return state.transform(width: -1 * translation.width, height: -1 * translation.height, x: translation.width, y: translation.height)
        case .rightTop:
            return state.transform(width: translation.width, height: -1 * translation.height, y: translation.height)
        case .rightBottom:
            return state.transform(width: translation.width, height: translation.height)
        case .leftBottom:
            return state.transform(width: -1 * translation.width, height: translation.height, x: translation.width)
        case .top:
            return state.transform(height: -1 * translation.height, y: translation.height)
        case .bottom:
            return state.transform(height: translation.height)
        case .left:
            return state.transform(width: -1 * translation.width, x: translation.width)
        case .right:
            return state.transform(width: translation.width)
        }
    }

    private func senseTouchOn(_ startLocation: CGPoint) -> BoxState.DraggingMode {
        // Gesture locations are all in global position
        let x = startLocation.x
        let y = startLocation.y
        // borders of touched area
        let top = geometry.origin.y + cornerSize
        let left = geometry.origin.x + cornerSize
        let right = geometry.origin.x + geometry.size.width - cornerSize
        let bottom = geometry.origin.y + geometry.size.height - cornerSize

        if x <= left && y <= top { return .leftTop }
        if x >= right && y <= top { return .rightTop }
        if x >= right && y >= bottom { return .rightBottom }
        if x <= left && y >= bottom { return .leftBottom }
        if x <= left { return .left }
        if x >= right { return .right }
        if y <= top { return .top }
        if y >= bottom { return .bottom }

        return .body
    }

    private func gesture() -> some Gesture {
        DragGesture()
            .onChanged{ value in
                let state = BoxStates.shared.state(name: self.name)
                if state.mode == nil {
                    let mode = senseTouchOn(value.startLocation)
                    state.start(mode: mode, size: self.geometry.size, origin: self.geometry.origin, minLength: cornerSize * 2)
                }
                self.geometry = changedGeometry(value.translation, for: state)
            }
            .onEnded{ value in
                let state = BoxStates.shared.state(name: self.name)
                self.geometry = changedGeometry(value.translation, for: state)
                state.stop()
            }
    }

    var body: some View {
        ZStack {
            CorneredBox(
                backgroundColor: backgroundColor,
                backgroundOpacity: backgroundOpacity,
                borderColor: borderColor,
                borderWidth: borderWidth,
                cornerSize: cornerSize,
                cornerVisible: cornerVisible,
                geometry: self.geometry,
                inPlaceCallback: { origin in
                    self.geometry = self.geometry.updateOrigin(origin: origin)
                }
            )

            // It's ok to specify geometry.position directly even when position is .zero
            // because it'll be replaced soon just after onAppear of CorneredBox
            Color.clear
                .contentShape(Rectangle()) // to make Color.clear touchable
                .frame(width: self.geometry.size.width, height: self.geometry.size.height)
                .position(self.geometry.position)
                .gesture(gesture())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ResizeableBox_Previews: PreviewProvider {
    @State static var geometry = ResizeableBoxGeometry(size: CGSize(width: 200, height: 200))

    static var previews: some View {
        ResizeableBox(name: "preview", geometry: $geometry)
    }
}
