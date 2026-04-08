import TokmakUI

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                Text("Hello Tokmak!")
                Spacer()
                Button("Click Me") {
                    print("Button clicked!")
                }
            }
            .padding(20)
            .frame(width: 400, height: 300)
        }
    }
}

MyApp.main()