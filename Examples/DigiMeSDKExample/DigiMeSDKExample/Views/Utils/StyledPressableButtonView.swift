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
    var disclosureIndicator = false
    
    let action: () -> Void
    @State private var isPressed: Bool = false
    
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
                SourceImage(url: url)
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
            
            if requiredReauth {
                Text("Reauthorize")
                    .foregroundColor(isPressed ? .white : .red)
            }
            
            if disclosureIndicator {
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundColor(isPressed ? .white : .gray)
            }
        }
        .padding(12)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .background(isPressed ? .accentColor : backgroundColor)
        .cornerRadius(10)
        .overlay(
            GeometryReader { geometry in
                Color.clear
                    .contentShape(Rectangle())                    
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ _ in self.isPressed = true })
                            .onEnded { value in
                                self.isPressed = false
                                // Check if the drag ended inside the view
                                let location = value.location
                                let frame = geometry.frame(in: .local)
                                if frame.contains(location) {
                                    action()
                                }
                            }
                    )
            }
        )
    }
}

struct StyledPressableButtonView_Previews: PreviewProvider {
    @State static var isPressed = false

    static var previews: some View {
        ScrollView {
            StyledPressableButtonView(text: "Action Title",
                               iconSystemName: "photo",
                               iconForegroundColor: .gray,
                               textForegroundColor: .accentColor,
                               backgroundColor: Color(.secondarySystemGroupedBackground),
                               action: {
            })
            .previewLayout(.sizeThatFits)
            .padding()
        }
        .background(.gray)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
