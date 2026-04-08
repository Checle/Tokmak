# Tokmak ESP-IDF Example

This is a minimal scaffold showing how to integrate Tokmak with ESP-IDF
without making Tokmak itself own the ESP-IDF link step.

## Layout

- `main/`: ESP-IDF-owned sources, including `app_main` and the hardware bridge.
- `swift-app/`: a small local Swift package that depends on the Tokmak repo and
  exports a C-callable entry point.

## Ownership

- The ESP-IDF firmware target owns:
  - ESP-IDF component registration
  - SPI/GPIO setup
  - final linking against ESP-IDF
- The Swift package owns:
  - the Tokmak app definition
  - the call into `MyApp.main()`

## Build Notes

This example is a scaffold. It is intended to be built from an ESP-IDF
environment and expects a Swift toolchain with Embedded support.

The ESP-IDF component build invokes `swift build` for `swift-app/` and links the
resulting static library into the component.

You will likely need to set `TOKMAK_SWIFT_EXTRA_ARGS` in
`main/CMakeLists.txt` for your actual Swift Embedded toolchain, for example:

```cmake
set(TOKMAK_SWIFT_EXTRA_ARGS
    "--triple riscv32-none-none-eabi"
    CACHE STRING
    "Extra arguments passed to swift build")
```

or:

```cmake
set(TOKMAK_SWIFT_EXTRA_ARGS
    "--swift-sdk /path/to/swift-sdk"
    CACHE STRING
    "Extra arguments passed to swift build")
```

The exact triple depends on your ESP target and Swift toolchain support.

## App Bridge

The contract between Tokmak and the firmware target is:

- `tokmak_swift_main()`: exported by Swift and called from `app_main()`
- `tokmak_esp_idf_board_init()`: implemented in C and called before Swift starts
- `tokmak_esp_idf_delay_ms()`
- `tokmak_esp_idf_gpio_set_level()`
- `tokmak_esp_idf_gpio_get_level()`
- `tokmak_esp_idf_spi_write()`

Those bridge functions are consumed by Tokmak's `CLVGL` driver when
`TOKMAK_PLATFORM_ESP_IDF=1` is enabled.
