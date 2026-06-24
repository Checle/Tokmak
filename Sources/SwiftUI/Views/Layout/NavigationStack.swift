// Copyright 2026 Checle LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.




public struct NavigationStack<Content: View>: View {
  public let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: Content {
    content
  }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitNavigationStack(self)
  }


}

public struct NavigationLink<Label: View, Destination: View>: View {
  public let destination: Destination
  public let label: Label

  public init(destination: Destination, @ViewBuilder label: () -> Label) {
    self.destination = destination
    self.label = label()
  }

  public var body: Label {
    label
  }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitNavigationLink(self)
  }


}

public extension View {
  func navigationTitle(_ title: String) -> some View {
    self
  }
}
