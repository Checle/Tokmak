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




public protocol ListStyle {}

public struct PlainListStyle: ListStyle {
  public init() {}
}

public extension ListStyle where Self == PlainListStyle {
  static var plain: PlainListStyle { PlainListStyle() }
}

public struct List<Content: View>: View {
  public let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: Content {
    content
  }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitList(self)
  }


}

public extension List {
  func listStyle<S: ListStyle>(_ style: S) -> Self {
    self
  }

  init<Data: RandomAccessCollection, ID: Hashable, RowContent: View>(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  ) where Content == ForEach<Data, ID, RowContent> {
    self.content = ForEach(data, id: id, content: rowContent)
  }

  init<Data: RandomAccessCollection, RowContent: View>(
    _ data: Data,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  ) where Data.Element: Identifiable, Content == ForEach<Data, Data.Element.ID, RowContent> {
    self.content = ForEach(data, content: rowContent)
  }
}
