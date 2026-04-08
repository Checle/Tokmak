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

#if os(macOS) || os(Linux)
import Foundation

public extension App {
    
    /// The primary entry point for testing the application on macOS or Linux
    /// using SDL2. This bypasses the E-Paper driver completely and renders
    /// to an interactive desktop window.
    static func main() {
        let width = 800
        let height = 480
        lv_init()
        tokmak_sdl_init(Int32(width), Int32(height))

        // 1. Setup LVGL Display Driver
        let drawBuf = UnsafeMutablePointer<lv_disp_draw_buf_t>.allocate(capacity: 1)
        // For SDL, we typically allocate enough for the whole screen or a large chunk
        let bufferSize = width * height
        let lvBuffer1 = UnsafeMutablePointer<lv_color_t>.allocate(capacity: bufferSize)
        let lvBuffer2 = UnsafeMutablePointer<lv_color_t>.allocate(capacity: bufferSize)
        
        lv_disp_draw_buf_init(drawBuf, lvBuffer1, lvBuffer2, UInt32(bufferSize))

        let dispDrv = UnsafeMutablePointer<lv_disp_drv_t>.allocate(capacity: 1)
        lv_disp_drv_init(dispDrv)
        
        dispDrv.pointee.hor_res = Int16(width)
        dispDrv.pointee.ver_res = Int16(height)
        dispDrv.pointee.flush_cb = tokmak_sdl_display_flush
        dispDrv.pointee.draw_buf = drawBuf
        
        lv_disp_drv_register(dispDrv)
        
        // 2. Setup LVGL Input Driver (Mouse/Touch emulation)
        let indevDrv = UnsafeMutablePointer<lv_indev_drv_t>.allocate(capacity: 1)
        lv_indev_drv_init(indevDrv)
        indevDrv.pointee.type = LV_INDEV_TYPE_POINTER
        indevDrv.pointee.read_cb = tokmak_sdl_mouse_read
        lv_indev_drv_register(indevDrv)
        
        // 3. Start the rendering process
        let renderer = LVGLRenderer()
        renderer.render(Self())
        
        // 4. Start the SDL main loop
        tokmak_sdl_loop()
    }
}

#endif
