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

public struct _PaddingLayout: ViewModifier {
  public let edges: Edge.Set
  public let insets: EdgeInsets?

  public init(edges: Edge.Set = .all, insets: EdgeInsets? = nil) {
    self.edges = edges
    self.insets = insets
  }

  public func body(content: Content) -> some View {
    _PaddingView(content: content, edges: edges, insets: insets)
  }
}

public struct _PaddingView<Content: View>: View, AnyLVGLWidget {
  public let content: Content
  public let edges: Edge.Set
  public let insets: EdgeInsets?

  public var body: Content { content }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_obj_create(parent)!
    
    let defaultPadding: CGFloat = 16
    let top = tokmakLVCoord(insets?.top ?? defaultPadding)
    let bottom = tokmakLVCoord(insets?.bottom ?? defaultPadding)
    let leading = tokmakLVCoord(insets?.leading ?? defaultPadding)
    let trailing = tokmakLVCoord(insets?.trailing ?? defaultPadding)

    lv_obj_set_style_pad_all(obj, 0, UInt32(LV_PART_MAIN))
    if edges.contains(.top) { lv_obj_set_style_pad_top(obj, top, UInt32(LV_PART_MAIN)) }
    if edges.contains(.bottom) { lv_obj_set_style_pad_bottom(obj, bottom, UInt32(LV_PART_MAIN)) }
    if edges.contains(.leading) { lv_obj_set_style_pad_left(obj, leading, UInt32(LV_PART_MAIN)) }
    if edges.contains(.trailing) { lv_obj_set_style_pad_right(obj, trailing, UInt32(LV_PART_MAIN)) }

    lv_obj_set_width(obj, tokmakLVSizeContent)
    lv_obj_set_height(obj, tokmakLVSizeContent)
    lv_obj_set_style_border_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, 0, UInt32(LV_PART_MAIN))

    return obj
  }
}

public extension View {
  func padding(_ insets: EdgeInsets) -> some View {
    modifier(_PaddingLayout(insets: insets))
  }

  func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
    let insets = length.map { EdgeInsets(_all: $0) }
    return modifier(_PaddingLayout(edges: edges, insets: insets))
  }

  func padding(_ length: CGFloat) -> some View {
    padding(.all, length)
  }
}
