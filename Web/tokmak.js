const app = document.querySelector("#app");
const { instance } = await WebAssembly.instantiateStreaming(
  fetch("./TokmakWebDemo.wasm"),
  {}
);
const exports = instance.exports;
const decoder = new TextDecoder();

function commit() {
  const start = exports.tokmak_html();
  const length = exports.tokmak_html_length();
  app.innerHTML = decoder.decode(
    new Uint8Array(exports.memory.buffer, start, length)
  );
}

app.addEventListener("click", event => {
  const control = event.target.closest("[data-tokmak-action]");
  if (!control) return;
  exports.tokmak_event(Number(control.dataset.tokmakAction));
  commit();
});

exports.tokmak_start();
commit();
