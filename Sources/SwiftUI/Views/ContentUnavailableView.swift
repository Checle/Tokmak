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

/// A compact placeholder view for empty or unavailable content states.
public struct ContentUnavailableView: View {
  let label: AnyView
  let description: AnyView
  let actions: AnyView

  public init<Label, Description, Actions>(
    @ViewBuilder label: () -> Label,
    @ViewBuilder description: () -> Description,
    @ViewBuilder actions: () -> Actions
  ) where Label: View, Description: View, Actions: View {
    self.label = AnyView(label())
    self.description = AnyView(description())
    self.actions = AnyView(actions())
  }

  public init<Label, Description>(
    @ViewBuilder label: () -> Label,
    @ViewBuilder description: () -> Description
  ) where Label: View, Description: View {
    self.label = AnyView(label())
    self.description = AnyView(description())
    actions = AnyView(EmptyView())
  }

  public init<Label>(
    @ViewBuilder label: () -> Label
  ) where Label: View {
    self.label = AnyView(label())
    description = AnyView(EmptyView())
    actions = AnyView(EmptyView())
  }

  public init<S>(_ title: S) where S: StringProtocol {
    self.init {
      Text(title)
    }
  }

  public init<S1, S2>(_ title: S1, description: S2) where S1: StringProtocol, S2: StringProtocol {
    self.init {
      Text(title)
    } description: {
      Text(description)
        .foregroundColor(Color(white: 0.4))
    }
  }

  public init<S1, S2, Actions>(
    _ title: S1,
    description: S2,
    @ViewBuilder actions: () -> Actions
  ) where S1: StringProtocol, S2: StringProtocol, Actions: View {
    self.init {
      Text(title)
    } description: {
      Text(description)
        .foregroundColor(Color(white: 0.4))
    } actions: {
      actions()
    }
  }

  public init<S1, S2>(
    systemImage: String,
    _ title: S1,
    description: S2
  ) where S1: StringProtocol, S2: StringProtocol {
    self.init {
      VStack(spacing: 8) {
        Image(systemName: systemImage)

        Text(title)
      }
    } description: {
      Text(description)
        .foregroundColor(Color(white: 0.4))
        .multilineTextAlignment(.center)
        .frame(width: 300)
    }
  }

  public init<S1, S2, Actions>(
    systemImage: String,
    _ title: S1,
    description: S2,
    @ViewBuilder actions: () -> Actions
  ) where S1: StringProtocol, S2: StringProtocol, Actions: View {
    self.init {
      VStack(spacing: 8) {
        Image(systemName: systemImage)

        Text(title)
      }
    } description: {
      Text(description)
        .foregroundColor(Color(white: 0.4))
        .multilineTextAlignment(.center)
        .frame(width: 300)
    } actions: {
      actions()
    }
  }

  public var body: some View {
    VStack(spacing: 12) {
      label
      description
      actions
    }
    .padding(24)
    .frame(width: 320, alignment: .center)
  }


  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitContentUnavailableView(self)
  }

  public func walk<V: ViewWalker>(_ visitor: inout V) {
    visitor.visit(self)
  }
}
