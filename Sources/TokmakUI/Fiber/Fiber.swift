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

/// A persistent tree node in the static path.
public class FiberNode {
  public var child: FiberNode?
  public var sibling: FiberNode?
  
  public var target: UnsafeMutableRawPointer?
  public var ownsTarget: Bool = false
  public var index: Int = 0
  public var reconciliationIdentity: TokmakIdentityKey?
  
  /// The values of state stored in this fiber.
  public var stateValues: [Any] = []
  public var scrollTargetIDs: [TokmakIdentityKey] = []
  
  /// The current state stored in this fiber.
  /// (Placeholder for future state implementation)
  public var state: Any?

  public init() {}

  public final func reconcileChild<Child>(
    _ type: Child.Type,
    at index: Int,
    identity: TokmakIdentityKey? = nil
  ) -> (fiber: Fiber<Child>, replaced: FiberNode?) {
    if let identity, let matched = findChild(with: identity) {
      if let typedFiber = matched.fiber as? Fiber<Child> {
        detachChild(matched.fiber, previous: matched.previous)
        typedFiber.index = index
        typedFiber.reconciliationIdentity = identity
        insertChild(typedFiber, at: index)
        return (typedFiber, nil)
      }

      let replacement = Fiber<Child>()
      replacement.index = index
      replacement.reconciliationIdentity = identity
      detachChild(matched.fiber, previous: matched.previous)
      insertChild(replacement, at: index)
      matched.fiber.sibling = nil
      return (replacement, matched.fiber)
    }

    var previous: FiberNode?
    var current = child

    while let fiber = current, fiber.index < index {
      previous = fiber
      current = fiber.sibling
    }

    if let fiber = current, fiber.index == index {
      if let typedFiber = fiber as? Fiber<Child>, fiber.reconciliationIdentity == identity {
        typedFiber.reconciliationIdentity = identity
        return (typedFiber, nil)
      }

      let replacement = Fiber<Child>()
      replacement.index = index
      replacement.reconciliationIdentity = identity
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
    newChild.index = index
    newChild.reconciliationIdentity = identity

    if let previous {
      newChild.sibling = previous.sibling
      previous.sibling = newChild
    } else {
      newChild.sibling = child
      child = newChild
    }

    return (newChild, nil)
  }

  public func pruneChildren(after index: Int) -> [FiberNode] {
    guard let firstChild = child else {
      return []
    }

    if index < 0 {
      child = nil
      return collectSiblings(startingAt: firstChild)
    }

    var kept: FiberNode? = nil
    var current: FiberNode? = firstChild

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

  private func collectSiblings(startingAt fiber: FiberNode) -> [FiberNode] {
    var collected: [FiberNode] = []
    var current: FiberNode? = fiber

    while let item = current {
      let next = item.sibling
      item.sibling = nil
      collected.append(item)
      current = next
    }

    return collected
  }

  private func findChild(with identity: TokmakIdentityKey) -> (previous: FiberNode?, fiber: FiberNode)? {
    var previous: FiberNode?
    var current = child

    while let fiber = current {
      if fiber.reconciliationIdentity == identity {
        return (previous, fiber)
      }
      previous = fiber
      current = fiber.sibling
    }

    return nil
  }

  private func detachChild(_ target: FiberNode, previous: FiberNode?) {
    if let previous {
      previous.sibling = target.sibling
    } else {
      child = target.sibling
    }
    target.sibling = nil
  }

  private func insertChild(_ target: FiberNode, at index: Int) {
    target.index = index

    var previous: FiberNode?
    var current = child

    while let fiber = current, fiber.index < index {
      previous = fiber
      current = fiber.sibling
    }

    if let previous {
      target.sibling = previous.sibling
      previous.sibling = target
    } else {
      target.sibling = child
      child = target
    }
  }
}

/// A generic node in the persistent tree that knows its type.
public final class Fiber<T>: FiberNode {}
