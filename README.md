# Tokmak

SwiftUI-compatible framework for small browser apps with Embedded Swift and WebAssembly.

Tokmak follows Tokamak's renderer split while remaining self-contained:

- `SwiftUI` provides the lightweight view, state, and reconciliation core.
- `TokmakStaticHTML` renders views to deterministic HTML.
- `TokmakDOM` connects HTML and actions to a browser host.
- External renderers, such as Newton's LVGL renderer, depend only on the core.

There are no package dependencies and no JavaScript object bridge. The browser host uses standard
`WebAssembly` and DOM APIs to read rendered UTF-8 from module memory and dispatch action identifiers.

## Example

```swift
import SwiftUI
import TokmakDOM

struct Counter: View {
  @State private var count = 0

  var body: some View {
    VStack {
      Text("Count: \(count)")
      Button("Increment") { count += 1 }
    }
  }
}

@_cdecl("tokmak_start")
public func start() {
  mount(Counter())
}
```

## Build

```sh
make
make test
make clean
```

The Swift modules compile for `wasm32-unknown-none-wasm` with Embedded Swift. Final browser linking
still requires the small freestanding runtime to cover the standard library's libc and Unicode
entry points; that runtime is intentionally kept local rather than replaced by JavaScriptKit.
