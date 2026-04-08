// Copyright 2020-2021 Tokamak contributors
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
//
//  Created by Max Desiatov on 08/04/2020.
//

/// A type-erased view.
#if hasFeature(Embedded)
public struct AnyView: _PrimitiveView {
  public init<V>(_ view: V) where V: View {}

  public func walk<V: ViewWalker>(_ visitor: inout V) {
    fatalError("AnyView is unavailable in embedded builds.")
  }
}

public func mapAnyView<T, V>(_ anyView: AnyView, transform: (V) -> T) -> T? {
  nil
}

extension AnyView: ParentView {
  @_spi(TokmakUI)
  public var children: [AnyView] { [] }
}

public struct _AnyViewProxy {
  public var subject: AnyView

  public init(_ subject: AnyView) { self.subject = subject }
}
#else
public struct AnyView: _PrimitiveView {
  /// The type of the underlying `view`.
  let type: Any.Type

  /// The actual `View` value wrapped within this `AnyView`.
  var view: Any

  /** Type-erased `body` of the underlying `view`. Needs to take a fresh version of `view` as an
   argument, otherwise it captures an old value of the `body` property.
   */
  let walkClosure: (inout any ViewWalker, Any) -> ()

  public init<V>(_ view: V) where V: View {
    if let anyView = view as? AnyView {
      self = anyView
    } else {
      type = V.self
      self.view = view

      walkClosure = { visitor, view in
        var v = visitor
        (view as! V).walk(&v)
        visitor = v
      }
    }
  }

  public func walk<V: ViewWalker>(_ visitor: inout V) {
    var anyVisitor: any ViewWalker = visitor
    walkClosure(&anyVisitor, view)
    visitor = anyVisitor as! V
  }
}

public func mapAnyView<T, V>(_ anyView: AnyView, transform: (V) -> T) -> T? {
  guard let view = anyView.view as? V else { return nil }

  return transform(view)
}

extension AnyView: ParentView {
  @_spi(TokmakUI)
  public var children: [AnyView] {
    (view as? ParentView)?.children ?? []
  }
}

public struct _AnyViewProxy {
  public var subject: AnyView

  public init(_ subject: AnyView) { self.subject = subject }

  public var type: Any.Type { subject.type }
  public var view: Any { subject.view }
}
#endif
