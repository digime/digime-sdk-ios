//
//  NotifyBannerView.swift
//  DigiMeSDKExample
//
//  Created on 10/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

struct NotifyBannerView: View {
    var type: NotifyBannerStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: type.iconFileName)
                    .foregroundColor(type.themeColor)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer(minLength: 10)

                Button {
                    onCancelTapped()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.primary)
                }
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .overlay(
            Rectangle()
                .fill(type.themeColor)
                .frame(width: 6)
                .clipped()
            , alignment: .leading
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}

struct NotifyBannerModifier: ViewModifier {
    @Binding var toast: NotifyBanner?
    @State private var workItem: DispatchWorkItem?

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: -30)
                }.animation(.spring(), value: toast)
            )
            .onChange(of: toast) { _, _ in
                showToast()
            }
    }

    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer()
                NotifyBannerView(type: toast.type, title: toast.title, message: toast.message) {
                    dismissToast()
                }
            }
            .transition(.move(edge: .bottom))
        }
    }

    private func showToast() {
        guard let toast = toast else {
            return
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if toast.duration > 0 {
            workItem?.cancel()

            let task = DispatchWorkItem {
                dismissToast()
            }

            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }

    private func dismissToast() {
        withAnimation {
            toast = nil
        }

        workItem?.cancel()
        workItem = nil
    }
}

struct NotifyBanner: Equatable {
    var type: NotifyBannerStyle
    var title: String
    var message: String
    var duration: Double = 3
}

enum NotifyBannerStyle {
    case error
    case warning
    case success
    case info
}

extension NotifyBannerStyle {
    var themeColor: Color {
        switch self {
        case .error:
            return Color.red
        case .warning:
            return Color.orange
        case .info:
            return Color.blue
        case .success:
            return Color.green
        }
    }

    var iconFileName: String {
        switch self {
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        }
    }
}

extension View {
    func bannerView(toast: Binding<NotifyBanner?>) -> some View {
        self.modifier(NotifyBannerModifier(toast: toast))
    }
}

#Preview {
    VStack {
        NotifyBannerView(
            type: .error,
            title: "Error",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ") {}

        NotifyBannerView(
            type: .warning,
            title: "Warning",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ") {}

        NotifyBannerView(
            type: .info,
            title: "Info",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ") {}

        NotifyBannerView(
            type: .success,
            title: "Success",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ") {}
    }
}
