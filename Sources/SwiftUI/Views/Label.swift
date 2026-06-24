public struct Label<Title: View, Icon: View>: View {
 public let title: Title
 public let icon: Icon

 public init(@ViewBuilder title: () -> Title, @ViewBuilder icon: () -> Icon) {
  self.title = title()
  self.icon = icon()
 }

 public var body: some View {
  HStack {
   icon
   title
  }
 }
}

public extension Label where Title == Text, Icon == Image {
 init<S>(_ title: S, systemImage name: String) where S: StringProtocol {
  self.init(title: { Text(String(title)) }, icon: { Image(systemName: name) })
 }
}
