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

#if TOKMAK_PLATFORM_PICO
public extension App {
    
    /// The primary entry point for E-Paper applications using the GDEY037T03.
    /// It automatically sets up the C EPD driver and registers the LVGL flush callback.
    /// The EPD driver relies on external C symbols (like `gpio_put`) being linked
    /// by the application for the chosen platform (e.g., Pi Pico).
    static func main() {
        // 1. Initialize the EPD
        epd_uc8253_init()
        epd_uc8253_clear()
        
        // 2. Setup LVGL
        let width = Int(EPD_UC8253_WIDTH)
        let height = Int(EPD_UC8253_HEIGHT)
        
        // Create an LVGL draw buffer.
        // We use a statically allocated buffer (never freed since main doesn't return).
        // 40 lines of height for the LVGL draw buffer is a good balance for partial updates on EPD.
        let bufferLines = 40
        let bufferSize = width * bufferLines
        let lvBuffer = UnsafeMutablePointer<lv_color_t>.allocate(capacity: bufferSize)
        let lvBufferPtr = UnsafeMutableBufferPointer(start: lvBuffer, count: bufferSize)
        
        let config = DisplayConfiguration(width: width, height: height, drawBuffer: lvBufferPtr) { area, colors in
            let areaWidth = area.maxX - area.minX + 1
            let areaHeight = area.maxY - area.minY + 1
            let bytesPerRow = (areaWidth + 7) / 8
            
            // E-Paper displays typically expect 1-bit per pixel, packed into bytes.
            var packedBuffer = [UInt8](repeating: 0, count: bytesPerRow * areaHeight)
            
            var colorIndex = 0
            for y in 0..<areaHeight {
                for x in 0..<areaWidth {
                    // Very simple thresholding for 1-bit B/W. 
                    // Depending on `lv_color_t` depth, `full` might need different interpretation.
                    // For LV_COLOR_DEPTH 1, full == 1 is white. 
                    let isWhite = colors[colorIndex].full != 0 
                    
                    if isWhite {
                        let bitIndex = 7 - (x % 8)
                        let byteIndex = (y * bytesPerRow) + (x / 8)
                        packedBuffer[byteIndex] |= (1 << bitIndex)
                    }
                    colorIndex += 1
                }
            }
            
            // Send the partial update to the EPD driver
            packedBuffer.withUnsafeBufferPointer { ptr in
                epd_uc8253_update_region(
                    ptr.baseAddress, 
                    Int32(area.minX), 
                    Int32(area.minY), 
                    Int32(areaWidth), 
                    Int32(areaHeight), 
                    EPD_MODE_PARTIAL
                )
            }
        }
        
        // 3. Launch the app with this configuration
        main(display: config)
    }
}
#endif
