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

extension Text: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let label = lv_label_create(parent)!
    applyTextStyle(to: label)
    return label
  }

  func applyTextStyle(
    to label: UnsafeMutablePointer<lv_obj_t>,
    width: lv_coord_t = tokmakLVSizeContent,
    alignment: TextAlignment? = nil
  ) {
    let proxy = _TextProxy(self)
    let resolvedAlignment = alignment ?? proxy.environment.multilineTextAlignment

    lv_label_set_long_mode(label, lv_label_long_mode_t(LV_LABEL_LONG_WRAP))
    lv_obj_set_width(label, width)
    lv_obj_set_style_text_align(
      label,
      tokmakLVTextAlign(resolvedAlignment),
      UInt32(LV_PART_MAIN)
    )

    let font = proxy.modifiers.compactMap { modifier -> Font? in
      if case let .font(font) = modifier {
        return font
      }
      return nil
    }.last
    if let font {
      let resolvedFont = _FontProxy(font).resolve(in: proxy.environment)
      let weight = resolvedFont._bold ? Font.Weight.bold.value : resolvedFont._weight.value
      lv_obj_set_style_text_font(
        label,
        tokmak_lv_font_noto_sans(Int32(resolvedFont._size.rounded()), Int32(weight)),
        UInt32(LV_PART_MAIN)
      )
    }

    let letterSpacing = proxy.modifiers.compactMap { modifier -> CGFloat? in
      switch modifier {
      case let .kerning(value), let .tracking(value):
        return value
      default:
        return nil
      }
    }.last
    if let letterSpacing {
      lv_obj_set_style_text_letter_space(
        label,
        tokmakLVCoord(letterSpacing),
        UInt32(LV_PART_MAIN)
      )
    }

    let foregroundColor = proxy.modifiers.compactMap { modifier -> Color? in
      if case let .color(color) = modifier {
        return color
      }
      return nil
    }.last

    if let foregroundColor {
      lv_obj_set_style_text_color(
        label,
        tokmakLVMonochromeColor(foregroundColor, in: proxy.environment),
        UInt32(LV_PART_MAIN)
      )
    }

    let text = proxy.rawText
    text.withCString { cString in
      lv_label_set_text(label, cString)
    }
  }
}
