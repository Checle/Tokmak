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

public struct _FrameLayout: ViewModifier {
  public let width: CGFloat?
  public let height: CGFloat?
  public let alignment: Alignment

  public init(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) {
    self.width = width
    self.height = height
    self.alignment = alignment
  }

  public func body(content: Content) -> some View {
    _FrameView(content: content, width: width, height: height, alignment: alignment)
  }
}

public struct _FrameView<Content: View>: View, AnyLVGLWidget {
  public let content: Content
  public let width: CGFloat?
  public let height: CGFloat?
  public let alignment: Alignment

  public var body: Content { content }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_obj_create(parent)!
    
    if let w = width {
      lv_obj_set_width(obj, tokmakLVCoord(w))
    } else {
      lv_obj_set_width(obj, tokmakLVSizeContent)
    }

    if let h = height {
      lv_obj_set_height(obj, tokmakLVCoord(h))
    } else {
      lv_obj_set_height(obj, tokmakLVSizeContent)
    }

    lv_obj_set_style_pad_all(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, 0, UInt32(LV_PART_MAIN))

    var justify_main = LV_FLEX_ALIGN_CENTER
    var justify_cross = LV_FLEX_ALIGN_CENTER
    
    switch alignment {
      case .topLeading: justify_main = LV_FLEX_ALIGN_START; justify_cross = LV_FLEX_ALIGN_START
      case .top: justify_main = LV_FLEX_ALIGN_START; justify_cross = LV_FLEX_ALIGN_CENTER
      case .topTrailing: justify_main = LV_FLEX_ALIGN_START; justify_cross = LV_FLEX_ALIGN_END
      case .leading: justify_main = LV_FLEX_ALIGN_CENTER; justify_cross = LV_FLEX_ALIGN_START
      case .center: justify_main = LV_FLEX_ALIGN_CENTER; justify_cross = LV_FLEX_ALIGN_CENTER
      case .trailing: justify_main = LV_FLEX_ALIGN_CENTER; justify_cross = LV_FLEX_ALIGN_END
      case .bottomLeading: justify_main = LV_FLEX_ALIGN_END; justify_cross = LV_FLEX_ALIGN_START
      case .bottom: justify_main = LV_FLEX_ALIGN_END; justify_cross = LV_FLEX_ALIGN_CENTER
      case .bottomTrailing: justify_main = LV_FLEX_ALIGN_END; justify_cross = LV_FLEX_ALIGN_END
      default: break
    }

    lv_obj_set_layout(obj, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(obj, LV_FLEX_FLOW_COLUMN)
    lv_obj_set_flex_align(obj, justify_main, justify_cross, LV_FLEX_ALIGN_CENTER)

    return obj
  }
}

public extension View {
  func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
    modifier(_FrameLayout(width: width, height: height, alignment: alignment))
  }
}
