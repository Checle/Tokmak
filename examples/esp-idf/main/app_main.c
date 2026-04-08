#include <stddef.h>

extern void tokmak_esp_idf_board_init(void);
extern void tokmak_swift_main(void);

void app_main(void) {
    tokmak_esp_idf_board_init();
    tokmak_swift_main();
}
