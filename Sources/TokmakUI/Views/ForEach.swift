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

/// A collection-backed container that expands into its child views.
///
/// The current reconciler is still position-based, so `id` is accepted for API
/// compatibility and future keyed reconciliation, but child moves are not yet
/// matched by identity.
public struct ForEach<Data, ID, Content>: View
  where Data: RandomAccessCollection, ID: Hashable, Content: View
{
  public let data: Data
  let id: KeyPath<Data.Element, ID>
  let content: (Data.Element) -> Content

  public init(
    _ data: Data,
    id: KeyPath<Data.Element, ID>,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.data = data
    self.id = id
    self.content = content
  }

  public var body: _ForEachContent<Data, Content> {
    _ForEachContent(data: data, content: content)
  }
}

public extension ForEach where Data.Element: Identifiable, ID == Data.Element.ID {
  init(
    _ data: Data,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.init(data, id: \.id, content: content)
  }
}

public extension ForEach where Data == Range<Int>, ID == Int {
  init(
    _ data: Range<Int>,
    @ViewBuilder content: @escaping (Int) -> Content
  ) {
    self.init(data, id: \.self, content: content)
  }
}

public struct _ForEachContent<Data, Content>: _PrimitiveView
  where Data: RandomAccessCollection, Content: View
{
  let data: Data
  let content: (Data.Element) -> Content

  public var body: Never {
    neverBody("_ForEachContent")
  }

  public func walk<V: ViewWalker>(_ visitor: inout V) {
    for element in data {
      content(element).walk(&visitor)
    }
  }
}

extension _ForEachContent: GroupView {
  public var children: [AnyView] {
    data.map { AnyView(content($0)) }
  }
}
