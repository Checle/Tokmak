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
  mutating func visit<V: PropertyVisitor>(_ visitor: inout V)
}

@propertyWrapper
public struct State<Value>: DynamicProperty, StateProtocol {
  private let initialValue: Value
  private var storage: StateStorage<Value>?

  var anyInitialValue: Any { initialValue }

  var getter: (() -> Any)? {
    get { { storage?.get() as Any } }
    set { /* Not used in this implementation */ }
  }

  var setter: ((Any, Transaction) -> ())? {
    get { { val, _ in if let v = val as? Value { storage?.set(v) } } }
    set { /* Not used in this implementation */ }
  }

  public init(wrappedValue value: Value) {
    initialValue = value
  }

  public mutating func _link(to fiber: FiberNode, at index: Int, redraw: @escaping () -> ()) {
    self.storage = StateStorage(fiber: fiber, index: index, initialValue: initialValue, redraw: redraw)
  }

  public mutating func visit<V: PropertyVisitor>(_ visitor: inout V) {
    visitor.visitState(&self)
  }

  public var wrappedValue: Value {
    get { storage?.get() ?? initialValue }
    nonmutating set { storage?.set(newValue) }
  }

  public var projectedValue: Binding<Value> {
    guard let storage = storage else {
      fatalError("\(#function) not available outside of `body`")
    }
    return .init(
      get: { storage.get() },
      set: { newValue, _ in
        storage.set(newValue)
      }
    )
  }
}

private final class StateStorage<Value> {
  let fiber: FiberNode
  let index: Int
  let initialValue: Value
  let redraw: () -> ()

  init(fiber: FiberNode, index: Int, initialValue: Value, redraw: @escaping () -> ()) {
    self.fiber = fiber
    self.index = index
    self.initialValue = initialValue
    self.redraw = redraw

    if fiber.stateValues.count <= index {
      while fiber.stateValues.count <= index {
        fiber.stateValues.append(initialValue)
      }
    }
  }

  func get() -> Value {
    (fiber.stateValues[index] as? Value) ?? initialValue
  }

  func set(_ newValue: Value) {
    fiber.stateValues[index] = newValue
    redraw()
  }
}

extension State: WritableValueStorage {}

public extension State where Value: ExpressibleByNilLiteral {
  @inlinable
  init() { self.init(wrappedValue: nil) }
}
