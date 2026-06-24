import SwiftUI
import TokmakDOM

struct Counter: View {
  @State private var count = 0

  var body: some View {
    VStack {
      Text("Tokmak")
        .bold()
      Text("Count: \(count)")
      Button("Increment") {
        count += 1
      }
    }
    .padding()
  }
}

@_cdecl("tokmak_start")
public func start() {
  mount(Counter())
}
