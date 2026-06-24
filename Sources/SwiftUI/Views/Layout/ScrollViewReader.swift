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

#if hasFeature(Embedded)
public struct ScrollViewProxy {
  public func scrollTo<ID>(_ id: ID) where ID: Hashable {}
  public func scrollTo<ID>(_ id: ID, anchor: UnitPoint?) where ID: Hashable {}
}

public struct ScrollViewReader<Content: View>: View {
  let content: (ScrollViewProxy) -> Content

  public init(@ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
    self.content = content
  }

  public var body: Content {
    content(ScrollViewProxy())
  }
}
#else
public struct ScrollViewProxy {
  public static var scrollHandler: ((AnyHashable) -> Void)?

  public func scrollTo<ID>(_ id: ID) where ID: Hashable {
    Self.scrollHandler?(id)
  }

  public func scrollTo<ID>(_ id: ID, anchor: UnitPoint?) where ID: Hashable {
    Self.scrollHandler?(id)
  }
}

public struct ScrollViewReader<Content: View>: View {
  let content: (ScrollViewProxy) -> Content

  public init(@ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
    self.content = content
  }

  public var body: Content {
    content(ScrollViewProxy())
  }
}
#endif
