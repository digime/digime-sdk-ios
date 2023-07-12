//
//  ScopeDateButton.swift
//  DigiMeSDKExample
//
//  Created on 11/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ScopeDateButton<Content: View>: View {
    @Binding var showModal: Bool
    @Binding var date: Date?
    
    var formatter: DateFormatter
    var actionButtonTitle: String
    var imageIcon: Content
    
    var body: some View {
        Button {
            showModal.toggle()
        } label: {
            HStack {
                imageIcon
                    .frame(width: 30, height: 30, alignment: .center)
                Text(actionButtonTitle)
                Spacer()
                if let date = date {
                    Text(formatter.string(from: date))
                        .foregroundColor(.gray)
                }
                else {
                    Text(ScopeAddView.datePlaceholder)
                        .foregroundColor(.gray)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .foregroundColor(.primary)
    }
}

struct ScopeDateButton_Previews: PreviewProvider {
    static var previews: some View {
        ScopeDateButton(showModal: .constant(true), date: .constant(Date()), formatter: DateFormatter(), actionButtonTitle: "Title", imageIcon: Image(systemName: "calendar.badge.clock"))
    }
}
