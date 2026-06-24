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


public struct TabView<Content: View>: View {
  public let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitTabView(self)
  }


}



public struct _TabItemView<Content: View, Label: View>: View {
  public let content: Content
  public let title: String

  public var body: Content { content }

  init(content: Content, label: Label) {
    self.content = content
    self.title = tokmakTabTitle(from: label)
  }
}

public extension View {
  func tabItem<Label: View>(@ViewBuilder _ label: () -> Label) -> some View {
    _TabItemView(content: self, label: label())
  }
}

public protocol TokmakTabItem {
  var tabTitle: String { get }
  var tabContent: AnyView { get }
}

extension _TabItemView: TokmakTabItem {
  public var tabTitle: String { title }
  public var tabContent: AnyView { AnyView(content) }
}

public func tokmakTabChildren<Content: View>(from content: Content) -> [AnyView] {
  #if hasFeature(Embedded)
  return []
  #else
  if let parent = content as? ParentView {
    return parent.children
  }
  return [AnyView(content)]
  #endif
}

#if hasFeature(Embedded)
public func tokmakTabTitle<V: View>(from view: V) -> String {
  "Tab"
}
#else
public func tokmakTabTitle(from view: Any) -> String {
  if let text = view as? Text {
    return _TextProxy(text).rawText
  }
  let mirror = Mirror(reflecting: view)
  for child in mirror.children {
    let title = tokmakTabTitle(from: child.value)
    if title != "Tab" {
      return title
    }
  }
  return "Tab"
}
#endif

public func tokmakTabTitle(from view: AnyView) -> String {
  #if hasFeature(Embedded)
  "Tab"
  #else
  if let tabItem = view.view as? TokmakTabItem {
    return tabItem.tabTitle
  }
  return tokmakTabTitle(from: view.view)
  #endif
}

public func tokmakTabContent(from view: AnyView) -> AnyView {
  #if hasFeature(Embedded)
  view
  #else
  if let tabItem = view.view as? TokmakTabItem {
    return tabItem.tabContent
  }
  return view
  #endif
}
