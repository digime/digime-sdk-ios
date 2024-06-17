//
//  MemoryIntensiveView.swift
//  DigiMeSDKExample
//
//  Created on 12/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

struct MemoryIntensiveView: View {

    @StateObject var memoryIntensiveInstance = MemoryIntensiveClass()

    var body: some View {
        VStack {
            Text("Objects created: \(memoryIntensiveInstance.result)")
                .padding()

            Button {
                memoryIntensiveInstance.allocateMemoryObjects {
                }
            } label: {
                Text("Allocate Memory")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
        }
        .padding()
    }
}
