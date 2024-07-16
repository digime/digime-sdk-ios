
import SwiftUI

public struct ContentView4: View {
    public init() {
    }
    public var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("locKey".localized())
        }
        .padding()
    }
}

#Preview {
    ContentView4()
}

