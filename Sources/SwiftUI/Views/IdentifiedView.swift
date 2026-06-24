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


public struct TokmakIdentityKey: Hashable {
  private enum Storage: Hashable {
    case int(Int)
    case uint(UInt)
    case string(String)
    case bool(Bool)
    case raw(valueHash: Int)
  }

  private let storage: Storage

  public init(_ value: Int) {
    storage = .int(value)
  }

  public init(_ value: UInt) {
    storage = .uint(value)
  }

  public init(_ value: String) {
    storage = .string(value)
  }

  public init(_ value: Bool) {
    storage = .bool(value)
  }

  public init<ID: Hashable>(_ value: ID) {
    var valueHasher = Hasher()
    value.hash(into: &valueHasher)
    storage = .raw(valueHash: valueHasher.finalize())
  }
}

public struct _IdentifiedView<Content: View>: View {
  let content: Content
  public let scrollTargetID: TokmakIdentityKey?

  public var reconciliationIdentity: TokmakIdentityKey? {
    scrollTargetID
  }

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitIdentifiedView(self)
  }


}

public extension View {
  func id<ID>(_ id: ID) -> some View where ID: Hashable {
    _IdentifiedView(content: self, scrollTargetID: TokmakIdentityKey(id))
  }
}
