import TokmakUI

struct MyApp: App {
    @State private var enteredText = "Newton"

    mutating func visitProperties<V: PropertyVisitor>(_ visitor: inout V) {
        visitor.visit(&_enteredText)
    }

    var body: some Scene {
        WindowGroup {
            VStack {
                Text("Tokmak")
                    .foregroundColor(.black)

                Divider()

                Text("Monochrome control study")
                    .foregroundColor(Color(white: 0.4))

                HStack {
                    Text("Swatches")
                    Color.black
                    Color(white: 0.65)
                    Color.white
                }

                Group {
                    Button("Primary Action") {
                        print("Primary action")
                    }

                    Button("Secondary Action") {
                        print("Secondary action")
                    }
                }

                TextField("Name", text: $enteredText)

                Text("Typed: \(enteredText)")
                    .foregroundColor(Color(white: 0.4))

                ScrollView {
                    ForEach(0..<10) { index in
                        Text("Scroll row \(index)")
                    }
                }
                .frame(width: 520, height: 120)

                Spacer()

                Text("Target: pixelated BW e-paper")
                    .foregroundColor(Color(white: 0.4))
            }
            .padding(18)
            .frame(width: 720, height: 420)
        }
    }
}

MyApp.main()
