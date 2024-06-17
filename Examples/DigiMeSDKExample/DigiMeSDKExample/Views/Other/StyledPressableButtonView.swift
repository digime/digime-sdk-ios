//
//  StyledPressableButtonView.swift
//  DigiMeSDKExample
//
//  Created on 16/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct StyledPressableButtonView: View {
    var text: String
    var iconSystemName: String?
    var iconName: String?
    var iconUrl: URL?
    var iconForegroundColor: Color
    var textForegroundColor: Color
    var backgroundColor: Color
    var requiredReauth = false
    var retryAfter: Date?
    var disclosureIndicator = false
    var isDisabled = false

    let action: () -> Void
    @State private var isPressed = false {
        didSet {
            if isPressed {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    // Ensure isPressed is still true before setting it to false to avoid overriding user re-presses
                    if self.isPressed {
                        self.isPressed = false
                    }
                }
            }
        }
    }

    private var image: Image? {
        if let iconSystemName = iconSystemName {
            return Image(systemName: iconSystemName)
        }
        else if let iconName = iconName {
            return Image(iconName)
        }
        else {
            return nil
        }
    }
    
    var body: some View {
        HStack {
            if let url = iconUrl {
                if url.pathExtension.lowercased() == "svg" {
                    SVGImageView(url: url, size: CGSize(width: 20, height: 20))
                        .frame(width: 20, height: 20, alignment: .center)
                }
                else {
                    SourceImage(url: url)
                        .frame(width: 20, height: 20, alignment: .center)
                }
            }
            else if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(isPressed ? .white : iconForegroundColor)
                    .frame(width: 20, height: 20, alignment: .center)
            }
            
            Text(text)
                .foregroundColor(isPressed ? .white : textForegroundColor)
            
            Spacer()
            
            status

            if disclosureIndicator {
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundColor(isPressed ? .white : .gray)
            }
        }
        .padding(12)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .background(fillColor)
        .cornerRadius(10)
        .overlay(
            GeometryReader { geometry in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isDisabled {
                                    self.isPressed = true
                                }
                            }
                            .onEnded { value in
                                if !isDisabled {
                                    // Check if the drag ended inside the view
                                    let location = value.location
                                    let frame = geometry.frame(in: .local)
                                    if frame.contains(location) {
                                        action()
                                    }
                                }

                                // Reset isPressed regardless of where the gesture ends
                                self.isPressed = false
                            }
                    )
            }
        )
    }

    private var status: some View {
        var textColor: Color = .red
        var textContent: String = ""

        if
            let retryAfter = retryAfter,
            retryAfter > Date() {

            textColor = Color(.systemGray)
            textContent = "Sync Paused"
        }
        else if requiredReauth {
            textContent = "Reauthorize"
        }
        else {
            textContent = ""
        }

        if isPressed {
            textColor = Color.white
        }

        return Text(textContent).foregroundColor(textColor)
    }

    private var fillColor: Color {
        return isPressed ? .accentColor : (syncPaused ? Color(.systemGray5) : backgroundColor)
    }

    private var syncPaused: Bool {
        return retryAfter?.compare(Date()) == .orderedDescending
    }
}

#Preview {
    ScrollView {
        StyledPressableButtonView(text: "Action Title",
                                  iconSystemName: "photo",
                                  iconForegroundColor: .gray,
                                  textForegroundColor: .accentColor,
                                  backgroundColor: Color(.secondarySystemGroupedBackground),
                                  requiredReauth: true,
                                  retryAfter: Date().adding(hours: 3)) {
        }
                                  .previewLayout(.sizeThatFits)
                                  .padding()

        StyledPressableButtonView(text: "Action Title",
                                  iconSystemName: "photo",
                                  iconForegroundColor: .gray,
                                  textForegroundColor: .accentColor,
                                  backgroundColor: Color(.secondarySystemGroupedBackground),
                                  requiredReauth: true) {
        }
                                  .previewLayout(.sizeThatFits)
                                  .padding()

        StyledPressableButtonView(text: "Action Title",
                                  iconSystemName: "photo",
                                  iconForegroundColor: .gray,
                                  textForegroundColor: .accentColor,
                                  backgroundColor: Color(.secondarySystemGroupedBackground)) {
        }
                                  .previewLayout(.sizeThatFits)
                                  .padding()
    }
    .background(.black)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
