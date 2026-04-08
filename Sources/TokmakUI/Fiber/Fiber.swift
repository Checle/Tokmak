// Copyright 2022 Tokamak contributors
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

/// A protocol for the persistent tree nodes in the static path.
public protocol AnyFiber: AnyObject {
  var parent: (any AnyFiber)? { get set }
  var child: (any AnyFiber)? { get set }
  var sibling: (any AnyFiber)? { get set }
  
  /// The renderer's target (e.g., `UnsafeMutablePointer<lv_obj_t>`)
  var target: UnsafeMutableRawPointer? { get set }
  var ownsTarget: Bool { get set }
  
  /// The index of this fiber in the parent's list of children.
  var index: Int { get set }

  /// The values of state stored in this fiber.
  var stateValues: [Any] { get set }

  func reconcileChild<T>(_ type: T.Type, at index: Int) -> (fiber: Fiber<T>, replaced: (any AnyFiber)?)
  func pruneChildren(after index: Int) -> [(any AnyFiber)]
}

/// A generic node in the persistent tree that knows its type.
public final class Fiber<T>: AnyFiber {
  public weak var parent: (any AnyFiber)?
  public var child: (any AnyFiber)?
  public var sibling: (any AnyFiber)?
  
  public var target: UnsafeMutableRawPointer?
  public var ownsTarget: Bool = false
  public var index: Int = 0
  
  /// The values of state stored in this fiber.
  public var stateValues: [Any] = []
  
  /// The current state stored in this fiber.
  /// (Placeholder for future state implementation)
  public var state: Any?
  
  public init() {}

  public func reconcileChild<Child>(_ type: Child.Type, at index: Int) -> (fiber: Fiber<Child>, replaced: (any AnyFiber)?) {
    var previous: (any AnyFiber)?
    var current = child

    while let fiber = current, fiber.index < index {
      previous = fiber
      current = fiber.sibling
    }

    if let fiber = current, fiber.index == index {
      if let typedFiber = fiber as? Fiber<Child> {
        return (typedFiber, nil)
      }

      let replacement = Fiber<Child>()
      replacement.parent = self
      replacement.index = index
      replacement.sibling = fiber.sibling

      if let previous {
        previous.sibling = replacement
      } else {
        child = replacement
      }

      fiber.sibling = nil
      return (replacement, fiber)
    }

    let newChild = Fiber<Child>()
    newChild.parent = self
    newChild.index = index

    if let previous {
      newChild.sibling = previous.sibling
      previous.sibling = newChild
    } else {
      newChild.sibling = child
      child = newChild
    }

    return (newChild, nil)
  }

  public func pruneChildren(after index: Int) -> [(any AnyFiber)] {
    guard let firstChild = child else {
      return []
    }

    if index < 0 {
      child = nil
      return collectSiblings(startingAt: firstChild)
    }

    var kept: (any AnyFiber)? = nil
    var current: (any AnyFiber)? = firstChild

    while let fiber = current, fiber.index <= index {
      kept = fiber
      current = fiber.sibling
    }

    kept?.sibling = nil
    if kept == nil {
      child = nil
    }

    return current.map { collectSiblings(startingAt: $0) } ?? []
  }

  private func collectSiblings(startingAt fiber: any AnyFiber) -> [(any AnyFiber)] {
    var collected: [(any AnyFiber)] = []
    var current: (any AnyFiber)? = fiber

    while let item = current {
      let next = item.sibling
      item.sibling = nil
      collected.append(item)
      current = next
    }

    return collected
  }
}
