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

import CLVGL

public struct TabView<Content: View>: View, AnyLVGLWidget {
  public let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitTabView(self)
  }

  public func _createTarget(renderer: LVGLRenderer, parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>? {
    new(renderer, parent)
  }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_tabview_create(parent, lv_dir_t(LV_DIR_BOTTOM), tokmakLVCoord(52))!
    lv_obj_set_size(obj, lv_pct(100), lv_pct(100))
    lv_obj_set_style_pad_all(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, 0, UInt32(LV_PART_MAIN))

    let buttons = lv_tabview_get_tab_btns(obj)
    lv_obj_set_style_bg_color(buttons, lv_color_hex(0xFFFFFF), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(buttons, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(buttons, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_text_color(buttons, lv_color_hex(0x000000), UInt32(LV_PART_ITEMS))
    lv_obj_set_style_text_font(buttons, tokmak_lv_font_noto_sans_regular(14), UInt32(LV_PART_ITEMS))
    lv_obj_set_style_text_decor(buttons, lv_text_decor_t(LV_TEXT_DECOR_NONE), UInt32(LV_PART_ITEMS))
    lv_obj_set_style_bg_color(buttons, lv_color_hex(0xFFFFFF), UInt32(LV_PART_ITEMS))
    lv_obj_set_style_bg_opa(buttons, lv_opa_t(LV_OPA_TRANSP), UInt32(LV_PART_ITEMS))
    lv_obj_set_style_border_width(buttons, 0, UInt32(LV_PART_ITEMS))
    lv_obj_set_style_border_opa(buttons, lv_opa_t(LV_OPA_TRANSP), UInt32(LV_PART_ITEMS))

    let checkedSelector = UInt32(LV_PART_ITEMS | LV_STATE_CHECKED)
    lv_obj_set_style_text_color(buttons, tokmakLVPrimaryBlue, checkedSelector)
    lv_obj_set_style_text_font(buttons, tokmak_lv_font_noto_sans_bold(14), checkedSelector)
    lv_obj_set_style_text_decor(buttons, lv_text_decor_t(LV_TEXT_DECOR_NONE), checkedSelector)
    lv_obj_set_style_bg_color(buttons, lv_color_hex(0xFFFFFF), checkedSelector)
    lv_obj_set_style_bg_opa(buttons, lv_opa_t(LV_OPA_TRANSP), checkedSelector)
    lv_obj_set_style_border_width(buttons, 0, checkedSelector)
    lv_obj_set_style_border_opa(buttons, lv_opa_t(LV_OPA_TRANSP), checkedSelector)

    return obj
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

protocol TokmakTabItem {
  var tabTitle: String { get }
  var tabContent: AnyView { get }
}

extension _TabItemView: TokmakTabItem {
  var tabTitle: String { title }
  var tabContent: AnyView { AnyView(content) }
}

func tokmakTabChildren<Content: View>(from content: Content) -> [AnyView] {
  if let parent = content as? ParentView {
    return parent.children
  }
  return [AnyView(content)]
}

func tokmakTabTitle(from view: Any) -> String {
  if let text = view as? Text {
    return _TextProxy(text).rawText
  }
  return "Tab"
}

func tokmakTabTitle(from view: AnyView) -> String {
  #if hasFeature(Embedded)
  "Tab"
  #else
  if let tabItem = view.view as? TokmakTabItem {
    return tabItem.tabTitle
  }
  return tokmakTabTitle(from: view.view)
  #endif
}

func tokmakTabContent(from view: AnyView) -> AnyView {
  #if hasFeature(Embedded)
  view
  #else
  if let tabItem = view.view as? TokmakTabItem {
    return tabItem.tabContent
  }
  return view
  #endif
}
