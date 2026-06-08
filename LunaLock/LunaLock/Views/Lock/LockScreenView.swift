import SwiftUI

struct LockScreenView: View {
    @StateObject private var security = SecurityManager.shared
    @State private var pinCode = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var showError = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "1A0033"), Color(hex: "7C4DFF").opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color(hex: "7C4DFF"))
                    .padding(.top, 80)

                Text("LunaLock")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                if security.lockMethod == .faceID {
                    Button(action: authenticateWithBiometrics) {
                        VStack(spacing: 12) {
                            Image(systemName: "faceid")
                                .font(.system(size: 44))
                            Text("Tap to Unlock")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 140, height: 140)
                        .background(Circle().fill(Color(hex: "7C4DFF").opacity(0.3)))
                    }
                } else {
                    VStack(spacing: 20) {
                        HStack(spacing: 16) {
                            ForEach(0..<4, id: \.self) { index in
                                Circle()
                                    .fill(index < pinCode.count ? Color.white : Color.white.opacity(0.2))
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .offset(x: shakeOffset)

                        if showError {
                            Text("Incorrect PIN")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                            ForEach(1...9, id: \.self) { num in
                                pinButton("\(num)") { appendPIN("\(num)") }
                            }
                            pinButton("") {}
                            pinButton("0") { appendPIN("0") }
                            Button(action: {
                                if !pinCode.isEmpty {
                                    pinCode.removeLast()
                                }
                            }) {
                                Image(systemName: "delete.left")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }

                Spacer()
            }
        }
    }

    private func pinButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Circle().fill(Color.white.opacity(0.15)))
        }
    }

    private func appendPIN(_ digit: String) {
        guard pinCode.count < 4 else { return }
        pinCode.append(digit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if pinCode.count == 4 {
            if security.verifyPIN(pinCode) {
                security.isLocked = false
            } else {
                showError = true
                withAnimation(.default) {
                    shakeOffset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.default) {
                        shakeOffset = -10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.default) {
                            shakeOffset = 0
                        }
                    }
                }
                pinCode = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showError = false
                }
            }
        }
    }

    private func authenticateWithBiometrics() {
        security.authenticate { success in }
    }
}
