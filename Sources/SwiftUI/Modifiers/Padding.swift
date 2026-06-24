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


public struct _PaddingLayout: ViewModifier {
  public let edges: Edge.Set
  public let insets: EdgeInsets?

  public init(edges: Edge.Set = .all, insets: EdgeInsets? = nil) {
    self.edges = edges
    self.insets = insets
  }

  public func body(content: Content) -> some View {
    _PaddingView(content: content, edges: edges, insets: insets)
  }
}

public struct _PaddingView<Content: View>: View {
  public let content: Content
  public let edges: Edge.Set
  public let insets: EdgeInsets?

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitPaddingView(self)
  }


}

public extension View {
  func padding(_ insets: EdgeInsets) -> some View {
    modifier(_PaddingLayout(insets: insets))
  }

  func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
    let insets = length.map { EdgeInsets(_all: $0) }
    return modifier(_PaddingLayout(edges: edges, insets: insets))
  }

  func padding(_ length: CGFloat) -> some View {
    padding(.all, length)
  }
}
