import TokmakUI

struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      VStack {
        Text("Hello ESP-IDF!")
        Spacer()
        Button("Refresh") {
        }
      }
      .padding(20)
      .frame(width: 240, height: 416)
    }
  }
}

@_cdecl("tokmak_swift_main")
public func tokmak_swift_main() {
  MyApp.main()
}
