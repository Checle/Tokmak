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

/// A safe Swift representation of the LVGL drawing area.
public struct Rect {
  public let minX: Int
  public let minY: Int
  public let maxX: Int
  public let maxY: Int
}

/// The callback function the user provides to push pixels to the physical display.
public typealias DisplayFlushCallback = (
  _ area: Rect,
  _ colorBuffer: UnsafeMutableBufferPointer<lv_color_t>
) -> Void

/// Configuration for the LVGL display driver.
public struct DisplayConfiguration {
  public let width: Int
  public let height: Int
  public let drawBuffer: UnsafeMutableBufferPointer<lv_color_t>
  public let flushCallback: DisplayFlushCallback

  public init(
    width: Int,
    height: Int,
    drawBuffer: UnsafeMutableBufferPointer<lv_color_t>,
    flushCallback: @escaping DisplayFlushCallback
  ) {
    self.width = width
    self.height = height
    self.drawBuffer = drawBuffer
    self.flushCallback = flushCallback
  }
}

/// A class to hold the closure so it can be passed through LVGL's C `user_data` pointer.
private final class FlushContext {
  let callback: DisplayFlushCallback
  init(_ callback: @escaping DisplayFlushCallback) {
    self.callback = callback
  }
}

/// The raw C callback that LVGL will call. It extracts the Swift closure and executes it.
private func lvgl_flush_wrapper(
  drv: UnsafeMutablePointer<lv_disp_drv_t>?,
  area: UnsafePointer<lv_area_t>?,
  color_p: UnsafeMutablePointer<lv_color_t>?
) {
  guard let drv = drv, let area = area, let color_p = color_p else { return }

  // Extract the Swift closure from user_data
  let context = Unmanaged<FlushContext>.fromOpaque(drv.pointee.user_data).takeUnretainedValue()

  let rect = Rect(
    minX: Int(area.pointee.x1),
    minY: Int(area.pointee.y1),
    maxX: Int(area.pointee.x2),
    maxY: Int(area.pointee.y2)
  )

  // Provide a safe buffer pointer to the user
  let pixelCount = (rect.maxX - rect.minX + 1) * (rect.maxY - rect.minY + 1)
  let buffer = UnsafeMutableBufferPointer(start: color_p, count: pixelCount)

  // Call the user's Swift code
  context.callback(rect, buffer)

  // Tell LVGL the flush is complete
  lv_disp_flush_ready(drv)
}

public extension App {
  static func _launch(_ app: Self, with configuration: _AppConfiguration) {
    // Default launch without display config. 
    // This is useful for simulators or if the user initializes LVGL entirely manually.
    lv_init()
    let renderer = LVGLRenderer()
    renderer.render(app)
  }

  /// The primary entry point for Embedded Swift applications.
  /// Wires up the LVGL display driver using the provided configuration.
  static func main(display: DisplayConfiguration) {
    lv_init()

    // 1. Initialize the LVGL draw buffer
    let drawBuf = UnsafeMutablePointer<lv_disp_draw_buf_t>.allocate(capacity: 1)
    lv_disp_draw_buf_init(drawBuf, display.drawBuffer.baseAddress, nil, UInt32(display.drawBuffer.count))

    // 2. Retain the context so it isn't deallocated
    let context = FlushContext(display.flushCallback)
    let retainedContext = Unmanaged.passRetained(context).toOpaque()

    // 3. Register the display driver
    let dispDrv = UnsafeMutablePointer<lv_disp_drv_t>.allocate(capacity: 1)
    lv_disp_drv_init(dispDrv)

    dispDrv.pointee.hor_res = Int16(display.width)
    dispDrv.pointee.ver_res = Int16(display.height)
    dispDrv.pointee.flush_cb = lvgl_flush_wrapper
    dispDrv.pointee.draw_buf = drawBuf
    dispDrv.pointee.user_data = retainedContext

    lv_disp_drv_register(dispDrv)

    // 4. Start the rendering process
    let renderer = LVGLRenderer()
    renderer.render(Self())
  }

  static func _setTitle(_ title: String) {
  }
}
