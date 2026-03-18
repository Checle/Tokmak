// Copyright 2020 Tokamak contributors
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

public struct TupleView<T>: _PrimitiveView, View {
  public let value: T

  public init(_ value: T) {
    self.value = value
  }

  public init<T1, T2>(_ v1: T1, _ v2: T2) where T == (T1, T2) {
    value = (v1, v2)
  }

  public init<T1, T2, T3>(_ v1: T1, _ v2: T2, _ v3: T3) where T == (T1, T2, T3) {
    value = (v1, v2, v3)
  }

  public init<T1, T2, T3, T4>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4) where T == (T1, T2, T3, T4) {
    value = (v1, v2, v3, v4)
  }

  public init<T1, T2, T3, T4, T5>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5) where T == (T1, T2, T3, T4, T5) {
    value = (v1, v2, v3, v4, v5)
  }

  public init<T1, T2, T3, T4, T5, T6>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6) where T == (T1, T2, T3, T4, T5, T6) {
    value = (v1, v2, v3, v4, v5, v6)
  }

  public init<T1, T2, T3, T4, T5, T6, T7>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6, _ v7: T7) where T == (T1, T2, T3, T4, T5, T6, T7) {
    value = (v1, v2, v3, v4, v5, v6, v7)
  }

  public init<T1, T2, T3, T4, T5, T6, T7, T8>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6, _ v7: T7, _ v8: T8) where T == (T1, T2, T3, T4, T5, T6, T7, T8) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8)
  }

  public init<T1, T2, T3, T4, T5, T6, T7, T8, T9>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6, _ v7: T7, _ v8: T8, _ v9: T9) where T == (T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8, v9)
  }

  public init<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>(_ v1: T1, _ v2: T2, _ v3: T3, _ v4: T4, _ v5: T5, _ v6: T6, _ v7: T7, _ v8: T8, _ v9: T9, _ v10: T10) where T == (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
    value = (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
  }

  public func walk<V: ViewWalker>(_ visitor: inout V) {
    if let v = value as? (any View, any View) {
      walkAny(v.0, &visitor)
      walkAny(v.1, &visitor)
    } else if let v = value as? (any View, any View, any View) {
      walkAny(v.0, &visitor)
      walkAny(v.1, &visitor)
      walkAny(v.2, &visitor)
    } else if let v = value as? (any View, any View, any View, any View) {
      walkAny(v.0, &visitor)
      walkAny(v.1, &visitor)
      walkAny(v.2, &visitor)
      walkAny(v.3, &visitor)
    } else if let v = value as? (any View, any View, any View, any View, any View) {
      walkAny(v.0, &visitor)
      walkAny(v.1, &visitor)
      walkAny(v.2, &visitor)
      walkAny(v.3, &visitor)
      walkAny(v.4, &visitor)
    } else if let v = value as? (any View, any View, any View, any View, any View, any View) {
      walkAny(v.0, &visitor)
      walkAny(v.1, &visitor)
      walkAny(v.2, &visitor)
      walkAny(v.3, &visitor)
      walkAny(v.4, &visitor)
      walkAny(v.5, &visitor)
    } else if let v = value as? any View {
      walkAny(v, &visitor)
    }
  }
}

func walkAny<V: ViewWalker>(_ view: Any, _ visitor: inout V) {
  if let view = view as? any View {
    view.walk(&visitor)
  }
}
