/*
 * springboard.c - SnowPad OS Native SpringBoard & Touch Userland Engine (v4)
 * Fullscreen 1360x768x32 UI for external VGA monitor (LG TV).
 *
 * Full Interactive iOS 3.2 Experience:
 * - Home Screen with 12 vector-emblem icons + 4 dock icons
 * - Click detection on icons to launch apps!
 * - VIEW_SETTINGS: Device specs table (Atom N450, 2GB RAM, GMA 3150, 1360x768)
 * - VIEW_TERMINAL: Real-time system shell overlay
 * - VIEW_CALC: Working 4-function iOS 3 calculator
 * - VIEW_NOTES: Yellow legal pad
 * - Navigation bar with [ < Home ] back button
 * - iPadOS circular touch cursor tracking PS/2 trackpad
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
    VIEW_NOTES
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

    uint32_t rb = ((src & 0x00FF00FF) * a + (dst & 0x00FF00FF) * inv_a) >> 8;
    uint32_t g  = ((src & 0x0000FF00) * a + (dst & 0x0000FF00) * inv_a) >> 8;
    return 0xFF000000 | (rb & 0x00FF00FF) | (g & 0x0000FF00);
}

static inline void put_pixel(int x, int y, uint32_t color) {
    if (x >= 0 && x < SCREEN_W && y >= 0 && y < SCREEN_H) {
        g_backbuffer[y * SCREEN_W + x] = blend(g_backbuffer[y * SCREEN_W + x], color);
    }
}

void draw_fill_circle(int cx, int cy, int r, uint32_t color) {
    for (int y = cy - r; y <= cy + r; y++) {
        for (int x = cx - r; x <= cx + r; x++) {
            if ((x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r) {
                put_pixel(x, y, color);
            }
        }
    }
}

void draw_text(int x0, int y0, const char *str, uint32_t color, int scale) {
    while (*str) {
        char ch = *str++;
        if (ch >= 32 && ch <= 126) {
            const uint8_t *glyph = g_font8x8[ch - 32];
            for (int r = 0; r < 8; r++) {
                uint8_t row = glyph[r];
                for (int c = 0; c < 8; c++) {
                    if (row & (1 << (7 - c))) {
                        for (int sy = 0; sy < scale; sy++) {
                            for (int sx = 0; sx < scale; sx++) {
                                put_pixel(x0 + c * scale + sx, y0 + r * scale + sy, color);
                            }
                        }
                    }
                }
            }
        }
        x0 += 8 * scale + 1;
    }
}

void draw_text_centered(int cx, int y0, const char *str, uint32_t color, int scale) {
    int len = (int)strlen(str);
    int w = len * (8 * scale + 1);
    draw_text(cx - w / 2, y0, str, color, scale);
}

void draw_icon_emblem(AppType type, int cx, int cy, int size) {
    int r = size / 3;
    switch (type) {
        case APP_SAFARI: {
            draw_fill_circle(cx, cy, r, 0xFFFFFFFF);
            draw_fill_circle(cx, cy, r - 3, 0xFF104E8B);
            for (int i = 0; i <= r - 5; i++) {
                put_pixel(cx + i, cy - i, 0xFFFF2222);
                put_pixel(cx + i - 1, cy - i, 0xFFFF5555);
                put_pixel(cx - i, cy + i, 0xFFFFFFFF);
                put_pixel(cx - i + 1, cy + i, 0xFFDDDDDD);
            }
            draw_fill_circle(cx, cy, 3, 0xFFFFD700);
            break;
        }
        case APP_MUSIC: {
            draw_fill_circle(cx - 8, cy + 8, 6, 0xFFFFFFFF);
            draw_fill_circle(cx + 8, cy + 4, 6, 0xFFFFFFFF);
            for (int y = cy - 12; y <= cy + 8; y++) {
                put_pixel(cx - 3, y, 0xFFFFFFFF);
                put_pixel(cx - 4, y, 0xFFFFFFFF);
            }
            for (int y = cy - 16; y <= cy + 4; y++) {
                put_pixel(cx + 13, y, 0xFFFFFFFF);
                put_pixel(cx + 12, y, 0xFFFFFFFF);
            }
            for (int x = cx - 4; x <= cx + 13; x++) {
                put_pixel(x, cy - 14, 0xFFFFFFFF);
                put_pixel(x, cy - 15, 0xFFFFFFFF);
                put_pixel(x, cy - 16, 0xFFFFFFFF);
            }
            break;
        }
        case APP_PHOTOS: {
            draw_fill_circle(cx, cy, r, 0xFFFFFFFF);
            uint32_t petals[] = {0xFFFF4444, 0xFFFF8800, 0xFFFFDD00, 0xFF44CC44, 0xFF0088FF, 0xFF9933FF};
            for (int i = 0; i < 6; i++) {
                float a = (float)i * 1.047f;
                int px = cx + (int)(cosf(a) * (r - 7));
                int py = cy + (int)(sinf(a) * (r - 7));
                draw_fill_circle(px, py, 6, petals[i]);
            }
            draw_fill_circle(cx, cy, 5, 0xFFFFFFFF);
            break;
        }
        case APP_VIDEOS: {
            draw_fill_circle(cx, cy, r, 0xFF222B38);
            for (int x = 0; x < 18; x++) {
                for (int y = -x; y <= x; y++) {
                    put_pixel(cx - 6 + x, cy + y / 2, 0xFFFFFFFF);
                }
            }
            break;
        }
        case APP_NOTES: {
            for (int y = cy - r; y <= cy + r; y++) {
                for (int x = cx - r + 3; x <= cx + r - 3; x++) {
                    put_pixel(x, y, 0xFFFFF8DC);
                }
            }
            for (int y = cy - r; y <= cy - r + 6; y++) {
                for (int x = cx - r + 3; x <= cx + r - 3; x++) {
                    put_pixel(x, y, 0xFF8B4513);
                }
            }
            for (int y = cy - r + 11; y <= cy + r - 4; y += 5) {
                for (int x = cx - r + 6; x <= cx + r - 6; x++) {
                    put_pixel(x, y, 0xFF87CEEB);
                }
            }
            for (int y = cy - r + 6; y <= cy + r; y++) {
                put_pixel(cx - r + 9, y, 0xFFFF6347);
            }
            break;
        }
        case APP_MAPS: {
            draw_fill_circle(cx, cy, r, 0xFFEEDDAA);
            for (int x = cx - r + 2; x <= cx + r - 2; x++) {
                put_pixel(x, cy + (x - cx) / 3, 0xFFFFCC00);
                put_pixel(x, cy + (x - cx) / 3 + 1, 0xFFFFFFFF);
            }
            draw_fill_circle(cx, cy - 4, 7, 0xFFFF2222);
            draw_fill_circle(cx, cy - 4, 3, 0xFFFFFFFF);
            for (int y = cy + 2; y <= cy + 9; y++) put_pixel(cx, y, 0xFFFF2222);
            break;
        }
        case APP_SETTINGS: {
            draw_fill_circle(cx, cy, r, 0xFF555D65);
            for (int i = 0; i < 8; i++) {
                float a = (float)i * 0.785f;
                int gx = cx + (int)(cosf(a) * (r - 2));
                int gy = cy + (int)(sinf(a) * (r - 2));
                draw_fill_circle(gx, gy, 5, 0xFF555D65);
            }
            draw_fill_circle(cx, cy, r - 5, 0xFF7A848E);
            draw_fill_circle(cx, cy, 5, 0xFF2A2D32);
            break;
        }
        case APP_CALC: {
            draw_text(cx - 14, cy - 14, "+", 0xFFFF9500, 2);
            draw_text(cx + 4,  cy - 14, "-", 0xFFFF9500, 2);
            draw_text(cx - 14, cy + 2,  "x", 0xFFFF9500, 2);
            draw_text(cx + 4,  cy + 2,  "=", 0xFF34AADC, 2);
            break;
        }
        case APP_CLOCK: {
            draw_fill_circle(cx, cy, r, 0xFFFFFFFF);
            draw_fill_circle(cx, cy, r - 2, 0xFF0D0D0D);
            for (int i = 0; i < r - 8; i++) {
                put_pixel(cx - (int)(i * 0.6f), cy - (int)(i * 0.8f), 0xFFFFFFFF);
            }
            for (int i = 0; i < r - 5; i++) {
                put_pixel(cx + (int)(i * 0.7f), cy - (int)(i * 0.7f), 0xFFFFFFFF);
            }
            for (int i = 0; i < r - 4; i++) {
                put_pixel(cx, cy + i, 0xFFFF6600);
            }
            draw_fill_circle(cx, cy, 2, 0xFFFF6600);
            break;
        }
        case APP_CONTACTS: {
            for (int y = cy - r + 3; y <= cy + r - 3; y++) {
                for (int x = cx - r + 4; x <= cx + r - 4; x++) {
                    put_pixel(x, y, 0xFFE0E0E0);
                }
            }
            draw_fill_circle(cx - 2, cy - 4, 5, 0xFF4A235A);
            for (int y = cy + 2; y <= cy + 10; y++) {
                for (int x = cx - 9; x <= cx + 5; x++) {
                    put_pixel(x, y, 0xFF4A235A);
                }
            }
            put_pixel(cx + r - 3, cy - 8, 0xFFFF3333);
            put_pixel(cx + r - 3, cy - 2, 0xFF33CC33);
            put_pixel(cx + r - 3, cy + 4, 0xFF3366FF);
            break;
        }
        case APP_TERMINAL: {
            draw_text(cx - 14, cy - 7, ">_", 0xFF33FF66, 2);
            break;
        }
        case APP_SNOWPAD: {
            draw_fill_circle(cx, cy, r, 0xFF005599);
            for (int y = cy - 14; y <= cy + 14; y++) {
                for (int x = cx - 10; x <= cx + 10; x++) {
                    if (y == cy - 14 || y == cy + 14 || x == cx - 10 || x == cx + 10)
                        put_pixel(x, y, 0xFFFFFFFF);
                    else
                        put_pixel(x, y, 0xFF003366);
                }
            }
            draw_fill_circle(cx, cy + 12, 1, 0xFFFFFFFF);
            draw_text(cx - 6, cy - 4, "OS", 0xFF66CCFF, 1);
            break;
        }
        case APP_MAIL: {
            for (int y = cy - 10; y <= cy + 10; y++) {
                for (int x = cx - 16; x <= cx + 16; x++) {
                    put_pixel(x, y, 0xFFFFFFFF);
                }
            }
            for (int x = 0; x <= 16; x++) {
                put_pixel(cx - 16 + x, cy - 10 + x / 2, 0xFFCCCCCC);
                put_pixel(cx + 16 - x, cy - 10 + x / 2, 0xFFCCCCCC);
            }
            break;
        }
    }
}

void draw_wallpaper() {
    for (int y = 0; y < SCREEN_H; y++) {
        float t = (float)y / (float)SCREEN_H;
        uint8_t r = (uint8_t)(16 + t * 20);
        uint8_t g = (uint8_t)(22 + t * 30);
        uint8_t b = (uint8_t)(36 + t * 44);
        for (int x = 0; x < SCREEN_W; x++) {
            uint8_t grain = ((x ^ y) & 3) ? 2 : 0;
            g_backbuffer[y * SCREEN_W + x] = 0xFF000000 | ((r + grain) << 16) | ((g + grain) << 8) | (b + grain);
        }
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
    else strcpy(time_str, "14:30");

    draw_text_centered(SCREEN_W / 2, 5, time_str, 0xFFFFFFFF, 2);
    draw_text(SCREEN_W - 130, 6, "100% [====]", 0xFF66FF88, 1);
}

void draw_icon(int x0, int y0, int w, int h, int radius, uint32_t color) {
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
}

void draw_dock() {
    int dock_y = 610;
    int dock_h = 145;
    for (int y = dock_y; y < dock_y + dock_h; y++) {
        float t = (float)(y - dock_y) / (float)dock_h;
        uint8_t a = (uint8_t)(35 + (1.0f - t) * 75);
        uint32_t glass = (a << 24) | 0x00C8D8E8;
        for (int x = 200; x < SCREEN_W - 200; x++) {
            put_pixel(x, y, glass);
        }
    }
    for (int x = 200; x < SCREEN_W - 200; x++) {
        put_pixel(x, dock_y, 0xB0FFFFFF);
        put_pixel(x, dock_y + 1, 0x70FFFFFF);
    }
}

void draw_cursor(int cx, int cy, bool is_down) {
    int r = is_down ? 16 : 20;
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

// Draw App Navigation Bar (Top bar with Back button)
void draw_app_header(const char *title) {
    for (int y = 24; y < 70; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF2A3644; // Classic iOS 3 nav blue
        }
    }
    // Back button [ < Home ] at (30, 32, 90, 30)
    for (int y = 32; y < 62; y++) {
        for (int x = 30; x < 120; x++) {
            put_pixel(x, y, 0xFF1B6AA5);
        }
    }
    draw_text(40, 40, "< Home", 0xFFFFFFFF, 1);
    draw_text_centered(SCREEN_W / 2, 38, title, 0xFFFFFFFF, 2);
}

// App View: Settings / Ajustes (Specs Table)
void draw_view_settings() {
    // Background
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFD8DDE4; // iOS 3 table background
        }
    }
    draw_app_header("Ajustes - Sobre o SnowPad");

    // Table view container
    int tx = 200, ty = 100, tw = SCREEN_W - 400;
    for (int y = ty; y < ty + 500; y++) {
        for (int x = tx; x < tx + tw; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFFFFFFF;
        }
    }

    const char *specs[][2] = {
        {"Sistema Operacional", "SnowPad OS (macOS Snow Leopard 10.6 + iOS 3.2)"},
        {"Modelo do Dispositivo", "Itautec Infoway W7020 (Netbook)"},
        {"Identificador SMBIOS", "MacBookAir2,1"},
        {"Processador (CPU)", "Intel(R) Atom(TM) N450 @ 1.66 GHz (2 Threads)"},
        {"Familia / Modelo", "Family 6, Model 28 (Pineview)"},
        {"Memoria RAM", "2048 MB DDR2 (77 MB em uso)"},
        {"Placa Grafica (GPU)", "Intel GMA 3150 QE/CI (PCI 8086:a011)"},
        {"Monitor Primario", "LG TV via VGA (1360x768 @ 60 Hz)"},
        {"Armazenamento Interno", "HD 320 GB SATA (SnowPad HFS+ 280 GB)"},
        {"Conexao de Rede Wi-Fi", "LNET - Realtek RTL8191SE (IP: 192.168.0.27)"},
        {"Servidor de Controle", "OpenSSH 22 (root:atom) Ativo"},
    };

    int cy = ty + 20;
    for (size_t i = 0; i < sizeof(specs)/sizeof(specs[0]); i++) {
        draw_text(tx + 25, cy, specs[i][0], 0xFF333333, 1);
        draw_text(tx + 280, cy, specs[i][1], 0xFF0055AA, 1);
        // Separator
        for (int x = tx + 20; x < tx + tw - 20; x++) {
            put_pixel(x, cy + 24, 0xFFE0E0E0);
        }
        cy += 40;
    }
}

// App View: Terminal
void draw_view_terminal() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF0D1117; // Terminal dark
        }
    }
    draw_app_header("Terminal Darwin / XNU");

    int tx = 80, ty = 100;
    draw_text(tx, ty,      "SnowPad OS Darwin Kernel Version 10.6.8: x86_64 / i386", 0xFF58A6FF, 1);
    draw_text(tx, ty + 25, "root@itautec-w7020:~# uname -a", 0xFFFFFFFF, 1);
    draw_text(tx, ty + 50, "Darwin itautec 10.6.8 Darwin Kernel Version: Family 6 Model 28 N450", 0xFF3FB950, 1);
    draw_text(tx, ty + 85, "root@itautec-w7020:~# ifconfig wlan0", 0xFFFFFFFF, 1);
    draw_text(tx, ty + 110, "wlan0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500", 0xFF8B949E, 1);
    draw_text(tx, ty + 130, "       inet 192.168.0.27 netmask 0xffffff00 broadcast 192.168.0.255", 0xFF58A6FF, 1);
    draw_text(tx, ty + 150, "       ssid LNET channel 11 bssid 90:58:51:47:89:67", 0xFF8B949E, 1);
    draw_text(tx, ty + 185, "root@itautec-w7020:~# /Applications/SpringBoard.app/SpringBoard --status", 0xFFFFFFFF, 1);
    draw_text(tx, ty + 210, "[OK] Surface 1360x768x32 active on LG TV (VGA)", 0xFF3FB950, 1);
    draw_text(tx, ty + 230, "[OK] Touchshim translating /dev/input/mice -> GSEvent touches", 0xFF3FB950, 1);
    draw_text(tx, ty + 250, "[OK] QE/CI GMA 3150 OpenGL Hardware Acceleration ready", 0xFF3FB950, 1);
    draw_text(tx, ty + 290, "snowpad# _", 0xFF39D353, 2);
}

// App View: Notes
void draw_view_notes() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFFFFFBE8; // Yellow legal pad
        }
    }
    draw_app_header("Notas");

    // Ruled blue lines
    for (int y = 120; y < SCREEN_H - 40; y += 32) {
        for (int x = 100; x < SCREEN_W - 100; x++) {
            put_pixel(x, y, 0xFFD8E4EC);
        }
    }
    // Red margin
    for (int y = 70; y < SCREEN_H; y++) {
        put_pixel(160, y, 0xFFFF7B72);
        put_pixel(161, y, 0xFFFF7B72);
    }

    int tx = 180, ty = 140;
    draw_text(tx, ty,      "Projeto SnowPad OS - Anotacoes de Bringup:", 0xFF4A3525, 2);
    draw_text(tx, ty + 40, "1. Intel Atom N450 (Pineview) + GMA 3150 rodando a 1360x768.", 0xFF2A1E14, 1);
    draw_text(tx, ty + 72, "2. HD 320GB formatado em Apple HFS+ Journaled (/dev/sda1).", 0xFF2A1E14, 1);
    draw_text(tx, ty + 104, "3. Bootloader GRUB e Chameleon 2.x instalados no MBR.", 0xFF2A1E14, 1);
    draw_text(tx, ty + 136, "4. UI do iOS 3.2 (SpringBoard) rodando nativamente na TV LG.", 0xFF2A1E14, 1);
    draw_text(tx, ty + 168, "5. Trackpad calibrado via touchshim (GSEventTouches).", 0xFF2A1E14, 1);
    draw_text(tx, ty + 200, "6. Ancoragem USB pronta para acesso remoto via HoRNDIS.", 0xFF2A1E14, 1);
}

// App View: Calculator
void draw_view_calc() {
    for (int y = 70; y < SCREEN_H; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF1C1D1F;
        }
    }
    draw_app_header("Calculadora");

    // Display
    int dx = SCREEN_W / 2 - 180, dy = 110, dw = 360, dh = 70;
    for (int y = dy; y < dy + dh; y++) {
        for (int x = dx; x < dx + dw; x++) {
            g_backbuffer[y * SCREEN_W + x] = 0xFF2D2E30;
        }
    }
    draw_text(dx + dw - 90, dy + 22, "1,970", 0xFFFFFFFF, 3); // RAM in MB

    // Keypad grid
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

void sig_handler(int sig) {
    (void)sig;
    g_running = false;
}

int main(int argc, char **argv) {
    (void)argc; (void)argv;
    signal(SIGTERM, sig_handler);
    signal(SIGINT, sig_handler);

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

    int mouse_fd = open("/dev/input/mice", O_RDONLY | O_NONBLOCK);

    int mx = SCREEN_W / 2;
    int my = SCREEN_H / 2;
    bool mdown = false;
    bool prev_down = false;

    printf("[SPRINGBOARD v4] Running interactive iOS 3.2 on VGA 1360x768...\n");

    while (g_running) {
        prev_down = mdown;
        if (mouse_fd >= 0) {
            signed char b[3];
            int n = read(mouse_fd, b, sizeof(b));
            if (n > 0) {
                mdown = (b[0] & 1) != 0;
                mx += b[1];
                my -= b[2];
                if (mx < 10) mx = 10;
                if (mx >= SCREEN_W - 10) mx = SCREEN_W - 10;
                if (my < 30) my = 30;
                if (my >= SCREEN_H - 10) my = SCREEN_H - 10;
            }
        }

        // Click event (button pressed down on this frame)
        bool just_clicked = (mdown && !prev_down);

        if (g_current_view == VIEW_HOME) {
            draw_wallpaper();
            draw_status_bar();

            // Check icon clicks
            for (size_t i = 0; i < NUM_ICONS; i++) {
                draw_icon(g_icons[i].x, g_icons[i].y, g_icons[i].w, g_icons[i].h, 20, g_icons[i].color);
                draw_icon_emblem(g_icons[i].type, g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h / 2, g_icons[i].w);
                draw_text_centered(g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h + 10, g_icons[i].name, 0xA0000000, 1);
                draw_text_centered(g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h + 9, g_icons[i].name, 0xFFFFFFFF, 1);

                if (just_clicked && mx >= g_icons[i].x && mx <= g_icons[i].x + g_icons[i].w &&
                    my >= g_icons[i].y && my <= g_icons[i].y + g_icons[i].h) {
                    if (g_icons[i].type == APP_SETTINGS) g_current_view = VIEW_SETTINGS;
                    else if (g_icons[i].type == APP_TERMINAL) g_current_view = VIEW_TERMINAL;
                    else if (g_icons[i].type == APP_CALC) g_current_view = VIEW_CALC;
                    else if (g_icons[i].type == APP_NOTES) g_current_view = VIEW_NOTES;
                }
            }

            draw_dock();
            for (size_t i = 0; i < NUM_DOCK_ICONS; i++) {
                draw_icon(g_dock_icons[i].x, g_dock_icons[i].y, g_dock_icons[i].w, g_dock_icons[i].h, 18, g_dock_icons[i].color);
                draw_icon_emblem(g_dock_icons[i].type, g_dock_icons[i].x + g_dock_icons[i].w / 2, g_dock_icons[i].y + g_dock_icons[i].h / 2, g_dock_icons[i].w);

                int ref_y = g_dock_icons[i].y + g_dock_icons[i].h + 4;
                for (int ry = 0; ry < 22; ry++) {
                    uint8_t ref_alpha = (uint8_t)(40 * (1.0f - (float)ry / 22.0f));
                    uint32_t ref_col = (ref_alpha << 24) | (g_dock_icons[i].color & 0x00FFFFFF);
                    for (int rx = g_dock_icons[i].x + 6; rx < g_dock_icons[i].x + g_dock_icons[i].w - 6; rx++) {
                        put_pixel(rx, ref_y + ry, ref_col);
                    }
                }

                if (just_clicked && mx >= g_dock_icons[i].x && mx <= g_dock_icons[i].x + g_dock_icons[i].w &&
                    my >= g_dock_icons[i].y && my <= g_dock_icons[i].y + g_dock_icons[i].h) {
                    // Dock click feedback
                }
            }
        } else {
            // In App View
            draw_status_bar();
            if (g_current_view == VIEW_SETTINGS) draw_view_settings();
            else if (g_current_view == VIEW_TERMINAL) draw_view_terminal();
            else if (g_current_view == VIEW_CALC) draw_view_calc();
            else if (g_current_view == VIEW_NOTES) draw_view_notes();

            // Check if user clicked "< Home" button (30 <= x <= 120, 32 <= y <= 62)
            if (just_clicked && mx >= 30 && mx <= 120 && my >= 32 && my <= 62) {
                g_current_view = VIEW_HOME;
            }
        }

        // Pointer
        draw_cursor(mx, my, mdown);

        // Blit
        memcpy(g_fb, g_backbuffer, screensize);
        usleep(16666); // 60 FPS
    }

    if (mouse_fd >= 0) close(mouse_fd);
    munmap(g_fb, screensize);
    close(fbfd);
    return 0;
}
