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
public typealias EnvironmentObject = TokmakCore.EnvironmentObject

public typealias Binding = TokmakCore.Binding
public typealias ObservableObject = TokmakCore.ObservableObject
public typealias ObservedObject = TokmakCore.ObservedObject
public typealias Published = TokmakCore.Published
public typealias State = TokmakCore.State
public typealias StateObject = TokmakCore.StateObject

// MARK: Modifiers & Styles

public typealias ViewModifier = TokmakCore.ViewModifier
public typealias ModifiedContent = TokmakCore.ModifiedContent

public typealias DefaultTextFieldStyle = TokmakCore.DefaultTextFieldStyle
public typealias PlainTextFieldStyle = TokmakCore.PlainTextFieldStyle
public typealias RoundedBorderTextFieldStyle = TokmakCore.RoundedBorderTextFieldStyle
public typealias SquareBorderTextFieldStyle = TokmakCore.SquareBorderTextFieldStyle

public typealias DefaultListStyle = TokmakCore.DefaultListStyle
public typealias PlainListStyle = TokmakCore.PlainListStyle
public typealias InsetListStyle = TokmakCore.InsetListStyle
public typealias GroupedListStyle = TokmakCore.GroupedListStyle
public typealias InsetGroupedListStyle = TokmakCore.InsetGroupedListStyle
public typealias SidebarListStyle = TokmakCore.SidebarListStyle

public typealias DefaultPickerStyle = TokmakCore.DefaultPickerStyle
public typealias PopUpButtonPickerStyle = TokmakCore.PopUpButtonPickerStyle
public typealias RadioGroupPickerStyle = TokmakCore.RadioGroupPickerStyle
public typealias SegmentedPickerStyle = TokmakCore.SegmentedPickerStyle
public typealias WheelPickerStyle = TokmakCore.WheelPickerStyle

public typealias ToggleStyle = TokmakCore.ToggleStyle
public typealias ToggleStyleConfiguration = TokmakCore.ToggleStyleConfiguration

public typealias ButtonStyle = TokmakCore.ButtonStyle
public typealias ButtonStyleConfiguration = TokmakCore.ButtonStyleConfiguration
public typealias DefaultButtonStyle = TokmakCore.DefaultButtonStyle

public typealias ColorScheme = TokmakCore.ColorScheme

// MARK: Shapes

public typealias Shape = TokmakCore.Shape

public typealias Capsule = TokmakCore.Capsule
public typealias Circle = TokmakCore.Circle
public typealias Ellipse = TokmakCore.Ellipse
public typealias Path = TokmakCore.Path
public typealias Rectangle = TokmakCore.Rectangle
public typealias RoundedRectangle = TokmakCore.RoundedRectangle

// MARK: Primitive values

public typealias Color = TokmakCore.Color
public typealias Font = TokmakCore.Font
public typealias CGFloat = Foundation.CGFloat

#if !canImport(CoreGraphics)
public typealias CGAffineTransform = TokmakCore.CGAffineTransform
#endif

// MARK: Views

public typealias Button = TokmakCore.Button
public typealias DisclosureGroup = TokmakCore.DisclosureGroup
public typealias Divider = TokmakCore.Divider
public typealias ForEach = TokmakCore.ForEach
public typealias GeometryReader = TokmakCore.GeometryReader
public typealias GridItem = TokmakCore.GridItem
public typealias Group = TokmakCore.Group
public typealias HStack = TokmakCore.HStack
public typealias Image = TokmakCore.Image
public typealias LazyHGrid = TokmakCore.LazyHGrid
public typealias LazyVGrid = TokmakCore.LazyVGrid
public typealias List = TokmakCore.List
public typealias NavigationLink = TokmakCore.NavigationLink
public typealias NavigationView = TokmakCore.NavigationView
public typealias Picker = TokmakCore.Picker
public typealias ProgressView = TokmakCore.ProgressView
public typealias ScrollView = TokmakCore.ScrollView
public typealias Section = TokmakCore.Section
public typealias Spacer = TokmakCore.Spacer
public typealias Text = TokmakCore.Text
public typealias TextField = TokmakCore.TextField
public typealias Toggle = TokmakCore.Toggle
public typealias VStack = TokmakCore.VStack
public typealias ZStack = TokmakCore.ZStack

public typealias AnyView = TokmakCore.AnyView
public typealias EmptyView = TokmakCore.EmptyView

// MARK: LVGL Constants
public let LV_SIZE_CONTENT: Int16 = 2001 | (1 << 13)
