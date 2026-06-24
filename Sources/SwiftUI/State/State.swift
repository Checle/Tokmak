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

// A typed heap-allocated box.  Using Unmanaged<StateBox<Value>> instead of
// Any avoids both dynamic casting and the existential Any — both of which are
// forbidden under Embedded Swift.
private final class StateBox<Value> {
  var value: Value
  init(_ value: Value) { self.value = value }
}

public struct StateKey: Hashable {
  let value: UInt64

  init(fileID: StaticString, line: UInt, column: UInt) {
    var hash: UInt64 = 1469598103934665603
    for index in 0..<fileID.utf8CodeUnitCount {
      hash ^= UInt64(fileID.utf8Start[index])
      hash &*= 1099511628211
    }
    hash ^= UInt64(line)
    hash &*= 1099511628211
    hash ^= UInt64(column)
    self.value = hash
  }
}

private final class StateStorage<Value> {
  let initialValue: Value
  let key: StateKey
  var box: StateBox<Value>?
  var redraw: (() -> Void)?

  init(_ value: Value, key: StateKey) {
    initialValue = value
    self.key = key
  }

  func link(to fiber: FiberNode, redraw: @escaping () -> Void) {
    self.redraw = redraw

    if let existing = fiber.stateSlots[key] {
      box = Unmanaged<StateBox<Value>>.fromOpaque(existing).takeUnretainedValue()
    } else {
      let newBox = StateBox(initialValue)
      box = newBox
      fiber.stateSlots[key] = Unmanaged.passRetained(newBox).toOpaque()
    }
  }
}

private struct StateContext {
  let fiber: FiberNode
  let redraw: () -> Void
}

private var activeStateContext: StateContext?

/// Makes property-wrapper storage available while a view's body is evaluated.
public func withStateContext<Result>(
  fiber: FiberNode?,
  redraw: @escaping () -> Void,
  _ body: () -> Result
) -> Result {
  let previous = activeStateContext
  if let fiber {
    activeStateContext = StateContext(fiber: fiber, redraw: redraw)
  } else {
    activeStateContext = nil
  }
  defer { activeStateContext = previous }
  return body()
}

@propertyWrapper
public struct State<Value>: DynamicProperty {
  private let storage: StateStorage<Value>

  public init(
    wrappedValue value: Value,
    fileID: StaticString = #fileID,
    line: UInt = #line,
    column: UInt = #column
  ) {
    storage = StateStorage(
      value,
      key: StateKey(fileID: fileID, line: line, column: column)
    )
  }

  public var wrappedValue: Value {
    get {
      linkFromActiveContext()
      return storage.box?.value ?? storage.initialValue
    }
    nonmutating set {
      linkFromActiveContext()
      storage.box?.value = newValue
      storage.redraw?()
    }
  }

  public var projectedValue: Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { self.wrappedValue = $0 }
    )
  }

  private func linkFromActiveContext() {
    guard storage.box == nil, let context = activeStateContext else { return }
    storage.link(to: context.fiber, redraw: context.redraw)
  }
}

public extension State where Value: ExpressibleByNilLiteral {
  @inlinable
  init() { self.init(wrappedValue: nil) }
}
