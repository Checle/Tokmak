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
//
//  Created for LVGL renderer

import CLVGL
import Foundation
@_exported import TokmakCore

// MARK: Environment & State

public typealias Environment = TokmakCore.Environment
public typealias Binding = TokmakCore.Binding
public typealias State = TokmakCore.State

// MARK: Modifiers & Styles

public typealias ViewModifier = TokmakCore.ViewModifier
public typealias ModifiedContent = TokmakCore.ModifiedContent
public typealias ColorScheme = TokmakCore.ColorScheme

// MARK: Primitive values

public typealias Color = TokmakCore.Color
public typealias Font = TokmakCore.Font
public typealias CGFloat = Foundation.CGFloat

// MARK: Views

public typealias Text = TokmakCore.Text
public typealias AnyView = TokmakCore.AnyView

// MARK: LVGL Constants
public let LV_SIZE_CONTENT: Int16 = 2001 | (1 << 13)
