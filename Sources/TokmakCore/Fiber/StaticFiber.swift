// Copyright 2026 Tokamak contributors
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
public protocol AnyStaticFiber: AnyObject {
  var parent: (any AnyStaticFiber)? { get set }
  var child: (any AnyStaticFiber)? { get set }
  var sibling: (any AnyStaticFiber)? { get set }
  
  /// The renderer's target (e.g., `UnsafeMutablePointer<lv_obj_t>`)
  var target: UnsafeMutableRawPointer? { get set }
  
  /// The index of this fiber in the parent's list of children.
  var index: Int { get set }
}

/// A generic node in the persistent tree that knows its view type.
public final class StaticFiber<V: View>: AnyStaticFiber {
  public weak var parent: (any AnyStaticFiber)?
  public var child: (any AnyStaticFiber)?
  public var sibling: (any AnyStaticFiber)?
  
  public var target: UnsafeMutableRawPointer?
  public var index: Int = 0
  
  /// The current state stored in this fiber.
  /// (Placeholder for future state implementation)
  public var state: Any?
  
  public init() {}
}
