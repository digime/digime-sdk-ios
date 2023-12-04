//
//  SectionView.swift
//  DigiMeSDKExample
//
//  Created on 15/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct SectionView<Content: View>: View {
    let header: String?
    let footer: String?
    let content: Content

    init(header: String? = nil, footer: String? = nil, @ViewBuilder content: () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let header = header {
                Text(header)
                    .padding(.horizontal, 20)
                    .textCase(.uppercase)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            content
            
            if let footer = footer {
                Text(footer)
                    .padding(.horizontal, 20)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SectionView(header: "Section Header", footer: "Section Footer") {
        VStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.systemGray4))
                .frame(height: 100)
        }
        .frame(maxWidth: .infinity)
    }
    .previewLayout(.sizeThatFits)
}
