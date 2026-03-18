// Copyright 2020 Tokamak contributors
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
protocol ValueStorage {
  var getter: (() -> Any)? { get set }
  var anyInitialValue: Any { get }
}

protocol WritableValueStorage: ValueStorage {
  var setter: ((Any, Transaction) -> ())? { get set }
}
public protocol StateProtocol {
  mutating func _link(to fiber: any AnyFiber, at index: Int, redraw: @escaping () -> ())
}

@propertyWrapper
public struct State<Value>: DynamicProperty, StateProtocol {
  private let initialValue: Value

  var anyInitialValue: Any { initialValue }

  var getter: (() -> Any)?
  var setter: ((Any, Transaction) -> ())?

  public init(wrappedValue value: Value) {
    initialValue = value
  }

  public mutating func _link(to fiber: any AnyFiber, at index: Int, redraw: @escaping () -> ()) {
    // If the fiber doesn't have a value for this index, use the initial value.
    if fiber.stateValues.count <= index {
      while fiber.stateValues.count <= index {
        fiber.stateValues.append(initialValue)
      }
    }

    getter = { [weak fiber, initialValue] in
      fiber?.stateValues[index] ?? initialValue
    }

    setter = { [weak fiber, redraw] newValue, _ in
      guard let fiber = fiber else { return }
      fiber.stateValues[index] = newValue
      redraw()
    }
  }

  public var wrappedValue: Value {
    get { getter?() as? Value ?? initialValue }
    nonmutating set { setter?(newValue, Transaction._active ?? .init(animation: nil)) }
  }

  public var projectedValue: Binding<Value> {
    guard let getter = getter, let setter = setter else {
      fatalError("\(#function) not available outside of `body`")
    }
    // swiftlint:disable force_cast
    return .init(
      get: { getter() as! Value },
      set: { newValue, transaction in
        setter(newValue, Transaction._active ?? transaction)
      }
    )
    // swiftlint:enable force_cast
  }
}

extension State: WritableValueStorage {}

public extension State where Value: ExpressibleByNilLiteral {
  @inlinable
  init() { self.init(wrappedValue: nil) }
}
