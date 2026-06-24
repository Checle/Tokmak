#if defined(__wasm__)

typedef __SIZE_TYPE__ size_t;
typedef unsigned char byte;

extern byte __heap_base;

typedef struct {
  size_t size;
} allocation_header;

static size_t heap_cursor;
void *__stack_chk_guard = (void *)0x9e3779b9;

static size_t align_up(size_t value, size_t alignment) {
  return (value + alignment - 1) & ~(alignment - 1);
}

static int ensure_memory(size_t end) {
  size_t pages = __builtin_wasm_memory_size(0);
  size_t bytes = pages * 65536;
  if (end <= bytes) return 1;

  size_t missing = end - bytes;
  size_t growth = (missing + 65535) / 65536;
  return __builtin_wasm_memory_grow(0, growth) != (size_t)-1;
}

void *malloc(size_t size) {
  if (heap_cursor == 0) heap_cursor = (size_t)&__heap_base;

  size_t header = align_up(heap_cursor, 16);
  size_t payload = header + sizeof(allocation_header);
  size_t end = align_up(payload + size, 16);
  if (!ensure_memory(end)) return 0;

  ((allocation_header *)header)->size = size;
  heap_cursor = end;
  return (void *)payload;
}

void free(void *pointer) {
  (void)pointer;
}

void *calloc(size_t count, size_t size) {
  size_t total = count * size;
  byte *pointer = (byte *)malloc(total);
  if (!pointer) return 0;
  for (size_t index = 0; index < total; ++index) pointer[index] = 0;
  return pointer;
}

void *realloc(void *pointer, size_t size) {
  if (!pointer) return malloc(size);

  allocation_header *header =
      (allocation_header *)((byte *)pointer - sizeof(allocation_header));
  void *replacement = malloc(size);
  if (!replacement) return 0;

  size_t count = header->size < size ? header->size : size;
  for (size_t index = 0; index < count; ++index) {
    ((byte *)replacement)[index] = ((byte *)pointer)[index];
  }
  return replacement;
}

int posix_memalign(void **result, size_t alignment, size_t size) {
  if (heap_cursor == 0) heap_cursor = (size_t)&__heap_base;

  size_t payload = align_up(
      heap_cursor + sizeof(allocation_header),
      alignment
  );
  size_t header = payload - sizeof(allocation_header);
  size_t end = align_up(payload + size, 16);
  if (!ensure_memory(end)) return 12;

  ((allocation_header *)header)->size = size;
  heap_cursor = end;
  *result = (void *)payload;
  return 0;
}

void arc4random_buf(void *buffer, size_t count) {
  static unsigned state = 0x6d2b79f5;
  byte *bytes = (byte *)buffer;
  for (size_t index = 0; index < count; ++index) {
    state ^= state << 13;
    state ^= state >> 17;
    state ^= state << 5;
    bytes[index] = (byte)state;
  }
}

void __stack_chk_fail(void) {
  __builtin_trap();
}

unsigned char _swift_stdlib_getGraphemeBreakProperty(unsigned scalar) {
  (void)scalar;
  return 0;
}

#endif
