import SwiftUI

struct StartView: View {
    var onStart: () -> Void

    @State private var ringScale: CGFloat = 0.85
    @State private var outerGlow: CGFloat = 0.3
    @State private var ringRotation: Double = 0
    @State private var tacoWobble: Double = -4

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Ambient background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.tacoBellDeepViolet.opacity(0.5),
                            Color.black
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(ringScale)

            VStack(spacing: 12) {
                Button(action: onStart) {
                    ZStack {
                        // Outer pulsing rings
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(
                                    Color.tacoBellHotPink.opacity(0.12 - Double(i) * 0.03),
                                    lineWidth: 1
                                )
                                .frame(
                                    width: CGFloat(84 + i * 18),
                                    height: CGFloat(84 + i * 18)
                                )
                                .scaleEffect(ringScale)
                        }

                        // Rotating dashed orbit
                        Circle()
                            .stroke(
                                Color.tacoBellNeon.opacity(0.2),
                                style: StrokeStyle(lineWidth: 0.5, dash: [2, 6])
                            )
                            .frame(width: 110, height: 110)
                            .rotationEffect(.degrees(ringRotation))

                        // Main button circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 139/255, green: 59/255, blue: 181/255),
                                        Color.tacoBellPurple,
                                        Color.tacoBellDeepViolet
                                    ],
                                    center: .init(x: 0.4, y: 0.4),
                                    startRadius: 0,
                                    endRadius: 43
                                )
                            )
                            .frame(width: 86, height: 86)
                            .shadow(color: Color.tacoBellPurple.opacity(outerGlow), radius: 20)

                        // Inner ring
                        Circle()
                            .stroke(Color.tacoBellHotPink.opacity(0.3), lineWidth: 2)
                            .frame(width: 86, height: 86)

                        // Taco emoji
                        Text("🌮")
                            .font(.system(size: 36))
                            .shadow(color: Color.tacoBellNeon.opacity(0.8), radius: 10)
                            .rotationEffect(.degrees(tacoWobble))
                    }
                }
                .buttonStyle(.plain)

                // Label
                VStack(spacing: 2) {
                    Text("FIND")
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color.tacoBellLightPurple.opacity(0.5))
                        .tracking(6)

                    Text("TACO BELL")
                        .font(.system(size: 15, weight: .black, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.tacoBellHotPink, Color.tacoBellNeon, Color.tacoBellHotPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                ringScale = 1.0
                outerGlow = 0.6
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                tacoWobble = 4
            }
        }
    }
}
