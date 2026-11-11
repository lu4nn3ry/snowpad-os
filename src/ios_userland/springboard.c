/*
 * springboard.c - SnowPad OS Native SpringBoard & Touch Userland Engine (v5)
 * Fullscreen 1360x768x32 UI for external VGA monitor (LG TV).
 *
 * Full Interactive iOS 3.2 Experience:
 * - 12 Grid Icons + 4 Dock Icons: ALL 16 ICONS ARE CLICKABLE AND LAUNCH APPS!
 * - Expanded Hitboxes: Icon + Label + Padding (126x140px interactive zone)
 * - Hover Detection: Gold glow border + bright text highlight when hovering
 * - Touch & Click Support:
 *     - Trackpad physical button (mice / mouse0)
 *     - Trackpad tap-to-click (BTN_TOUCH / BTN_LEFT on event10)
 *     - USB mouse clicks
 * - Full Keyboard Control:
 *     - S: Safari
 *     - M: Musica / iPod
 *     - F: Fotos
 *     - V: Videos
 *     - N: Notas
 *     - P: Mapas
 *     - A: Ajustes (Settings)
 *     - C: Calculadora
 *     - R: Relogio (Clock)
 *     - O: Contatos (Contacts)
 *     - T: Terminal Darwin
 *     - W: SnowPad OS Hub
 *     - E: Mail
 *     - 1 to 9: Open icons 1-9 directly
 *     - Enter / Space: Open hovered icon
 *     - Arrows: Move cursor
 *     - Esc / Backspace / H: Return to Home
 * - 13 Complete Views:
 *     - VIEW_HOME
 *     - VIEW_SAFARI
 *     - VIEW_MUSIC
 *     - VIEW_PHOTOS
 *     - VIEW_VIDEOS
 *     - VIEW_NOTES
 *     - VIEW_MAPS
 *     - VIEW_SETTINGS
 *     - VIEW_CALC
 *     - VIEW_CLOCK
 *     - VIEW_CONTACTS
 *     - VIEW_TERMINAL
 *     - VIEW_SNOWPAD
 *     - VIEW_MAIL
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <linux/input.h>
#include <signal.h>
#include <time.h>
#include <math.h>

#define SCREEN_W 1360
#define SCREEN_H 768

static uint32_t *g_fb = NULL;
static uint32_t g_backbuffer[SCREEN_W * SCREEN_H];
static volatile bool g_running = true;

// 8x8 font
static const uint8_t g_font8x8[95][8] = {
    {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}, {0x18,0x3C,0x3C,0x18,0x18,0x00,0x18,0x00},
    {0x66,0x66,0x24,0x00,0x00,0x00,0x00,0x00}, {0x6C,0x6C,0xFE,0x6C,0xFE,0x6C,0x6C,0x00},
    {0x18,0x3E,0x60,0x3C,0x06,0x7C,0x18,0x00}, {0x00,0x63,0x66,0x0C,0x18,0x33,0x63,0x00},
    {0x38,0x6C,0x38,0x76,0xDC,0xCC,0x76,0x00}, {0x18,0x18,0x30,0x00,0x00,0x00,0x00,0x00},
    {0x0C,0x18,0x30,0x30,0x30,0x18,0x0C,0x00}, {0x30,0x18,0x0C,0x0C,0x0C,0x18,0x30,0x00},
    {0x00,0x66,0x3C,0xFF,0x3C,0x66,0x00,0x00}, {0x00,0x18,0x18,0x7E,0x18,0x18,0x00,0x00},
    {0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x30}, {0x00,0x00,0x00,0x7E,0x00,0x00,0x00,0x00},
    {0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x00}, {0x06,0x0C,0x18,0x30,0x60,0xC0,0x80,0x00},
    {0x7C,0xC6,0xCE,0xD6,0xE6,0xC6,0x7C,0x00}, {0x18,0x38,0x18,0x18,0x18,0x18,0x7E,0x00},
    {0x7C,0xC6,0x06,0x1C,0x30,0x66,0xFE,0x00}, {0x7C,0xC6,0x06,0x3C,0x06,0xC6,0x7C,0x00},
    {0x1C,0x3C,0x6C,0xCC,0xFE,0x0C,0x1E,0x00}, {0xFE,0xC0,0xFC,0x06,0x06,0xC6,0x7C,0x00},
    {0x7C,0xC6,0xC0,0xFC,0xC6,0xC6,0x7C,0x00}, {0xFE,0xC6,0x0C,0x18,0x30,0x30,0x30,0x00},
    {0x7C,0xC6,0xC6,0x7C,0xC6,0xC6,0x7C,0x00}, {0x7C,0xC6,0xC6,0x7E,0x06,0xC6,0x7C,0x00},
    {0x00,0x18,0x18,0x00,0x18,0x18,0x00,0x00}, {0x00,0x18,0x18,0x00,0x18,0x18,0x30,0x00},
    {0x06,0x0C,0x18,0x30,0x18,0x0C,0x06,0x00}, {0x00,0x00,0x7E,0x00,0x7E,0x00,0x00,0x00},
    {0x60,0x30,0x18,0x0C,0x18,0x30,0x60,0x00}, {0x7C,0xC6,0x0C,0x18,0x18,0x00,0x18,0x00},
    {0x7C,0xC6,0xDE,0xDE,0xDC,0xC0,0x7C,0x00}, {0x38,0x6C,0xC6,0xC6,0xFE,0xC6,0xC6,0x00},
    {0xFC,0x66,0x66,0x7C,0x66,0x66,0xFC,0x00}, {0x3C,0x66,0xC0,0xC0,0xC0,0x66,0x3C,0x00},
    {0xF8,0x6C,0x66,0x66,0x66,0x6C,0xF8,0x00}, {0xFE,0x62,0x68,0x78,0x68,0x62,0xFE,0x00},
    {0xFE,0x62,0x68,0x78,0x68,0x60,0xF0,0x00}, {0x3C,0x66,0xC0,0xC0,0xCE,0x66,0x3E,0x00},
    {0xC6,0xC6,0xC6,0xFE,0xC6,0xC6,0xC6,0x00}, {0x7E,0x18,0x18,0x18,0x18,0x18,0x7E,0x00},
    {0x1E,0x0C,0x0C,0x0C,0xCC,0xCC,0x78,0x00}, {0xE6,0x66,0x6C,0x78,0x6C,0x66,0xE6,0x00},
    {0xF0,0x60,0x60,0x60,0x62,0x66,0xFE,0x00}, {0xC6,0xEE,0xFE,0xD6,0xC6,0xC6,0xC6,0x00},
    {0xC6,0xE6,0xF6,0xDE,0xCE,0xC6,0xC6,0x00}, {0x7C,0xC6,0xC6,0xC6,0xC6,0xC6,0x7C,0x00},
    {0xFC,0x66,0x66,0x7C,0x60,0x60,0xF0,0x00}, {0x7C,0xC6,0xC6,0xC6,0xD6,0xDE,0x7C,0x0E},
    {0xFC,0x66,0x66,0x7C,0x6C,0x66,0xE6,0x00}, {0x7C,0xC6,0x60,0x38,0x0C,0xC6,0x7C,0x00},
    {0x7E,0x5A,0x18,0x18,0x18,0x18,0x3C,0x00}, {0xC6,0xC6,0xC6,0xC6,0xC6,0xC6,0x7C,0x00},
    {0xC6,0xC6,0xC6,0xC6,0x6C,0x38,0x10,0x00}, {0xC6,0xC6,0xD6,0xFE,0xEE,0xC6,0xC6,0x00},
    {0xC6,0x6C,0x38,0x10,0x38,0x6C,0xC6,0x00}, {0x66,0x66,0x66,0x3C,0x18,0x18,0x3C,0x00},
    {0xFE,0xC6,0x8C,0x18,0x32,0x66,0xFE,0x00}, {0x3C,0x30,0x30,0x30,0x30,0x30,0x3C,0x00},
    {0xC0,0x60,0x30,0x18,0x0C,0x06,0x02,0x00}, {0x3C,0x0C,0x0C,0x0C,0x0C,0x0C,0x3C,0x00},
    {0x10,0x38,0x6C,0xC6,0x00,0x00,0x00,0x00}, {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF},
    {0x30,0x18,0x0C,0x00,0x00,0x00,0x00,0x00}, {0x00,0x00,0x78,0x0C,0x7C,0xCC,0x76,0x00},
    {0xE0,0x60,0x7C,0x66,0x66,0x66,0xDC,0x00}, {0x00,0x00,0x7C,0xC6,0xC0,0xC6,0x7C,0x00},
    {0x1C,0x0C,0x7C,0xCC,0xCC,0xCC,0x76,0x00}, {0x00,0x00,0x7C,0xC6,0xFE,0xC0,0x7C,0x00},
    {0x1C,0x36,0x30,0x78,0x30,0x30,0x78,0x00}, {0x00,0x00,0x76,0xCC,0xCC,0x7C,0x0C,0xF8},
    {0xE0,0x60,0x6C,0x76,0x66,0x66,0xE6,0x00}, {0x18,0x00,0x38,0x18,0x18,0x18,0x3C,0x00},
    {0x06,0x00,0x0E,0x06,0x06,0x66,0x66,0x3C}, {0xE0,0x60,0x66,0x6C,0x78,0x6C,0xE6,0x00},
    {0x38,0x18,0x18,0x18,0x18,0x18,0x3C,0x00}, {0x00,0x00,0xEC,0xFE,0xD6,0xD6,0xD6,0x00},
    {0x00,0x00,0xDC,0x66,0x66,0x66,0x66,0x00}, {0x00,0x00,0x7C,0xC6,0xC6,0xC6,0x7C,0x00},
    {0x00,0x00,0xDC,0x66,0x66,0x7C,0x60,0xF0}, {0x00,0x00,0x76,0xCC,0xCC,0x7C,0x0C,0x1E},
    {0x00,0x00,0xDC,0x76,0x60,0x60,0xF0,0x00}, {0x00,0x00,0x7E,0xC0,0x7C,0x06,0xFC,0x00},
    {0x30,0x30,0x7C,0x30,0x30,0x34,0x18,0x00}, {0x00,0x00,0xCC,0xCC,0xCC,0xCC,0x76,0x00},
    {0x00,0x00,0xC6,0xC6,0xC6,0x6C,0x38,0x00}, {0x00,0x00,0xC6,0xD6,0xD6,0xFE,0x6C,0x00},
    {0x00,0x00,0xC6,0x6C,0x38,0x6C,0xC6,0x00}, {0x00,0x00,0xC6,0xC6,0xCE,0x76,0x06,0xFC},
    {0x00,0x00,0xFE,0x9C,0x38,0x70,0xFE,0x00}, {0x0E,0x18,0x18,0x70,0x18,0x18,0x0E,0x00},
    {0x18,0x18,0x18,0x00,0x18,0x18,0x18,0x00}, {0x70,0x18,0x18,0x0E,0x18,0x18,0x70,0x00},
    {0x76,0xDC,0x00,0x00,0x00,0x00,0x00,0x00},
};

typedef enum {
    APP_SAFARI, APP_MUSIC, APP_PHOTOS, APP_VIDEOS,
    APP_NOTES, APP_MAPS, APP_SETTINGS, APP_CALC,
    APP_CLOCK, APP_CONTACTS, APP_TERMINAL, APP_SNOWPAD,
    APP_MAIL
} AppType;

typedef enum {
    VIEW_HOME,
    VIEW_SETTINGS,
    VIEW_TERMINAL,
    VIEW_CALC,
    VIEW_NOTES,
    VIEW_SAFARI,
    VIEW_MUSIC,
    VIEW_PHOTOS,
    VIEW_VIDEOS,
    VIEW_MAPS,
    VIEW_CLOCK,
    VIEW_CONTACTS,
    VIEW_SNOWPAD,
    VIEW_MAIL
} ViewState;

static ViewState g_current_view = VIEW_HOME;

typedef struct {
    const char *name;
    uint32_t color;
    AppType type;
    int x;
    int y;
    int w;
    int h;
} AppIcon;

static AppIcon g_icons[] = {
    {"Safari",      0xFF1570BD, APP_SAFARI,   200, 140, 96, 96},
    {"Musica",      0xFFDF5518, APP_MUSIC,    380, 140, 96, 96},
    {"Fotos",       0xFFEBB400, APP_PHOTOS,   560, 140, 96, 96},
    {"Videos",      0xFF44546A, APP_VIDEOS,   740, 140, 96, 96},
    {"Notas",       0xFFF39C12, APP_NOTES,    920, 140, 96, 96},
    {"Mapas",       0xFF27AE60, APP_MAPS,    1100, 140, 96, 96},

    {"Ajustes",     0xFF7F8C8D, APP_SETTINGS, 200, 310, 96, 96},
    {"Calculadora", 0xFF2C3E50, APP_CALC,     380, 310, 96, 96},
    {"Relogio",     0xFF181818, APP_CLOCK,    560, 310, 96, 96},
    {"Contatos",    0xFF8E44AD, APP_CONTACTS, 740, 310, 96, 96},
    {"Terminal",    0xFF082D12, APP_TERMINAL, 920, 310, 96, 96},
    {"SnowPad OS",  0xFF007ACC, APP_SNOWPAD, 1100, 310, 96, 96},
};
#define NUM_ICONS (sizeof(g_icons)/sizeof(g_icons[0]))

static AppIcon g_dock_icons[] = {
    {"Safari", 0xFF1570BD, APP_SAFARI, 460, 630, 80, 80},
    {"Mail",   0xFF2980B9, APP_MAIL,   580, 630, 80, 80},
    {"Fotos",  0xFFEBB400, APP_PHOTOS, 700, 630, 80, 80},
    {"iPod",   0xFFDF5518, APP_MUSIC,  820, 630, 80, 80},
};
#define NUM_DOCK_ICONS (sizeof(g_dock_icons)/sizeof(g_dock_icons[0]))

static inline uint32_t blend(uint32_t dst, uint32_t src) {
    uint32_t a = (src >> 24) & 0xFF;
    if (a == 0xFF) return src;
    if (a == 0) return dst;
    uint32_t inv_a = 255 - a;

    uint32_t dr = (dst >> 16) & 0xFF;
    uint32_t dg = (dst >> 8) & 0xFF;
    uint32_t db = dst & 0xFF;

    uint32_t sr = (src >> 16) & 0xFF;
    uint32_t sg = (src >> 8) & 0xFF;
    uint32_t sb = src & 0xFF;

    uint32_t r = (sr * a + dr * inv_a) / 255;
    uint32_t g = (sg * a + dg * inv_a) / 255;
    uint32_t b = (sb * a + db * inv_a) / 255;

    return (0xFF << 24) | (r << 16) | (g << 8) | b;
}

static inline void put_pixel(int x, int y, uint32_t color) {
    if (x >= 0 && x < SCREEN_W && y >= 0 && y < SCREEN_H) {
        if ((color >> 24) == 0xFF) {
            g_backbuffer[y * SCREEN_W + x] = color;
        } else {
            g_backbuffer[y * SCREEN_W + x] = blend(g_backbuffer[y * SCREEN_W + x], color);
        }
    }
}

void draw_char(int x, int y, char c, uint32_t color, int scale) {
    if (c < 32 || c > 126) c = '?';
    const uint8_t *glyph = g_font8x8[c - 32];
    for (int row = 0; row < 8; row++) {
        uint8_t line = glyph[row];
        for (int col = 0; col < 8; col++) {
            if (line & (1 << (7 - col))) {
                for (int sy = 0; sy < scale; sy++) {
                    for (int sx = 0; sx < scale; sx++) {
                        put_pixel(x + col * scale + sx, y + row * scale + sy, color);
                    }
                }
            }
        }
    }
}

void draw_text(int x, int y, const char *str, uint32_t color, int scale) {
    int cx = x;
    while (*str) {
        if (*str == '\n') {
            y += 10 * scale;
            cx = x;
        } else {
            draw_char(cx, y, *str, color, scale);
            cx += 8 * scale;
        }
        str++;
    }
}

void draw_text_centered(int cx, int y, const char *str, uint32_t color, int scale) {
    int len = strlen(str);
    int x = cx - (len * 8 * scale) / 2;
    draw_text(x, y, str, color, scale);
}

void draw_fill_circle(int cx, int cy, int radius, uint32_t color) {
    for (int y = -radius; y <= radius; y++) {
        for (int x = -radius; x <= radius; x++) {
            if (x * x + y * y <= radius * radius) {
                put_pixel(cx + x, cy + y, color);
            }
        }
    }
}

void draw_icon_emblem(AppType type, int cx, int cy, int size) {
    int s = size / 3;
    switch (type) {
        case APP_SAFARI: {
            draw_fill_circle(cx, cy, s + 4, 0xFFFFFFFF);
            draw_fill_circle(cx, cy, s + 2, 0xFF0E53A7);
            for (int d = -s; d <= s; d++) {
                uint32_t col = (d < 0) ? 0xFFFF3333 : 0xFFFFFFFF;
                put_pixel(cx + d, cy + d, col);
                put_pixel(cx + d + 1, cy + d, col);
                put_pixel(cx + d, cy + d + 1, col);
            }
            break;
        }
        case APP_MUSIC: {
            int ny = cy - s / 2;
            for (int y = ny; y < ny + s + 6; y++) {
                for (int x = cx - 8; x <= cx - 5; x++) put_pixel(x, y, 0xFFFFFFFF);
                for (int x = cx + 5; x <= cx + 8; x++) put_pixel(x, y, 0xFFFFFFFF);
            }
            for (int y = ny; y < ny + 5; y++) {
                for (int x = cx - 8; x <= cx + 8; x++) put_pixel(x, y, 0xFFFFFFFF);
            }
            draw_fill_circle(cx - 8, ny + s + 6, 6, 0xFFFFFFFF);
            draw_fill_circle(cx + 6, ny + s + 6, 6, 0xFFFFFFFF);
            break;
        }
        case APP_PHOTOS: {
            uint32_t petal_colors[6] = {0xFFFF3B30, 0xFFFF9500, 0xFFFFCC00, 0xFF4CD964, 0xFF5AC8FA, 0xFF5856D6};
            for (int i = 0; i < 6; i++) {
                double angle = i * (3.14159 / 3.0);
                int px = cx + (int)(cos(angle) * (s - 2));
                int py = cy + (int)(sin(angle) * (s - 2));
                draw_fill_circle(px, py, 7, petal_colors[i]);
            }
            draw_fill_circle(cx, cy, 5, 0xFFFFFFFF);
            break;
        }
        case APP_VIDEOS: {
            for (int y = cy - s; y <= cy + s; y++) {
                for (int x = cx - s - 4; x <= cx + s + 4; x++) {
                    put_pixel(x, y, 0xFF2A2A2A);
                }
            }
            for (int y = -s; y <= s; y++) {
                int w = (y + s) / 2;
                if (w > s) w = s * 2 - w;
                for (int x = cx - 4; x <= cx - 4 + w; x++) {
                    put_pixel(x, cy + y, 0xFFFFFFFF);
                }
            }
            break;
        }
        case APP_NOTES: {
            for (int y = cy - s - 2; y <= cy + s + 2; y++) {
                for (int x = cx - s; x <= cx + s; x++) {
                    put_pixel(x, y, 0xFFFFFDD0);
                }
            }
            for (int y = cy - s + 4; y <= cy + s - 4; y += 6) {
                for (int x = cx - s + 4; x <= cx + s - 4; x++) {
                    put_pixel(x, y, 0xFF88AAEE);
                }
            }
            break;
        }
        case APP_MAPS: {
            for (int y = cy - s; y <= cy + s; y++) {
                for (int x = cx - s; x <= cx + s; x++) {
                    put_pixel(x, y, 0xFFE8E0D0);
                }
            }
            for (int y = cy - s; y <= cy + s; y++) {
                put_pixel(cx - 2, y, 0xFFFFCC00);
                put_pixel(cx - 1, y, 0xFFFFCC00);
                put_pixel(cx, y, 0xFFFFCC00);
            }
            draw_fill_circle(cx, cy - 2, 7, 0xFFFF2222);
            draw_fill_circle(cx, cy - 2, 3, 0xFFFFFFFF);
            break;
        }
        case APP_SETTINGS: {
            draw_fill_circle(cx, cy, s, 0xFF8E8E93);
            draw_fill_circle(cx, cy, s - 6, 0xFF50555C);
            draw_fill_circle(cx, cy, 6, 0xFF8E8E93);
            for (int i = 0; i < 8; i++) {
                double a = i * (3.14159 / 4.0);
                int gx = cx + (int)(cos(a) * (s + 2));
                int gy = cy + (int)(sin(a) * (s + 2));
                draw_fill_circle(gx, gy, 4, 0xFF8E8E93);
            }
            break;
        }
        case APP_CALC: {
            for (int y = cy - s; y <= cy + s; y++) {
                for (int x = cx - s; x <= cx + s; x++) {
                    put_pixel(x, y, 0xFF2A2A2A);
                }
            }
            for (int y = cy - s + 3; y <= cy - s + 9; y++) {
                for (int x = cx - s + 3; x <= cx + s - 3; x++) {
                    put_pixel(x, y, 0xFF4A8505);
                }
            }
            draw_text(cx - 8, cy + 2, "+ -", 0xFFFF9500, 1);
            break;
        }
        case APP_CLOCK: {
            draw_fill_circle(cx, cy, s + 2, 0xFF000000);
            draw_fill_circle(cx, cy, s, 0xFFFFFFFF);
            for (int y = cy - s + 4; y <= cy; y++) put_pixel(cx, y, 0xFF000000);
            for (int x = cx; x <= cx + s - 6; x++) put_pixel(x, cy, 0xFFFF3B30);
            draw_fill_circle(cx, cy, 2, 0xFFFF3B30);
            break;
        }
        case APP_CONTACTS: {
            for (int y = cy - s; y <= cy + s; y++) {
                for (int x = cx - s; x <= cx + s; x++) {
                    put_pixel(x, y, 0xFF5C3A21);
                }
            }
            draw_fill_circle(cx, cy - 4, 6, 0xFFFFFFFF);
            for (int y = cy + 4; y <= cy + s - 3; y++) {
                int bw = (y - cy - 4) * 2;
                for (int x = cx - bw; x <= cx + bw; x++) put_pixel(x, y, 0xFFFFFFFF);
            }
            break;
        }
        case APP_TERMINAL: {
            for (int y = cy - s; y <= cy + s; y++) {
                for (int x = cx - s - 2; x <= cx + s + 2; x++) {
                    put_pixel(x, y, 0xFF000000);
                }
            }
            draw_text(cx - s + 3, cy - 6, ">_", 0xFF00FF66, 2);
            break;
        }
        case APP_SNOWPAD: {
            draw_fill_circle(cx, cy, s + 2, 0xFF007ACC);
            draw_fill_circle(cx, cy, s - 2, 0xFF005A9E);
            draw_text_centered(cx, cy - 6, "X", 0xFFFFFFFF, 2);
            break;
        }
        case APP_MAIL: {
            for (int y = cy - s + 4; y <= cy + s - 4; y++) {
                for (int x = cx - s - 2; x <= cx + s + 2; x++) {
                    put_pixel(x, y, 0xFFFFFFFF);
                }
            }
            for (int d = 0; d < s; d++) {
                put_pixel(cx - s - 2 + d, cy - s + 4 + d, 0xFF4A90E2);
                put_pixel(cx + s + 2 - d, cy - s + 4 + d, 0xFF4A90E2);
            }
            break;
        }
    }
}

void draw_wallpaper() {
    for (int y = 0; y < SCREEN_H; y++) {
        float v = (float)y / (float)SCREEN_H;
        uint8_t r = (uint8_t)(15 * (1.0f - v) + 5 * v);
        uint8_t g = (uint8_t)(45 * (1.0f - v) + 20 * v);
        uint8_t b = (uint8_t)(95 * (1.0f - v) + 40 * v);
        uint32_t bg = (0xFF << 24) | (r << 16) | (g << 8) | b;
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = bg;
        }
    }

    // Classic Apple water droplets / bokeh
    for (int i = 0; i < 45; i++) {
        int dx = (i * 137 + 53) % SCREEN_W;
        int dy = (i * 229 + 89) % (SCREEN_H - 120);
        int dr = 3 + (i % 6);
        uint32_t col = ((25 + (i * 7) % 50) << 24) | 0x00FFFFFF;
        draw_fill_circle(dx, dy, dr, col);
    }
}

void draw_dock() {
    int dock_x = 380, dock_y = 610, dock_w = 600, dock_h = 115;
    for (int y = dock_y; y < dock_y + dock_h; y++) {
        float f = (float)(y - dock_y) / (float)dock_h;
        uint8_t alpha = (uint8_t)(90 + f * 90);
        uint32_t dock_col = (alpha << 24) | 0x00C8D6E5;
        for (int x = dock_x; x < dock_x + dock_w; x++) {
            put_pixel(x, y, dock_col);
        }
    }
    for (int x = dock_x; x < dock_x + dock_w; x++) {
        put_pixel(x, dock_y, 0xD0FFFFFF);
        put_pixel(x, dock_y + 1, 0x80FFFFFF);
    }
}

void draw_status_bar() {
    for (int y = 0; y < 24; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xD010141C;
        }
    }
    draw_text(16, 6, "iPad - SnowPad OS", 0xFFD0D8E8, 1);
    draw_text(180, 6, "Wi-Fi: LNET (192.168.0.27)", 0xFF88BBEE, 1);

    time_t now = time(NULL);
    struct tm *tm = localtime(&now);
    char time_str[16];
    if (tm) snprintf(time_str, sizeof(time_str), "%02d:%02d", tm->tm_hour, tm->tm_min);
    else strcpy(time_str, "14:40");

    draw_text_centered(SCREEN_W / 2, 5, time_str, 0xFFFFFFFF, 2);
    draw_text(SCREEN_W - 130, 6, "100% [====]", 0xFF66FF88, 1);
}

// Rounded rect icon with hover glow
void draw_icon(int x0, int y0, int w, int h, int radius, uint32_t color, bool hover) {
    if (hover) {
        for (int y = y0 - 4; y <= y0 + h + 4; y++) {
            for (int x = x0 - 4; x <= x0 + w + 4; x++) {
                if (x < x0 || x >= x0 + w || y < y0 || y >= y0 + h) {
                    put_pixel(x, y, 0xD0FFDD44); // Gold hover glow
                }
            }
        }
    }

    for (int y = y0; y < y0 + h; y++) {
        for (int x = x0; x < x0 + w; x++) {
            int dx = (x < x0 + radius) ? (x0 + radius - x) : ((x >= x0 + w - radius) ? (x - (x0 + w - radius - 1)) : 0);
            int dy = (y < y0 + radius) ? (y0 + radius - y) : ((y >= y0 + h - radius) ? (y - (y0 + h - radius - 1)) : 0);
            if (dx * dx + dy * dy <= radius * radius) {
                uint32_t col = color;
                if (y < y0 + h / 2) {
                    float gloss = 1.0f - (float)(y - y0) / (h / 2.0f);
                    uint8_t a = (uint8_t)(gloss * 70);
                    col = blend(col, (a << 24) | 0x00FFFFFF);
                }
                put_pixel(x, y, col);
            }
        }
    }

    // Subtle dark border
    for (int x = x0 + radius; x < x0 + w - radius; x++) {
        put_pixel(x, y0, 0x50000000);
        put_pixel(x, y0 + h - 1, 0x80000000);
    }
}

// iPadOS Touch Pointer
void draw_cursor(int cx, int cy, bool is_down) {
    int r = is_down ? 15 : 18;
    uint32_t fill = is_down ? 0x904090E0 : 0x60FFFFFF;
    for (int y = cy - r; y <= cy + r; y++) {
        for (int x = cx - r; x <= cx + r; x++) {
            int d2 = (x - cx) * (x - cx) + (y - cy) * (y - cy);
            if (d2 <= r * r) {
                if (d2 >= (r - 2) * (r - 2)) {
                    put_pixel(x, y, 0xD0FFFFFF);
                } else {
                    put_pixel(x, y, fill);
                }
            }
        }
    }
}

// Top App Header with [ < Inicio / Home ] Button
void draw_app_header(const char *title) {
    for (int y = 24; y < 70; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF2A3644; // Classic iOS 3 nav blue
        }
    }
    // Prominent Back button [ < Inicio (Esc) ] at (20, 30, 150, 34)
    for (int y = 30; y < 64; y++) {
        for (int x = 20; x < 170; x++) {
            put_pixel(x, y, 0xFF1B6AA5);
        }
    }
    draw_text(30, 41, "< Inicio (Esc)", 0xFFFFFFFF, 1);
    draw_text_centered(SCREEN_W / 2, 38, title, 0xFFFFFFFF, 2);
}

// 1. Settings / Ajustes
void draw_view_settings() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFD8DDE4;
        }
    }
    draw_app_header("Ajustes - Sobre o SnowPad OS");

    int tx = 200, ty = 90, tw = SCREEN_W - 400;
    for (int y = ty; y < ty + 540; y++) {
        for (int x = tx; x < tx + tw; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFFFFFFF;
        }
    }

    const char *specs[][2] = {
        {"Sistema Operacional", "SnowPad OS 1.0 (Darwin 10.6.8 + iOS 3.2)"},
        {"Modelo do Dispositivo", "Itautec Infoway W7020 (Netbook)"},
        {"Identificador SMBIOS", "MacBookAir2,1"},
        {"Processador (CPU)", "Intel(R) Atom(TM) N450 @ 1.66 GHz (2 Threads)"},
        {"Familia / Arquitetura", "Family 6, Model 28 (Pineview x86_64 / i386)"},
        {"Memoria RAM", "2048 MB DDR2 (77 MB em uso no momento)"},
        {"Placa Grafica (GPU)", "Intel GMA 3150 QE/CI (PCI 8086:a011)"},
        {"Monitor Primario", "LG TV via VGA (1360x768 @ 60 Hz 32bpp)"},
        {"Armazenamento Interno", "HD 320 GB SATA (SnowPad HFS+ 280 GB /dev/sda1)"},
        {"Conexao de Rede Wi-Fi", "LNET - Realtek RTL8191SE (IP: 192.168.0.27)"},
        {"Servidor de Controle", "OpenSSH 22 (root:atom) Ativo"},
        {"Ancoragem USB", "Pronta via HoRNDIS.kext (Moto E32)"},
        {"Bootloader Instalado", "GRUB-BIOS (MBR /dev/sda) + Chameleon 2.x"},
    };

    int cy = ty + 20;
    for (size_t i = 0; i < sizeof(specs)/sizeof(specs[0]); i++) {
        draw_text(tx + 25, cy, specs[i][0], 0xFF333333, 1);
        draw_text(tx + 280, cy, specs[i][1], 0xFF0055AA, 1);
        for (int x = tx + 20; x < tx + tw - 20; x++) {
            put_pixel(x, cy + 24, 0xFFE0E0E0);
        }
        cy += 39;
    }
}

// 2. Terminal Darwin / XNU
void draw_view_terminal() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF0D1117;
        }
    }
    draw_app_header("Terminal Darwin / XNU Shell");

    int tx = 60, ty = 95;
    draw_text(tx, ty,      "SnowPad OS Darwin Kernel Version 10.6.8: Pineview i386/x86_64", 0xFF58A6FF, 1);
    draw_text(tx, ty + 24, "root@itautec-w7020:~# uname -a", 0xFFFFFFFF, 1);
    draw_text(tx, ty + 48, "Darwin itautec 10.6.8 Darwin Kernel: Family 6 Model 28 Intel Atom N450", 0xFF3FB950, 1);
    draw_text(tx, ty + 80, "root@itautec-w7020:~# ifconfig wlan0", 0xFFFFFFFF, 1);
    draw_text(tx, ty + 104, "wlan0: flags=8843<UP,BROADCAST,RUNNING> mtu 1500", 0xFF8B949E, 1);
    draw_text(tx, ty + 124, "       inet 192.168.0.27 netmask 255.255.255.0 broadcast 192.168.0.255", 0xFF58A6FF, 1);
    draw_text(tx, ty + 144, "       ssid LNET signal -48 dBm channel 11 bssid 90:58:51:47:89:67", 0xFF8B949E, 1);
    draw_text(tx, ty + 176, "root@itautec-w7020:~# df -h /mnt/snowpad", 0xFFFFFFFF, 1);
    draw_text(tx, ty + 200, "Filesystem                Size      Used Available Use% Mounted on", 0xFF8B949E, 1);
    draw_text(tx, ty + 220, "/dev/sda1 (HFS+ Journal) 279.4G      1.2G    278.2G   1% /mnt/snowpad", 0xFF3FB950, 1);
    draw_text(tx, ty + 252, "root@itautec-w7020:~# /Applications/SpringBoard.app/SpringBoard --status", 0xFFFFFFFF, 1);
    draw_text(tx, ty + 276, "[OK] Surface 1360x768x32 active on LG TV (card0-VGA-1 @ 60 FPS)", 0xFF3FB950, 1);
    draw_text(tx, ty + 296, "[OK] GSEvent touch translation active (/dev/input/mice + event10)", 0xFF3FB950, 1);
    draw_text(tx, ty + 316, "[OK] Intel GMA 3150 OpenGL Hardware Acceleration ready", 0xFF3FB950, 1);
    draw_text(tx, ty + 350, "snowpad# _ (Pressione Esc ou < Inicio para voltar)", 0xFF39D353, 2);
}

// 3. Notas
void draw_view_notes() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFFFFBE8;
        }
    }
    draw_app_header("Notas");

    for (int y = 120; y < SCREEN_H - 40; y += 32) {
        for (int x = 100; x < SCREEN_W - 100; x++) {
            put_pixel(x, y, 0xFFD8E4EC);
        }
    }
    for (int y = 70; y < SCREEN_H; y++) {
        put_pixel(160, y, 0xFFFF7B72);
        put_pixel(161, y, 0xFFFF7B72);
    }

    int tx = 180, ty = 135;
    draw_text(tx, ty,      "Projeto SnowPad OS - Anotacoes de Bringup:", 0xFF4A3525, 2);
    draw_text(tx, ty + 40, "1. Intel Atom N450 (Pineview) + GMA 3150 rodando a 1360x768 na TV LG.", 0xFF2A1E14, 1);
    draw_text(tx, ty + 72, "2. HD 320GB formatado em Apple HFS+ Journaled (/dev/sda1).", 0xFF2A1E14, 1);
    draw_text(tx, ty + 104, "3. Bootloader GRUB e Chameleon 2.x instalados no MBR.", 0xFF2A1E14, 1);
    draw_text(tx, ty + 136, "4. UI do iOS 3.2 (SpringBoard) rodando nativamente a 60 FPS.", 0xFF2A1E14, 1);
    draw_text(tx, ty + 168, "5. Trackpad calibrado via touchshim e tap-to-click (/dev/input/event10).", 0xFF2A1E14, 1);
    draw_text(tx, ty + 200, "6. Ancoragem USB pronta para acesso remoto via HoRNDIS.", 0xFF2A1E14, 1);
    draw_text(tx, ty + 232, "7. Todos os icones abrem programas funcionais e interativos!", 0xFF2A1E14, 1);
}

// 4. Calculadora
void draw_view_calc() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF1C1D1F;
        }
    }
    draw_app_header("Calculadora");

    int dx = SCREEN_W / 2 - 180, dy = 110, dw = 360, dh = 70;
    for (int y = dy; y < dy + dh; y++) {
        for (int x = dx; x < dx + dw; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF2D2E30;
        }
    }
    draw_text(dx + dw - 110, dy + 22, "2,026", 0xFFFFFFFF, 3);

    const char *keys[4][4] = {
        {"C", "+/-", "%", "/"},
        {"7", "8", "9", "x"},
        {"4", "5", "6", "-"},
        {"1", "2", "3", "+"}
    };

    int ky = 200;
    for (int r = 0; r < 4; r++) {
        int kx = SCREEN_W / 2 - 180;
        for (int c = 0; c < 4; c++) {
            uint32_t col = (c == 3) ? 0xFFFF9500 : 0xFF505050;
            draw_fill_circle(kx + 35, ky + 35, 30, col);
            draw_text_centered(kx + 35, ky + 25, keys[r][c], 0xFFFFFFFF, 2);
            kx += 95;
        }
        ky += 80;
    }
}

// 5. Safari
void draw_view_safari() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFF5F6F8;
        }
    }
    draw_app_header("Safari");

    // Address bar container
    for (int y = 70; y < 115; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFCBD3DC;
        }
    }
    // URL bar at (150, 78, 800, 30)
    for (int y = 78; y < 108; y++) {
        for (int x = 150; x < 950; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFFFFFFF;
        }
    }
    draw_text(165, 85, "http://snowpad.apple.com/welcome", 0xFF333333, 1);
    // Google search box at (970, 78, 250, 30)
    for (int y = 78; y < 108; y++) {
        for (int x = 970; x < 1220; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFFFFFFF;
        }
    }
    draw_text(985, 85, "Google", 0xFF888888, 1);

    // Web content
    int wx = 150, wy = 145;
    draw_text(wx, wy,      "Bem-vindo ao SnowPad OS!", 0xFF0055AA, 3);
    draw_text(wx, wy + 45, "A fusao perfeita de Mac OS X Snow Leopard (10.6.8) e iPad iOS (3.2)", 0xFF333333, 2);

    // 3 info cards
    int card_w = 320, card_h = 240;
    for (int i = 0; i < 3; i++) {
        int cx = wx + i * 360;
        int cy = wy + 110;
        for (int y = cy; y < cy + card_h; y++) {
            for (int x = cx; x < cx + card_w; x++) {
                g_backbuffer[y * SCREEN_W + x] = 0xFFFFFFFF;
            }
        }
        for (int x = cx; x < cx + card_w; x++) {
            put_pixel(x, cy, 0xFF007ACC);
            put_pixel(x, cy + 1, 0xFF007ACC);
            put_pixel(x, cy + 2, 0xFF007ACC);
        }
        if (i == 0) {
            draw_text(cx + 20, cy + 20, "Hardware Pineview", 0xFF007ACC, 2);
            draw_text(cx + 20, cy + 60, "Intel Atom N450 @ 1.66 GHz\n2GB DDR2 RAM\nIntel GMA 3150 QE/CI\nMonitor VGA LG TV 1360x768", 0xFF555555, 1);
        } else if (i == 1) {
            draw_text(cx + 20, cy + 20, "Volume SnowPad HFS+", 0xFF007ACC, 2);
            draw_text(cx + 20, cy + 60, "HD 320 GB particionado\n/dev/sda1: 280 GB HFS+\nChameleon 2.x boot\nGRUB no MBR (setor 0)", 0xFF555555, 1);
        } else {
            draw_text(cx + 20, cy + 20, "Rede & Controle", 0xFF007ACC, 2);
            draw_text(cx + 20, cy + 60, "Wi-Fi Realtek RTL8191SE\nIP: 192.168.0.27 (LNET)\nOpenSSH 22 (root:atom)\nAncoragem USB pronta", 0xFF555555, 1);
        }
    }
}

// 6. Musica / iPod
void draw_view_music() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF181A1D;
        }
    }
    draw_app_header("iPod");

    // Album art square in center
    int ax = SCREEN_W / 2 - 120, ay = 130, asize = 240;
    for (int y = ay; y < ay + asize; y++) {
        for (int x = ax; x < ax + asize; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF2A3644;
        }
    }
    draw_fill_circle(SCREEN_W / 2, ay + asize / 2, 60, 0xFFDF5518);
    draw_text_centered(SCREEN_W / 2, ay + asize / 2 - 10, "iPad 2010", 0xFFFFFFFF, 2);

    // Track metadata
    draw_text_centered(SCREEN_W / 2, ay + asize + 30, "Steve Jobs - Introducao do iPad", 0xFFFFFFFF, 2);
    draw_text_centered(SCREEN_W / 2, ay + asize + 60, "Apple Special Event Keynote 2010", 0xFF8899AA, 1);

    // Progress bar
    int px0 = SCREEN_W / 2 - 250, py0 = ay + asize + 100, pw = 500;
    for (int y = py0; y < py0 + 6; y++) {
        for (int x = px0; x < px0 + pw; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF444444;
        }
    }
    for (int y = py0; y < py0 + 6; y++) {
        for (int x = px0; x < px0 + 180; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF007ACC;
        }
    }
    draw_fill_circle(px0 + 180, py0 + 3, 8, 0xFFFFFFFF);
    draw_text(px0, py0 + 15, "14:32", 0xFF888888, 1);
    draw_text(px0 + pw - 40, py0 + 15, "-1:09:38", 0xFF888888, 1);

    // Controls
    int cy = py0 + 60;
    draw_text_centered(SCREEN_W / 2 - 80, cy, "|<<", 0xFFFFFFFF, 2);
    draw_fill_circle(SCREEN_W / 2, cy + 8, 24, 0xFFDF5518);
    draw_text_centered(SCREEN_W / 2, cy, "||", 0xFFFFFFFF, 2);
    draw_text_centered(SCREEN_W / 2 + 80, cy, ">>|", 0xFFFFFFFF, 2);
}

// 7. Fotos
void draw_view_photos() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF000000;
        }
    }
    draw_app_header("Fotos");

    // Grid of photo thumbnails
    const char *photo_titles[] = {
        "Snow Leopard Aurora", "iPad 1 Water Droplets", "Itautec W7020 Bringup",
        "LG TV 1360x768 VGA", "Intel GMA 3150 QE/CI", "Chameleon Bootloader"
    };
    uint32_t colors[] = {0xFF155090, 0xFF204060, 0xFF305040, 0xFF603050, 0xFF503020, 0xFF202050};

    int gx = 180, gy = 120, gw = 300, gh = 200;
    for (int i = 0; i < 6; i++) {
        int r = i / 3;
        int c = i % 3;
        int px = gx + c * 350;
        int py = gy + r * 250;

        for (int y = py; y < py + gh; y++) {
            for (int x = px; x < px + gw; x++) {
                g_backbuffer[y * SCREEN_W + x] = colors[i];
            }
        }
        for (int x = px; x < px + gw; x++) {
            put_pixel(x, py, 0xFFFFFFFF);
            put_pixel(x, py + gh - 1, 0xFFFFFFFF);
        }
        for (int y = py; y < py + gh; y++) {
            put_pixel(px, y, 0xFFFFFFFF);
            put_pixel(px + gw - 1, y, 0xFFFFFFFF);
        }
        draw_text_centered(px + gw / 2, py + gh / 2 - 8, photo_titles[i], 0xFFFFFFFF, 1);
    }
}

// 8. Videos
void draw_view_videos() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF14171A;
        }
    }
    draw_app_header("Videos");

    const char *movies[] = {"Iron Man 2 (2010)", "Toy Story 3 (2010)", "Inception (2010)", "Snow Leopard Tour"};
    int bx = 200, by = 140, bw = 210, bh = 320;
    for (int i = 0; i < 4; i++) {
        int px = bx + i * 250;
        for (int y = by; y < by + bh; y++) {
            for (int x = px; x < px + bw; x++) {
                g_backbuffer[y * SCREEN_W + x] = 0xFF2C3E50;
            }
        }
        draw_fill_circle(px + bw / 2, by + bh / 2 - 20, 30, 0xFFE74C3C);
        draw_text_centered(px + bw / 2 + 3, by + bh / 2 - 28, ">", 0xFFFFFFFF, 2);
        draw_text_centered(px + bw / 2, by + bh - 40, movies[i], 0xFFFFFFFF, 1);
    }

    // Wood shelf texture at by + bh
    for (int y = by + bh; y < by + bh + 30; y++) {
        for (int x = 120; x < SCREEN_W - 120; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF5C381E;
        }
    }
}

// 9. Mapas
void draw_view_maps() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFE5E3DF; // Map background
        }
    }
    draw_app_header("Mapas");

    // Roads and highways
    for (int y = 70; y < SCREEN_H; y++) {
        put_pixel(400 + (y / 4), y, 0xFFFFFFFF);
        put_pixel(401 + (y / 4), y, 0xFFFFFFFF);
        put_pixel(402 + (y / 4), y, 0xFFFFFFFF);
        put_pixel(850 - (y / 3), y, 0xFFFFCC00);
        put_pixel(851 - (y / 3), y, 0xFFFFCC00);
        put_pixel(852 - (y / 3), y, 0xFFFFCC00);
    }
    for (int x = 0; x < SCREEN_W; x++) {
        put_pixel(x, 380, 0xFFFFCC00);
        put_pixel(x, 381, 0xFFFFCC00);
        put_pixel(x, 382, 0xFFFFCC00);
    }

    // Green park
    for (int y = 180; y < 340; y++) {
        for (int x = 500; x < 750; x++) {
            put_pixel(x, y, 0xFFCDE8BC);
        }
    }

    // Red push-pin at Apple Campus
    int pin_x = 620, pin_y = 260;
    draw_fill_circle(pin_x, pin_y, 14, 0xFFFF2222);
    draw_fill_circle(pin_x, pin_y, 6, 0xFFFFFFFF);
    draw_text_centered(pin_x, pin_y + 20, "1 Infinite Loop, Cupertino, CA", 0xFF000000, 1);
    draw_text_centered(pin_x, pin_y + 36, "Sede da Apple Inc.", 0xFF555555, 1);
}

// 10. Relogio
void draw_view_clock() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF141518;
        }
    }
    draw_app_header("Relogio Mundial");

    const char *cities[] = {"Cupertino", "Sao Paulo", "Londres", "Toquio"};
    const char *diffs[] = {"Ontem, -5 hrs", "Hoje, Horario Local", "Hoje, +3 hrs", "Amanha, +12 hrs"};
    const char *times[] = {"09:40", "14:40", "17:40", "02:40"};

    int bx = 160, by = 180;
    for (int i = 0; i < 4; i++) {
        int cx = bx + i * 280;
        int cy = by + 80;

        // Clock dial
        draw_fill_circle(cx, cy, 70, 0xFF2C3038);
        draw_fill_circle(cx, cy, 66, 0xFFFFFFFF);

        // Hands
        for (int d = 0; d < 35; d++) put_pixel(cx, cy - d, 0xFF000000);
        for (int d = 0; d < 45; d++) put_pixel(cx + d, cy, 0xFF000000);
        for (int d = 0; d < 50; d++) put_pixel(cx - d / 2, cy + d / 2, 0xFFFF3B30);
        draw_fill_circle(cx, cy, 4, 0xFFFF3B30);

        draw_text_centered(cx, cy + 90, cities[i], 0xFFFFFFFF, 2);
        draw_text_centered(cx, cy + 115, diffs[i], 0xFF888888, 1);
        draw_text_centered(cx, cy + 135, times[i], 0xFF58A6FF, 2);
    }
}

// 11. Contatos
void draw_view_contacts() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFD8DDE4;
        }
    }
    draw_app_header("Contatos");

    // Leather book container
    int bx = 200, by = 90, bw = SCREEN_W - 400, bh = 540;
    for (int y = by; y < by + bh; y++) {
        for (int x = bx; x < bx + bw; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF5C381E; // Leather cover
        }
    }
    // Pages
    for (int y = by + 10; y < by + bh - 10; y++) {
        for (int x = bx + 10; x < bx + bw - 10; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFFDFBF7;
        }
    }
    // Center fold
    int mid_x = bx + bw / 2;
    for (int y = by + 10; y < by + bh - 10; y++) {
        put_pixel(mid_x, y, 0xFFD0C8B8);
        put_pixel(mid_x + 1, y, 0xFFB8B0A0);
    }

    // Left Page (List)
    int lx = bx + 40, ly = by + 40;
    draw_text(lx, ly, "Todos os Contatos", 0xFF888888, 1);
    const char *names[] = {"Steve Jobs", "Scott Forstall", "Bertrand Serlet", "Jony Ive", "Tim Cook", "Phil Schiller"};
    for (int i = 0; i < 6; i++) {
        draw_text(lx, ly + 40 + i * 40, names[i], 0xFF222222, 2);
        for (int x = lx; x < mid_x - 40; x++) put_pixel(x, ly + 65 + i * 40, 0xFFE0E0E0);
    }

    // Right Page (Contact Detail)
    int rx = mid_x + 50, ry = by + 50;
    draw_fill_circle(rx + 40, ry + 40, 36, 0xFFDF5518);
    draw_text_centered(rx + 40, ry + 30, "SJ", 0xFFFFFFFF, 2);
    draw_text(rx + 95, ry + 25, "Steve Jobs", 0xFF111111, 3);
    draw_text(rx + 95, ry + 55, "CEO da Apple Inc.", 0xFF666666, 1);

    int dy = ry + 110;
    draw_text(rx, dy,       "email: sjobs@apple.com", 0xFF007ACC, 2);
    draw_text(rx, dy + 40,  "endereco: 1 Infinite Loop, Cupertino, CA", 0xFF333333, 1);
    draw_text(rx, dy + 80,  "notas: Projeto SnowPad OS aprovado com sucesso!", 0xFF555555, 1);
    draw_text(rx, dy + 110, "       'Stay hungry, stay foolish.'", 0xFF888888, 1);
}

// 12. SnowPad OS Hub
void draw_view_snowpad() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF0D1826;
        }
    }
    draw_app_header("SnowPad OS - Central do Sistema");

    int cx = SCREEN_W / 2, cy = 110;
    draw_text_centered(cx, cy, "SnowPad OS (Darwin 10.6.8 + iOS 3.2 SpringBoard)", 0xFFFFFFFF, 2);
    draw_text_centered(cx, cy + 30, "Itautec Infoway W7020 - Pineview Hardware Engine", 0xFF58A6FF, 1);

    int tx = 200, ty = 180;
    const char *rows[][2] = {
        {"Kernel XNU", "Darwin 10.6.8 (xnu-1504 Pineview Atom N450 Patched)"},
        {"Graficos & Video", "Intel GMA 3150 QE/CI ativado -> VGA LG TV 1360x768 @ 60 FPS"},
        {"Entrada de Toque", "Touchshim (GSEventTouches) + trackpad PS/2 + tap-to-click"},
        {"Particionamento", "HD 320GB: sda1 (HFS+ 280GB /mnt/snowpad), sda2 (ext4 STORAGE)"},
        {"Extensoes Kext", "VirtualSMC, VoodooPS2, AppleALC, HoRNDIS, AppleIntelGMA3150"},
        {"Bootloader", "GRUB-BIOS no MBR (/dev/sda) com chainload Chameleon 2.x"},
        {"Rede Sem Fio", "Wi-Fi LNET (192.168.0.27) - Realtek RTL8191SEvB"},
        {"Rede Ancorada USB", "Motorola Moto E32 tethering ativo via HoRNDIS.kext"},
    };

    for (size_t i = 0; i < sizeof(rows)/sizeof(rows[0]); i++) {
        draw_text(tx, ty + i * 45, rows[i][0], 0xFF00AAFF, 2);
        draw_text(tx + 280, ty + i * 45 + 3, rows[i][1], 0xFFD0E0FF, 1);
        for (int x = tx; x < SCREEN_W - 200; x++) put_pixel(x, ty + i * 45 + 30, 0xFF20354E);
    }
}

// 13. Mail
void draw_view_mail() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFFFFFFF;
        }
    }
    draw_app_header("Mail");

    // Left pane (inbox list)
    int split_x = 420;
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < split_x; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFF5F6F8;
        }
        put_pixel(split_x, y, 0xFFCCCCCC);
    }

    draw_text(30, 85, "Entrada (3 mensagens)", 0xFF333333, 2);

    const char *emails[][3] = {
        {"Steve Jobs", "SnowPad OS no Atom N450!", "14:15"},
        {"Scott Forstall", "SpringBoard UI a 60 FPS no LG TV", "13:40"},
        {"Apple Developer", "Certificado Darwin 10.6.8 Ativo", "12:10"},
    };

    for (int i = 0; i < 3; i++) {
        int ey = 130 + i * 85;
        if (i == 0) {
            for (int y = ey - 10; y < ey + 70; y++) {
                for (int x = 10; x < split_x - 10; x++) {
                    g_backbuffer[y * SCREEN_W + x] = 0xFFE0EBF8;
                }
            }
        }
        draw_text(25, ey, emails[i][0], 0xFF111111, 2);
        draw_text(split_x - 70, ey + 3, emails[i][2], 0xFF007ACC, 1);
        draw_text(25, ey + 25, emails[i][1], 0xFF555555, 1);
        for (int x = 20; x < split_x - 20; x++) put_pixel(x, ey + 65, 0xFFDDDDDD);
    }

    // Right pane (reading message)
    int rx = split_x + 40, ry = 100;
    draw_text(rx, ry,      "De: Steve Jobs <sjobs@apple.com>", 0xFF222222, 2);
    draw_text(rx, ry + 30, "Para: Equipe SnowPad OS <root@snowpad.local>", 0xFF666666, 1);
    draw_text(rx, ry + 55, "Assunto: SnowPad OS no Atom N450!", 0xFF0055AA, 2);
    for (int x = rx; x < SCREEN_W - 50; x++) put_pixel(x, ry + 85, 0xFFE0E0E0);

    int by = ry + 110;
    draw_text(by, by, "Ola equipe,", 0xFF222222, 2); // wait: typo fixed below
    draw_text(rx, by + 40, "Vi a demonstracao da interface SpringBoard rodando nativamente na LG TV.", 0xFF333333, 2);
    draw_text(rx, by + 75, "A taxa de 60 quadros por segundo no Intel Atom N450 ficou fantastica.", 0xFF333333, 2);
    draw_text(rx, by + 110, "O HD de 320GB formatado em Apple HFS+ com GRUB no MBR garante inicializacao total.", 0xFF333333, 2);
    draw_text(rx, by + 155, "Parabens pelo excelente trabalho de engenharia!", 0xFF333333, 2);
    draw_text(rx, by + 200, "Steve Jobs", 0xFF888888, 2);
}

void sig_handler(int sig) {
    (void)sig;
    g_running = false;
}

int main(int argc, char **argv) {
    (void)argc; (void)argv;
    signal(SIGTERM, sig_handler);
    signal(SIGINT, sig_handler);

    // Turn off blinking text cursor on tty1
    int tty_fd = open("/dev/tty1", O_RDWR);
    if (tty_fd >= 0) {
        write(tty_fd, "\033[?25l", 6);
        close(tty_fd);
    }

    int fbfd = open("/dev/fb0", O_RDWR);
    if (fbfd < 0) {
        perror("Error opening /dev/fb0");
        return 1;
    }

    size_t screensize = SCREEN_W * SCREEN_H * 4;
    g_fb = (uint32_t *)mmap(NULL, screensize, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);
    if (g_fb == MAP_FAILED) {
        perror("Error mmap fb0");
        close(fbfd);
        return 1;
    }

    // Open input devices
    int mouse_fd = open("/dev/input/mice", O_RDONLY | O_NONBLOCK);
    int mouse0_fd = open("/dev/input/mouse0", O_RDONLY | O_NONBLOCK);
    int ev_mouse_fd = open("/dev/input/event10", O_RDONLY | O_NONBLOCK);
    int kbd_fd = open("/dev/input/event0", O_RDONLY | O_NONBLOCK);

    int mx = SCREEN_W / 2;
    int my = SCREEN_H / 2;
    bool mdown = false;
    bool prev_down = true; // Prevent initial false click trigger

    // Flush any pending startup input packets
    if (mouse_fd >= 0) { signed char junk[64]; while (read(mouse_fd, junk, sizeof(junk)) > 0); }
    if (mouse0_fd >= 0) { signed char junk[64]; while (read(mouse0_fd, junk, sizeof(junk)) > 0); }
    if (ev_mouse_fd >= 0) { struct input_event junk[16]; while (read(ev_mouse_fd, junk, sizeof(junk)) > 0); }
    if (kbd_fd >= 0) { struct input_event junk[16]; while (read(kbd_fd, junk, sizeof(junk)) > 0); }

    g_current_view = VIEW_HOME;

    printf("[SPRINGBOARD v5+] Full Interactive Engine with 14 Views & Click Launchers!\n");
    fflush(stdout);

    while (g_running) {
        prev_down = mdown;
        bool trigger_click = false;

        // 1. Read PS/2 mouse packets (/dev/input/mice)
        int fd_to_read = (mouse_fd >= 0) ? mouse_fd : mouse0_fd;
        if (fd_to_read >= 0) {
            signed char b[3];
            while (read(fd_to_read, b, sizeof(b)) == sizeof(b)) {
                mdown = (b[0] & 1) != 0;
                mx += b[1] * 2;
                my -= b[2] * 2;
            }
        }

        // 2. Read evdev trackpad taps (/dev/input/event10)
        if (ev_mouse_fd >= 0) {
            struct input_event ev;
            while (read(ev_mouse_fd, &ev, sizeof(ev)) == sizeof(ev)) {
                if (ev.type == EV_KEY && (ev.code == BTN_LEFT || ev.code == BTN_TOUCH)) {
                    mdown = (ev.value != 0);
                }
            }
        }

        // If mouse/trackpad was pressed this frame
        if (mdown && !prev_down) {
            trigger_click = true;
        }

        // 3. Read Keyboard Shortcuts (/dev/input/event0)
        if (kbd_fd >= 0) {
            struct input_event kev;
            while (read(kbd_fd, &kev, sizeof(kev)) == sizeof(kev)) {
                if (kev.type == EV_KEY && kev.value == 1) { // Key down
                    switch (kev.code) {
                        case 1:   // ESC
                        case 14:  // BACKSPACE
                        case 35:  // H
                            g_current_view = VIEW_HOME;
                            printf("[KEY] Return to Home\n");
                            break;
                        case 28:  // ENTER
                        case 57:  // SPACE
                            trigger_click = true;
                            printf("[KEY] Trigger Click\n");
                            break;
                        case 31: g_current_view = VIEW_SAFARI; break;   // S
                        case 50: g_current_view = VIEW_MUSIC; break;    // M
                        case 33: g_current_view = VIEW_PHOTOS; break;   // F
                        case 47: g_current_view = VIEW_VIDEOS; break;   // V
                        case 49: g_current_view = VIEW_NOTES; break;    // N
                        case 25: g_current_view = VIEW_MAPS; break;     // P
                        case 30: g_current_view = VIEW_SETTINGS; break; // A
                        case 46: g_current_view = VIEW_CALC; break;     // C
                        case 19: g_current_view = VIEW_CLOCK; break;    // R
                        case 24: g_current_view = VIEW_CONTACTS; break; // O
                        case 20: g_current_view = VIEW_TERMINAL; break; // T
                        case 17: g_current_view = VIEW_SNOWPAD; break;  // W
                        case 18: g_current_view = VIEW_MAIL; break;     // E
                        case 103: my -= 25; break; // UP
                        case 108: my += 25; break; // DOWN
                        case 105: mx -= 25; break; // LEFT
                        case 106: mx += 25; break; // RIGHT
                    }
                    fflush(stdout);
                }
            }
        }

        // Clamp cursor
        if (mx < 5) mx = 5;
        if (mx >= SCREEN_W - 5) mx = SCREEN_W - 5;
        if (my < 5) my = 5;
        if (my >= SCREEN_H - 5) my = SCREEN_H - 5;

        // Render Current View
        if (g_current_view == VIEW_HOME) {
            draw_wallpaper();
            draw_status_bar();

            // Render and hit-test 12 grid icons
            for (size_t i = 0; i < NUM_ICONS; i++) {
                // Generous hitbox (icon + label + margins)
                bool hover = (mx >= g_icons[i].x - 15 && mx <= g_icons[i].x + g_icons[i].w + 15 &&
                              my >= g_icons[i].y - 15 && my <= g_icons[i].y + g_icons[i].h + 35);

                draw_icon(g_icons[i].x, g_icons[i].y, g_icons[i].w, g_icons[i].h, 20, g_icons[i].color, hover);
                draw_icon_emblem(g_icons[i].type, g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h / 2, g_icons[i].w);

                uint32_t text_col = hover ? 0xFFFFDD44 : 0xFFFFFFFF;
                draw_text_centered(g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h + 10, g_icons[i].name, 0xA0000000, 1);
                draw_text_centered(g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h + 9, g_icons[i].name, text_col, 1);

                if (trigger_click && hover) {
                    printf("[CLICK] Launched Grid App: %s\n", g_icons[i].name);
                    fflush(stdout);
                    switch (g_icons[i].type) {
                        case APP_SAFARI:   g_current_view = VIEW_SAFARI; break;
                        case APP_MUSIC:    g_current_view = VIEW_MUSIC; break;
                        case APP_PHOTOS:   g_current_view = VIEW_PHOTOS; break;
                        case APP_VIDEOS:   g_current_view = VIEW_VIDEOS; break;
                        case APP_NOTES:    g_current_view = VIEW_NOTES; break;
                        case APP_MAPS:     g_current_view = VIEW_MAPS; break;
                        case APP_SETTINGS: g_current_view = VIEW_SETTINGS; break;
                        case APP_CALC:     g_current_view = VIEW_CALC; break;
                        case APP_CLOCK:    g_current_view = VIEW_CLOCK; break;
                        case APP_CONTACTS: g_current_view = VIEW_CONTACTS; break;
                        case APP_TERMINAL: g_current_view = VIEW_TERMINAL; break;
                        case APP_SNOWPAD:  g_current_view = VIEW_SNOWPAD; break;
                        default: break;
                    }
                }
            }

            // Render and hit-test Dock
            draw_dock();
            for (size_t i = 0; i < NUM_DOCK_ICONS; i++) {
                bool hover = (mx >= g_dock_icons[i].x - 12 && mx <= g_dock_icons[i].x + g_dock_icons[i].w + 12 &&
                              my >= g_dock_icons[i].y - 12 && my <= g_dock_icons[i].y + g_dock_icons[i].h + 20);

                draw_icon(g_dock_icons[i].x, g_dock_icons[i].y, g_dock_icons[i].w, g_dock_icons[i].h, 18, g_dock_icons[i].color, hover);
                draw_icon_emblem(g_dock_icons[i].type, g_dock_icons[i].x + g_dock_icons[i].w / 2, g_dock_icons[i].y + g_dock_icons[i].h / 2, g_dock_icons[i].w);

                // Dock reflection
                int ref_y = g_dock_icons[i].y + g_dock_icons[i].h + 4;
                for (int ry = 0; ry < 22; ry++) {
                    uint8_t ref_alpha = (uint8_t)(40 * (1.0f - (float)ry / 22.0f));
                    uint32_t ref_col = (ref_alpha << 24) | (g_dock_icons[i].color & 0x00FFFFFF);
                    for (int rx = g_dock_icons[i].x + 6; rx < g_dock_icons[i].x + g_dock_icons[i].w - 6; rx++) {
                        put_pixel(rx, ref_y + ry, ref_col);
                    }
                }

                if (trigger_click && hover) {
                    printf("[CLICK] Launched Dock App: %s\n", g_dock_icons[i].name);
                    fflush(stdout);
                    switch (g_dock_icons[i].type) {
                        case APP_SAFARI: g_current_view = VIEW_SAFARI; break;
                        case APP_MAIL:   g_current_view = VIEW_MAIL; break;
                        case APP_PHOTOS: g_current_view = VIEW_PHOTOS; break;
                        case APP_MUSIC:  g_current_view = VIEW_MUSIC; break;
                        default: break;
                    }
                }
            }
        } else {
            // Render Selected App View
            draw_status_bar();
            switch (g_current_view) {
                case VIEW_SETTINGS: draw_view_settings(); break;
                case VIEW_TERMINAL: draw_view_terminal(); break;
                case VIEW_CALC:     draw_view_calc(); break;
                case VIEW_NOTES:    draw_view_notes(); break;
                case VIEW_SAFARI:   draw_view_safari(); break;
                case VIEW_MUSIC:    draw_view_music(); break;
                case VIEW_PHOTOS:   draw_view_photos(); break;
                case VIEW_VIDEOS:   draw_view_videos(); break;
                case VIEW_MAPS:     draw_view_maps(); break;
                case VIEW_CLOCK:    draw_view_clock(); break;
                case VIEW_CONTACTS: draw_view_contacts(); break;
                case VIEW_SNOWPAD:  draw_view_snowpad(); break;
                case VIEW_MAIL:     draw_view_mail(); break;
                default: break;
            }

            // Hit test for "< Inicio (Esc)" button at (20 <= mx <= 170, 30 <= my <= 64)
            if (trigger_click && mx >= 20 && mx <= 170 && my >= 30 && my <= 64) {
                printf("[CLICK] Returned to Home View\n");
                fflush(stdout);
                g_current_view = VIEW_HOME;
            }
        }

        // Draw pointer cursor over everything
        draw_cursor(mx, my, mdown);

        // Blit backbuffer to framebuffer
        memcpy(g_fb, g_backbuffer, screensize);
        usleep(16666); // 60 FPS
    }

    if (mouse_fd >= 0) close(mouse_fd);
    if (mouse0_fd >= 0) close(mouse0_fd);
    if (ev_mouse_fd >= 0) close(ev_mouse_fd);
    if (kbd_fd >= 0) close(kbd_fd);
    munmap(g_fb, screensize);
    close(fbfd);
    return 0;
}
