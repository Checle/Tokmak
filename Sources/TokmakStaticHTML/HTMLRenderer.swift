import SwiftUI

public final class HTMLRenderer {
  private var rootFiber = FiberNode()
  private var actions: [() -> Void] = []
  private var renderRoot: (() -> String)?

  public init() {}

  public func render<V: View>(_ view: V) -> String {
    renderRoot = { [self] in renderPass(view) }
    return renderPass(view)
  }

  public func perform(action id: Int) -> String? {
    guard actions.indices.contains(id) else { return nil }
    actions[id]()
    return renderRoot?()
  }

  private func renderPass<V: View>(_ view: V) -> String {
    actions.removeAll(keepingCapacity: true)
    var walker = HTMLWalker(
      renderer: self,
      currentFiber: rootFiber
    )
    view.walk(&walker)
    return walker.output
  }

  fileprivate func register(action: @escaping () -> Void) -> Int {
    actions.append(action)
    return actions.count - 1
  }

  fileprivate func requestRedraw() {
    _ = renderRoot?()
  }
}

private struct HTMLWalker: ReconciliationWalker {
  let renderer: HTMLRenderer
  var currentFiber: FiberNode?
  var childIndex = 0
  var output = ""

  mutating func visit<V: View>(_ view: V) {
    if view.isPrimitive {
      view._visit(&self)
    } else {
      visitBody(view)
    }
  }

  mutating func visitNativeView<V: NativeView>(_ view: V) {}

  mutating func visitText(_ view: Text) {
    output += "<span>\(escape(_TextProxy(view).rawText))</span>"
    childIndex += 1
  }

  mutating func visitVStack<V: View>(_ view: VStack<V>) {
    wrap("div", className: "tokmak-vstack", content: view.body)
  }

  mutating func visitHStack<V: View>(_ view: HStack<V>) {
    wrap("div", className: "tokmak-hstack", content: view.body)
  }

  mutating func visitZStack<V: View>(_ view: ZStack<V>) {
    wrap("div", className: "tokmak-zstack", content: view.body)
  }

  mutating func visitTabView<V: View>(_ view: TabView<V>) {
    wrap("div", className: "tokmak-tabs", content: view.body)
  }

  mutating func visitButton<V: View>(_ view: Button<V>) {
    let action = renderer.register(action: view.action)
    output += "<button data-tokmak-action=\"\(action)\">"
    view.label.walk(&self)
    output += "</button>"
  }

  mutating func visitSpacer(_ view: Spacer) {
    output += "<span class=\"tokmak-spacer\"></span>"
    childIndex += 1
  }

  mutating func visitDivider(_ view: Divider) {
    output += "<hr>"
    childIndex += 1
  }

  mutating func visitImage(_ view: Image) {
    output += "<img src=\"\(escapeAttribute(view.source))\" alt=\"\">"
    childIndex += 1
  }

  mutating func visitTextField(_ view: TextField) {
    output += "<input type=\"text\" placeholder=\"\(escapeAttribute(view.title))\" value=\"\(escapeAttribute(view.text.wrappedValue))\">"
    childIndex += 1
  }

  mutating func visitTextEditor(_ view: TextEditor) {
    output += "<textarea>\(escape(view.text.wrappedValue))</textarea>"
    childIndex += 1
  }

  mutating func visitList<V: View>(_ view: List<V>) {
    wrap("div", className: "tokmak-list", content: view.body)
  }

  mutating func visitNavigationStack<V: View>(_ view: NavigationStack<V>) {
    wrap("nav", className: "tokmak-navigation", content: view.body)
  }

  mutating func visitNavigationLink<L: View, D: View>(_ view: NavigationLink<L, D>) {
    wrap("span", className: "tokmak-navigation-link", content: view.label)
  }

  mutating func visitForEach<Data, ID, Content>(_ view: ForEach<Data, ID, Content>) {
    view.body.walk(&self)
  }

  mutating func visitGroup<V: View>(_ view: Group<V>) {
    view.content.walk(&self)
  }

  mutating func visitScrollView<V: View>(_ view: ScrollView<V>) {
    wrap("div", className: "tokmak-scroll", content: view.body)
  }

  mutating func visitScrollViewReader<V: View>(_ view: ScrollViewReader<V>) {
    view.body.walk(&self)
  }

  mutating func visitInlineFlow<V: View>(_ view: _InlineFlow<V>) {
    wrap("span", className: "tokmak-inline", content: view.body)
  }

  mutating func visitContentUnavailableView(_ view: ContentUnavailableView) {
    wrap("div", className: "tokmak-unavailable", content: view.body)
  }

  mutating func visitIdentifiedView<V: View>(_ view: _IdentifiedView<V>) {
    visitBody(view)
  }

  mutating func visitFilledShape<S: Shape>(_ view: _FilledShape<S>) {
    output += "<span class=\"tokmak-shape\"></span>"
    childIndex += 1
  }

  mutating func visitFrameView<V: View>(_ view: _FrameView<V>) {
    wrap("div", className: "tokmak-frame", content: view.body)
  }

  mutating func visitPaddingView<V: View>(_ view: _PaddingView<V>) {
    wrap("div", className: "tokmak-padding", content: view.body)
  }

  mutating func visitClipShapeView<V: View, S: Shape>(_ view: _ClipShapeView<V, S>) {
    wrap("div", className: "tokmak-clipped", content: view.body)
  }

  mutating func visitBackgroundView<V: View>(_ view: _BackgroundView<V>) {
    wrap("div", className: "tokmak-background", content: view.body)
  }

  mutating func visitForegroundStyleView<V: View>(_ view: _ForegroundStyleView<V>) {
    wrap("span", className: "tokmak-foreground", content: view.body)
  }

  mutating func visitButtonStyleView<V: View, S: ButtonStyle>(_ view: _ButtonStyleView<V, S>) {
    view.body.walk(&self)
  }

  mutating func visitMultilineTextAlignmentView<V: View>(_ view: _MultilineTextAlignmentView<V>) {
    view.body.walk(&self)
  }

  private mutating func visitBody<V: View>(_ view: V) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    let entry = currentFiber?.reconcileChild(
      V.self,
      at: childIndex,
      identity: view.reconciliationIdentity
    )
    currentFiber = entry?.fiber
    childIndex = 0

    withStateContext(fiber: currentFiber, redraw: renderer.requestRedraw) {
      view._visit(&self)
    }

    currentFiber = originalFiber
    childIndex = originalIndex + 1
  }

  private mutating func wrap<V: View>(
    _ tag: String,
    className: String,
    content: V
  ) {
    output += "<\(tag) class=\"\(className)\">"
    content.walk(&self)
    output += "</\(tag)>"
  }
}

private func escape(_ value: String) -> String {
  var escaped = ""
  for character in value {
    switch character {
    case "&": escaped += "&amp;"
    case "<": escaped += "&lt;"
    case ">": escaped += "&gt;"
    default: escaped.append(character)
    }
  }
  return escaped
}

private func escapeAttribute(_ value: String) -> String {
  var escaped = ""
  for character in value {
    switch character {
    case "&": escaped += "&amp;"
    case "<": escaped += "&lt;"
    case ">": escaped += "&gt;"
    case "\"": escaped += "&quot;"
    default: escaped.append(character)
    }
  }
  return escaped
}
