//
//  InfoMessageView.swift
//  DigiMeSDKExample
//
//  Created by Alex Hamilton on 18/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct InfoMessageView: View {
    @State var message: String
    @State var foregroundColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(.callout)
                    .foregroundColor(foregroundColor)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    InfoMessageView(message: "Unhandled error has occurred...", foregroundColor: .red)
}
