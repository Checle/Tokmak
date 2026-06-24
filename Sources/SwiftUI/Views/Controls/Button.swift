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


public struct Button<Label: View>: View {
  public let action: () -> Void
  public let label: Label

  public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
    self.action = action
    self.label = label()
  }

  public var body: Label { label }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitButton(self)
  }


}

public extension Button where Label == Text {
  init<S>(_ title: S, action: @escaping () -> Void) where S: StringProtocol {
    self.init(action: action) { Text(title) }
  }
}
