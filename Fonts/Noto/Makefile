OUT := ../../Sources/CLVGL/Fonts/Noto
RANGE := 0x20-0x7F,0xB0,0x2022
CONVERT := npx --yes lv_font_conv --no-compress --no-prefilter --bpp 4 --format lvgl --force-fast-kern-format

.PHONY: all
all: \
	$(OUT)/lv_font_noto_sans_light_32.c \
	$(OUT)/lv_font_noto_sans_light_56.c \
	$(OUT)/lv_font_noto_sans_regular_14.c \
	$(OUT)/lv_font_noto_sans_regular_16.c \
	$(OUT)/lv_font_noto_sans_bold_14.c \
	$(OUT)/lv_font_noto_sans_bold_16.c

$(OUT)/lv_font_noto_sans_light_32.c: NotoSans-Light.ttf
	$(CONVERT) --size 32 --font $< -r $(RANGE) -o $@

$(OUT)/lv_font_noto_sans_light_56.c: NotoSans-Light.ttf
	$(CONVERT) --size 56 --font $< -r $(RANGE) -o $@

$(OUT)/lv_font_noto_sans_regular_14.c: NotoSans-Regular.ttf
	$(CONVERT) --size 14 --font $< -r $(RANGE) -o $@

$(OUT)/lv_font_noto_sans_regular_16.c: NotoSans-Regular.ttf
	$(CONVERT) --size 16 --font $< -r $(RANGE) -o $@

$(OUT)/lv_font_noto_sans_bold_14.c: NotoSans-Bold.ttf
	$(CONVERT) --size 14 --font $< -r $(RANGE) -o $@

$(OUT)/lv_font_noto_sans_bold_16.c: NotoSans-Bold.ttf
	$(CONVERT) --size 16 --font $< -r $(RANGE) -o $@
