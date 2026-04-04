import SwiftUI

struct CompassView: View {
    @StateObject private var viewModel = CompassViewModel()
    @State private var radarSweepAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.4

    private let springAnimation = Animation.interpolatingSpring(stiffness: 80, damping: 12)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else {
                compassView
            }
        }
        .onAppear {
            viewModel.start()
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                radarSweepAngle = 360
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.06
                glowIntensity = 0.7
            }
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 14) {
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(
                            Color.tacoBellPurple.opacity(0.15 - Double(i) * 0.04),
                            lineWidth: 1
                        )
                        .frame(width: CGFloat(40 + i * 28), height: CGFloat(40 + i * 28))
                        .scaleEffect(pulseScale)
                }

                RadarSweep()
                    .fill(
                        AngularGradient(
                            colors: [.clear, Color.tacoBellHotPink.opacity(0.5)],
                            center: .center
                        )
                    )
                    .frame(width: 96, height: 96)
                    .rotationEffect(.degrees(radarSweepAngle))

                Text("🌮")
                    .font(.system(size: 24))
                    .shadow(color: Color.tacoBellNeon.opacity(0.8), radius: 6)
            }

            Text("SCANNING")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.tacoBellLightPurple)
                .opacity(glowIntensity)
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "xmark.octagon.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.tacoBellHotPink)
                .shadow(color: Color.tacoBellHotPink.opacity(0.5), radius: 8)

            Text(message)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.tacoBellLightPurple)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }

    // MARK: - Compass

    private var compassView: some View {
        VStack(spacing: 2) {
            Text(viewModel.tacoBellName.uppercased())
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.tacoBellHotPink.opacity(0.6))
                .lineLimit(1)
                .tracking(1.5)
                .padding(.horizontal, 4)

            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.tacoBellPurple.opacity(0.15),
                                Color.tacoBellDeepViolet.opacity(0.8),
                                Color.black
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                // Outer glow ring
                Circle()
                    .stroke(Color.tacoBellNeon.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 140, height: 140)
                    .shadow(color: Color.tacoBellNeon.opacity(0.1), radius: 6)

                // Rotating compass dial (N/S/E/W, ticks, rings)
                compassDial

                // Needle — always points straight up (shows your heading direction)
                CompassNeedle()
                    .fill(
                        LinearGradient(
                            colors: [Color.tacoBellHotPink, Color.tacoBellPurple],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 14, height: 44)
                    .shadow(color: Color.tacoBellHotPink.opacity(0.5), radius: 8)

                // Alignment chevron at top
                AlignChevron()
                    .fill(viewModel.isOnTarget ? Color.tacoBellHotPink : Color.tacoBellHotPink.opacity(0.3))
                    .frame(width: 10, height: 6)
                    .shadow(color: viewModel.isOnTarget ? Color.tacoBellHotPink.opacity(0.8) : .clear, radius: 4)
                    .offset(y: -66)

                // Taco marker on the perimeter
                tacoMarker

                // Center hub
                ZStack {
                    Circle()
                        .fill(Color.tacoBellDeepViolet)
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(Color.tacoBellHotPink)
                        .frame(width: 6, height: 6)
                        .shadow(color: Color.tacoBellHotPink.opacity(0.8), radius: 4)
                }
            }
            .frame(width: 140, height: 140)

            // Distance
            HStack(spacing: 4) {
                Text(formattedDistance)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.tacoBellNeon],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text(distanceUnit)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.tacoBellLightPurple.opacity(0.6))
                    .offset(y: 2)
            }

            // Tagline
            Text(viewModel.isOnTarget ? "🌮 ON TARGET 🌮" : "TACO RADAR ACTIVE")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundStyle(viewModel.isOnTarget ? Color.tacoBellHotPink.opacity(0.8) : Color.tacoBellHotPink.opacity(0.4))
                .tracking(2)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isOnTarget)
        }
    }

    // MARK: - Compass Dial (rotates with heading)

    private var compassDial: some View {
        ZStack {
            // Radar rings
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .stroke(
                        Color.tacoBellPurple.opacity(i == 3 ? 0.2 : 0.12),
                        lineWidth: i == 3 ? 1 : 0.5
                    )
                    .frame(width: CGFloat(30 + i * 24), height: CGFloat(30 + i * 24))
            }

            // Tick marks
            CompassTicks()
                .stroke(Color.tacoBellPurple.opacity(0.3), lineWidth: 0.5)
                .frame(width: 118, height: 118)

            // Bold major ticks
            CompassMajorTicks()
                .stroke(Color.tacoBellNeon.opacity(0.35), lineWidth: 1.5)
                .frame(width: 118, height: 118)

            // Cardinal labels
            cardinalLabel("N", angle: 0, color: Color.tacoBellHotPink, glow: true)
            cardinalLabel("E", angle: 90, color: Color.tacoBellLightPurple.opacity(0.5), glow: false)
            cardinalLabel("S", angle: 180, color: Color.tacoBellLightPurple.opacity(0.5), glow: false)
            cardinalLabel("W", angle: 270, color: Color.tacoBellLightPurple.opacity(0.5), glow: false)
        }
        .rotationEffect(Angle(degrees: -viewModel.headingAngle))
        .animation(springAnimation, value: viewModel.headingAngle)
    }

    private func cardinalLabel(_ letter: String, angle: Double, color: Color, glow: Bool) -> some View {
        Text(letter)
            .font(.system(size: 11, weight: .black, design: .monospaced))
            .foregroundStyle(color)
            .shadow(color: glow ? Color.tacoBellHotPink.opacity(0.5) : .clear, radius: glow ? 4 : 0)
            .rotationEffect(Angle(degrees: viewModel.headingAngle))
            .animation(springAnimation, value: viewModel.headingAngle)
            .offset(y: -56)
            .rotationEffect(Angle(degrees: angle))
    }

    // MARK: - Taco Marker

    private var tacoMarker: some View {
        Text("🌮")
            .font(.system(size: viewModel.isOnTarget ? 24 : 20))
            .shadow(
                color: viewModel.isOnTarget
                    ? Color.tacoBellHotPink.opacity(0.9)
                    : Color.tacoBellNeon.opacity(0.7),
                radius: viewModel.isOnTarget ? 14 : 8
            )
            .shadow(
                color: viewModel.isOnTarget
                    ? Color.tacoBellHotPink.opacity(0.4)
                    : .clear,
                radius: 24
            )
            .offset(y: -62)
            .rotationEffect(Angle(degrees: viewModel.tacoRelativeAngle))
            .animation(springAnimation, value: viewModel.tacoRelativeAngle)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isOnTarget)
    }

    // MARK: - Formatting

    private var formattedDistance: String {
        let miles = viewModel.distance / 1609.34
        if miles < 0.1 {
            let feet = viewModel.distance * 3.28084
            return String(format: "%.0f", feet)
        } else {
            return String(format: "%.1f", miles)
        }
    }

    private var distanceUnit: String {
        let miles = viewModel.distance / 1609.34
        return miles < 0.1 ? "FT" : "MI"
    }
}

