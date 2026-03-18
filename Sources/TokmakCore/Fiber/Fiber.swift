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

import Foundation

/// A protocol for the persistent tree nodes in the static path.
public protocol AnyFiber: AnyObject {
  var parent: (any AnyFiber)? { get set }
  var child: (any AnyFiber)? { get set }
  var sibling: (any AnyFiber)? { get set }
  
  /// The renderer's target (e.g., `UnsafeMutablePointer<lv_obj_t>`)
  var target: UnsafeMutableRawPointer? { get set }
  
  /// The index of this fiber in the parent's list of children.
  var index: Int { get set }

  /// The values of state stored in this fiber.
  var stateValues: [Any] { get set }

  func makeChild<T>(_ type: T.Type, at index: Int) -> Fiber<T>
}

/// A generic node in the persistent tree that knows its type.
public final class Fiber<T>: AnyFiber {
  public weak var parent: (any AnyFiber)?
  public var child: (any AnyFiber)?
  public var sibling: (any AnyFiber)?
  
  public var target: UnsafeMutableRawPointer?
  public var index: Int = 0
  
  /// The values of state stored in this fiber.
  public var stateValues: [Any] = []
  
  /// The current state stored in this fiber.
  /// (Placeholder for future state implementation)
  public var state: Any?
  
  public init() {}

  public func makeChild<Child>(_ type: Child.Type, at index: Int) -> Fiber<Child> {
    if let child = self.child as? Fiber<Child>, child.index == index {
      return child
    }

    let newChild = Fiber<Child>()
    newChild.parent = self
    newChild.index = index

    if index == 0 {
      newChild.sibling = self.child?.sibling
      self.child = newChild
    } else {
      // Find the sibling at index - 1
      var current = self.child
      while let c = current, c.index < index - 1 {
        current = c.sibling
      }
      newChild.sibling = current?.sibling
      current?.sibling = newChild
    }

    return newChild
  }
}
