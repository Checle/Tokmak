// Copyright 2018-2020 Tokamak contributors
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
//  Created by Carson Katri on 7/12/21.
//

public extension View {
  func accentColor(_ accentColor: Color?) -> some View {
    transformEnvironment { $0.accentColor = accentColor }
  }
}

public extension View {
  func foregroundColor(_ color: Color?) -> some View {
    transformEnvironment { $0.foregroundColor = color }
  }
}
