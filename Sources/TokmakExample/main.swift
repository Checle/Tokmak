import TokmakUI

struct MyApp: App {
    @State private var enteredText = "Newton"
    @State private var showsUnavailable = false

    mutating func visitProperties<V: PropertyVisitor>(_ visitor: inout V) {
        visitor.visit(&_enteredText)
        visitor.visit(&_showsUnavailable)
    }

    var body: some Scene {
        WindowGroup {
            ScrollViewReader { proxy in
                VStack {
                    Text("Tokmak")
                        .foregroundColor(.black)

                    Divider()

                    Text("Monochrome control study")
                        .foregroundColor(Color(white: 0.4))

                    HStack {
                        Image.system(Image.Symbol.directory)
                        Text("Swatches")
                        Color.black
                        Color(white: 0.65)
                        Color.white
                    }

                    Group {
                        Button("Jump to Last Row") {
                            proxy.scrollTo(9)
                        }

                        Button("Jump to First Row") {
                            proxy.scrollTo(0)
                        }

                        Button(showsUnavailable ? "Show Rows" : "Show Empty State") {
                            showsUnavailable.toggle()
                        }
                    }

                    TextField("Name", text: $enteredText)

                    Text("Typed: \(enteredText)")
                        .foregroundColor(Color(white: 0.4))

                    Group {
                        if showsUnavailable {
                            ContentUnavailableView(
                                "No Notes Yet",
                                description: "This e-paper dashboard has nothing to render in the current filter."
                            ) {
                                Button("Restore Content") {
                                    showsUnavailable = false
                                }
                            }
                        } else {
                            ScrollView {
                                ForEach(0..<10) { index in
                                    Text("Scroll row \(index)")
                                        .id(index)
                                }
                            }
                            .frame(width: 520, height: 120)
                        }
                    }

                    Group {
                        Spacer()

                        Text("Target: pixelated BW e-paper")
                            .foregroundColor(Color(white: 0.4))
                    }
                }
                .padding(18)
                .frame(width: 720, height: 420)
            }
        }
    }
}

MyApp.main()
