//
//  HealthDataProgressView.swift
//  DigiMePlugin
//
//  Created on 09/09/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI
import SwiftData

struct HealthDataProgressView: View {
    @ObservedObject private var viewModel: HealthDataViewModel
    @Environment(\.colorScheme) private var colorScheme

    @Binding private var actionTitle: String
    @Binding private var isPresented: Bool
    private let onDismiss: () -> Void

    @State private var offset: CGFloat = 1000

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private static let intervalFormatter: DateComponentsFormatter = {
        let fm = DateComponentsFormatter()
        fm.allowedUnits = [.hour, .minute, .second]
        fm.unitsStyle = .abbreviated
        fm.zeroFormattingBehavior = .pad
        return fm
    }()

    init(viewModel: HealthDataViewModel, actionTitle: Binding<String>, isPresented: Binding<Bool>, onDismiss: @escaping () -> Void) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _actionTitle = actionTitle
        _isPresented = isPresented
        self.onDismiss = onDismiss
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        dismissView()
                    }

                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding(.top)

                    Text(actionTitle)
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    if viewModel.isExporting {
                        Text("elapsedTime".localized(with: Self.intervalFormatter.string(from: viewModel.importElapsedTime) ?? "0"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    else {
                        Text("elapsedTime".localized(with: Self.intervalFormatter.string(from: viewModel.exportElapsedTime) ?? "0"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    Button(action: {
                        dismissView()
                    }) {
                        Text("View Details")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(.accentColor)
                }
                .padding()
                .frame(width: min(geometry.size.width * 0.9, 300))
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), radius: 20, y: 10)
                .offset(y: offset)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .opacity(isPresented ? 1 : 0)
        .animation(.spring(), value: offset)
        .onAppear() {
            viewModel.resetElapsedTime()
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                withAnimation {
                    offset = 0
                }
            }
        }
        .onReceive(timer) { _ in
            if isPresented {
                viewModel.updateElapsedTime()
            }
        }
    }

    private func dismissView() {
        withAnimation {
            offset = 1000
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
            isPresented = false
        }
    }
}
