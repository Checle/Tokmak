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

// Fully-typed counterparts to `TupleView` for Embedded Swift, where a tuple cannot be decomposed
// via existential casts. Each child type is preserved as a stored property, so `_visit` can walk
// every child with static dispatch — no `any View`, no reflection. These are transparent in the
// view tree (like `TupleView`): they create no fiber of their own, walking children directly so
// they become siblings under the enclosing container.

public struct _TupleView2<C0: View, C1: View>: _PrimitiveView {
  let c0: C0
  let c1: C1
  init(_ c0: C0, _ c1: C1) { self.c0 = c0; self.c1 = c1 }
  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    c0.walk(&visitor)
    c1.walk(&visitor)
  }
}

public struct _TupleView3<C0: View, C1: View, C2: View>: _PrimitiveView {
  let c0: C0; let c1: C1; let c2: C2
  init(_ c0: C0, _ c1: C1, _ c2: C2) { self.c0 = c0; self.c1 = c1; self.c2 = c2 }
  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    c0.walk(&visitor); c1.walk(&visitor); c2.walk(&visitor)
  }
}

public struct _TupleView4<C0: View, C1: View, C2: View, C3: View>: _PrimitiveView {
  let c0: C0; let c1: C1; let c2: C2; let c3: C3
  init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) { self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3 }
  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    c0.walk(&visitor); c1.walk(&visitor); c2.walk(&visitor); c3.walk(&visitor)
  }
}

public struct _TupleView5<C0: View, C1: View, C2: View, C3: View, C4: View>: _PrimitiveView {
  let c0: C0; let c1: C1; let c2: C2; let c3: C3; let c4: C4
  init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) { self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3; self.c4 = c4 }
  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    c0.walk(&visitor); c1.walk(&visitor); c2.walk(&visitor); c3.walk(&visitor); c4.walk(&visitor)
  }
}

public struct _TupleView6<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>: _PrimitiveView {
  let c0: C0; let c1: C1; let c2: C2; let c3: C3; let c4: C4; let c5: C5
  init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) { self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3; self.c4 = c4; self.c5 = c5 }
  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    c0.walk(&visitor); c1.walk(&visitor); c2.walk(&visitor); c3.walk(&visitor); c4.walk(&visitor); c5.walk(&visitor)
  }
}

public struct _TupleView7<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>: _PrimitiveView {
  let c0: C0; let c1: C1; let c2: C2; let c3: C3; let c4: C4; let c5: C5; let c6: C6
  init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) { self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3; self.c4 = c4; self.c5 = c5; self.c6 = c6 }
  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    c0.walk(&visitor); c1.walk(&visitor); c2.walk(&visitor); c3.walk(&visitor); c4.walk(&visitor); c5.walk(&visitor); c6.walk(&visitor)
  }
}

public struct _TupleView8<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>: _PrimitiveView {
  let c0: C0; let c1: C1; let c2: C2; let c3: C3; let c4: C4; let c5: C5; let c6: C6; let c7: C7
  init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) { self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3; self.c4 = c4; self.c5 = c5; self.c6 = c6; self.c7 = c7 }
  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    c0.walk(&visitor); c1.walk(&visitor); c2.walk(&visitor); c3.walk(&visitor); c4.walk(&visitor); c5.walk(&visitor); c6.walk(&visitor); c7.walk(&visitor)
  }
}

public struct _TupleView9<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>: _PrimitiveView {
  let c0: C0; let c1: C1; let c2: C2; let c3: C3; let c4: C4; let c5: C5; let c6: C6; let c7: C7; let c8: C8
  init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) { self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3; self.c4 = c4; self.c5 = c5; self.c6 = c6; self.c7 = c7; self.c8 = c8 }
  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    c0.walk(&visitor); c1.walk(&visitor); c2.walk(&visitor); c3.walk(&visitor); c4.walk(&visitor); c5.walk(&visitor); c6.walk(&visitor); c7.walk(&visitor); c8.walk(&visitor)
  }
}

public struct _TupleView10<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>: _PrimitiveView {
  let c0: C0; let c1: C1; let c2: C2; let c3: C3; let c4: C4; let c5: C5; let c6: C6; let c7: C7; let c8: C8; let c9: C9
  init(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) { self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3; self.c4 = c4; self.c5 = c5; self.c6 = c6; self.c7 = c7; self.c8 = c8; self.c9 = c9 }
  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    c0.walk(&visitor); c1.walk(&visitor); c2.walk(&visitor); c3.walk(&visitor); c4.walk(&visitor); c5.walk(&visitor); c6.walk(&visitor); c7.walk(&visitor); c8.walk(&visitor); c9.walk(&visitor)
  }
}
