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
//  Created by Carson Katri on 7/19/20.
//

 #if hasFeature(Embedded)
public struct _AnyApp: App {
  public init<A: App>(_ app: A) {}

  public func walk<V: AppWalker>(_ visitor: inout V) {
    fatalError("_AnyApp is unavailable in embedded builds.")
  }

  @_spi(TokmakUI)
  public var body: Never {
    neverScene("_AnyApp")
  }

  @_spi(TokmakUI)
  public init() {
    fatalError("`_AnyApp` cannot be initialized without an underlying `App` type.")
  }

  @_spi(TokmakUI)
  public static func _launch(_ app: Self, with configuration: _AppConfiguration) {
    fatalError("`_AnyApp` cannot be launched in embedded builds.")
  }

  @_spi(TokmakUI)
  public static func _setTitle(_ title: String) {
    fatalError("`title` cannot be set for `_AnyApp` in embedded builds.")
  }

  public static var _configuration: _AppConfiguration {
    fatalError("`configuration` cannot be set for `_AnyApp` in embedded builds.")
  }
}
#else
public struct _AnyApp: App {
  var app: Any
  let type: Any.Type
  let bodyClosure: (Any) -> _AnyScene
  let bodyType: Any.Type
  let walkClosure: (inout any AppWalker, Any) -> ()

  public init<A: App>(_ app: A) {
    self.app = app
    type = A.self
    // swiftlint:disable:next force_cast
    bodyClosure = { _AnyScene(($0 as! A).body) }
    bodyType = A.Body.self
    walkClosure = { visitor, app in
      var v = visitor
      (app as! A).walk(&v)
      visitor = v
    }
  }

  public func walk<V: AppWalker>(_ visitor: inout V) {
    var anyVisitor: any AppWalker = visitor
    walkClosure(&anyVisitor, app)
    visitor = anyVisitor as! V
  }

  @_spi(TokmakUI)
  public var body: Never {
    neverScene("_AnyApp")
  }

  @_spi(TokmakUI)
  public init() {
    fatalError("`_AnyApp` cannot be initialized without an underlying `App` type.")
  }

  @_spi(TokmakUI)
  public static func _launch(_ app: Self, with configuration: _AppConfiguration) {
    fatalError("`_AnyApp` cannot be launched. Access underlying `app` value.")
  }

  @_spi(TokmakUI)
  public static func _setTitle(_ title: String) {
    fatalError("`title` cannot be set for `AnyApp`. Access underlying `app` value.")
  }

  public static var _configuration: _AppConfiguration {
    fatalError("`configuration` cannot be set for `AnyApp`. Access underlying `app` value.")
  }
}
#endif