// MARK: - Shapes

struct CompassNeedle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let tipY = rect.minY
        let baseY = rect.maxY

        path.move(to: CGPoint(x: midX, y: tipY))
        path.addQuadCurve(
            to: CGPoint(x: midX + 6, y: rect.midY + 4),
            control: CGPoint(x: midX + 4, y: tipY + 10)
        )
        path.addLine(to: CGPoint(x: midX + 2, y: baseY))
        path.addLine(to: CGPoint(x: midX - 2, y: baseY))
        path.addLine(to: CGPoint(x: midX - 6, y: rect.midY + 4))
        path.addQuadCurve(
            to: CGPoint(x: midX, y: tipY),
            control: CGPoint(x: midX - 4, y: tipY + 10)
        )
        path.closeSubpath()
        return path
    }
}

struct AlignChevron: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct RadarSweep: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(-30),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

struct CompassTicks: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius - 3

        for i in 0..<72 {
            if i % 6 == 0 { continue } // Skip major ticks (drawn separately)
            let angle = Double(i) * 5.0 - 90
            let radians = angle * .pi / 180

            let outer = CGPoint(
                x: center.x + CGFloat(cos(radians)) * outerRadius,
                y: center.y + CGFloat(sin(radians)) * outerRadius
            )
            let inner = CGPoint(
                x: center.x + CGFloat(cos(radians)) * innerRadius,
                y: center.y + CGFloat(sin(radians)) * innerRadius
            )
            path.move(to: outer)
            path.addLine(to: inner)
        }
        return path
    }
}

struct CompassMajorTicks: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius - 6

        for i in 0..<12 {
            let angle = Double(i) * 30.0 - 90
            let radians = angle * .pi / 180

            let outer = CGPoint(
                x: center.x + CGFloat(cos(radians)) * outerRadius,
                y: center.y + CGFloat(sin(radians)) * outerRadius
            )
            let inner = CGPoint(
                x: center.x + CGFloat(cos(radians)) * innerRadius,
                y: center.y + CGFloat(sin(radians)) * innerRadius
            )
            path.move(to: outer)
            path.addLine(to: inner)
        }
        return path
    }
}
