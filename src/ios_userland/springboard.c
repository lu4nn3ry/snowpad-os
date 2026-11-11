/*
 * springboard.c - SnowPad OS Native SpringBoard & Touch Userland Engine (v3)
 * Fullscreen 1360x768x32 UI for external VGA monitor (LG TV).
 *
 * Authentic iOS 3.2 / iPad 1 Icon Artworks:
 * - Safari (Compass needle)
 * - iPod / Música (Double musical note)
 * - Fotos (Sunflower flower petals)
 * - Vídeos (Film clapperboard)
 * - Notas (Ruled notepad with leather header)
 * - Mapas (Highway with red pin)
 * - Ajustes (Mechanical 8-tooth cog/gear)
 * - Calculadora (4-quadrant math symbols)
 * - Relogio (Real-time analog clock hands)
 * - Contatos (Address book silhouette)
 * - Terminal (Monochrome terminal prompt >_)
 * - SnowPad OS (iPad tablet silhouette)
 * - Mail (Folded envelope)
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

// 8x8 bitmap font (ASCII 32 to 126)
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

// Dock icons
static AppIcon g_dock_icons[] = {
    {"Safari", 0xFF1570BD, APP_SAFARI, 460, 630, 80, 80},
    {"Mail",   0xFF2980B9, APP_MAIL,   580, 630, 80, 80},
    {"Fotos",  0xFFEBB400, APP_PHOTOS, 700, 630, 80, 80},
    {"iPod",   0xFFDF5518, APP_MUSIC,  820, 630, 80, 80},
};
#define NUM_DOCK_ICONS (sizeof(g_dock_icons)/sizeof(g_dock_icons[0]))

// Alpha blend
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

// Draw filled circle
void draw_fill_circle(int cx, int cy, int r, uint32_t color) {
    for (int y = cy - r; y <= cy + r; y++) {
        for (int x = cx - r; x <= cx + r; x++) {
            if ((x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r) {
                put_pixel(x, y, color);
            }
        }
    }
}

// Draw text
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

// Draw authentic iOS 3.2 emblem inside icon
void draw_icon_emblem(AppType type, int cx, int cy, int size) {
    int r = size / 3;
    switch (type) {
        case APP_SAFARI: {
            // White compass dial
            draw_fill_circle(cx, cy, r, 0xFFFFFFFF);
            draw_fill_circle(cx, cy, r - 3, 0xFF104E8B);
            // Compass red/white needle
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
            // Double eighth note ♫ in crisp white
            draw_fill_circle(cx - 8, cy + 8, 6, 0xFFFFFFFF);
            draw_fill_circle(cx + 8, cy + 4, 6, 0xFFFFFFFF);
            // Stems
            for (int y = cy - 12; y <= cy + 8; y++) {
                put_pixel(cx - 3, y, 0xFFFFFFFF);
                put_pixel(cx - 4, y, 0xFFFFFFFF);
            }
            for (int y = cy - 16; y <= cy + 4; y++) {
                put_pixel(cx + 13, y, 0xFFFFFFFF);
                put_pixel(cx + 12, y, 0xFFFFFFFF);
            }
            // Connecting beam
            for (int x = cx - 4; x <= cx + 13; x++) {
                put_pixel(x, cy - 14, 0xFFFFFFFF);
                put_pixel(x, cy - 15, 0xFFFFFFFF);
                put_pixel(x, cy - 16, 0xFFFFFFFF);
            }
            break;
        }
        case APP_PHOTOS: {
            // Sunflower with multi-colored petals
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
            // Film clapperboard / play triangle
            draw_fill_circle(cx, cy, r, 0xFF222B38);
            // White play triangle
            for (int x = 0; x < 18; x++) {
                for (int y = -x; y <= x; y++) {
                    put_pixel(cx - 6 + x, cy + y / 2, 0xFFFFFFFF);
                }
            }
            break;
        }
        case APP_NOTES: {
            // Yellow legal pad with leather top
            for (int y = cy - r; y <= cy + r; y++) {
                for (int x = cx - r + 3; x <= cx + r - 3; x++) {
                    put_pixel(x, y, 0xFFFFF8DC);
                }
            }
            // Brown leather top
            for (int y = cy - r; y <= cy - r + 6; y++) {
                for (int x = cx - r + 3; x <= cx + r - 3; x++) {
                    put_pixel(x, y, 0xFF8B4513);
                }
            }
            // Ruled lines
            for (int y = cy - r + 11; y <= cy + r - 4; y += 5) {
                for (int x = cx - r + 6; x <= cx + r - 6; x++) {
                    put_pixel(x, y, 0xFF87CEEB);
                }
            }
            // Red margin line
            for (int y = cy - r + 6; y <= cy + r; y++) {
                put_pixel(cx - r + 9, y, 0xFFFF6347);
            }
            break;
        }
        case APP_MAPS: {
            // Green map with red destination pin
            draw_fill_circle(cx, cy, r, 0xFFEEDDAA);
            // Highway line
            for (int x = cx - r + 2; x <= cx + r - 2; x++) {
                put_pixel(x, cy + (x - cx) / 3, 0xFFFFCC00);
                put_pixel(x, cy + (x - cx) / 3 + 1, 0xFFFFFFFF);
            }
            // Red pin
            draw_fill_circle(cx, cy - 4, 7, 0xFFFF2222);
            draw_fill_circle(cx, cy - 4, 3, 0xFFFFFFFF);
            for (int y = cy + 2; y <= cy + 9; y++) put_pixel(cx, y, 0xFFFF2222);
            break;
        }
        case APP_SETTINGS: {
            // Mechanical 8-tooth gear
            draw_fill_circle(cx, cy, r, 0xFF555D65);
            for (int i = 0; i < 8; i++) {
                float a = (float)i * 0.785f;
                int gx = cx + (int)(cosf(a) * (r - 2));
                int gy = cy + (int)(sinf(a) * (r - 2));
                draw_fill_circle(gx, gy, 5, 0xFF555D65);
            }
            draw_fill_circle(cx, cy, r - 5, 0xFF7A848E);
            draw_fill_circle(cx, cy, 5, 0xFF2A2D32); // Inner hole
            break;
        }
        case APP_CALC: {
            // 4 quadrant math symbols (+, -, *, =)
            draw_text(cx - 14, cy - 14, "+", 0xFFFF9500, 2);
            draw_text(cx + 4,  cy - 14, "-", 0xFFFF9500, 2);
            draw_text(cx - 14, cy + 2,  "x", 0xFFFF9500, 2);
            draw_text(cx + 4,  cy + 2,  "=", 0xFF34AADC, 2);
            break;
        }
        case APP_CLOCK: {
            // Clock face with hands
            draw_fill_circle(cx, cy, r, 0xFFFFFFFF);
            draw_fill_circle(cx, cy, r - 2, 0xFF0D0D0D);
            // Hour hand (pointing to 10)
            for (int i = 0; i < r - 8; i++) {
                put_pixel(cx - (int)(i * 0.6f), cy - (int)(i * 0.8f), 0xFFFFFFFF);
            }
            // Minute hand (pointing to 2)
            for (int i = 0; i < r - 5; i++) {
                put_pixel(cx + (int)(i * 0.7f), cy - (int)(i * 0.7f), 0xFFFFFFFF);
            }
            // Orange second hand (pointing to 6)
            for (int i = 0; i < r - 4; i++) {
                put_pixel(cx, cy + i, 0xFFFF6600);
            }
            draw_fill_circle(cx, cy, 2, 0xFFFF6600);
            break;
        }
        case APP_CONTACTS: {
            // Address book silhouette
            for (int y = cy - r + 3; y <= cy + r - 3; y++) {
                for (int x = cx - r + 4; x <= cx + r - 4; x++) {
                    put_pixel(x, y, 0xFFE0E0E0);
                }
            }
            // Person bust
            draw_fill_circle(cx - 2, cy - 4, 5, 0xFF4A235A);
            for (int y = cy + 2; y <= cy + 10; y++) {
                for (int x = cx - 9; x <= cx + 5; x++) {
                    put_pixel(x, y, 0xFF4A235A);
                }
            }
            // Side tabs
            put_pixel(cx + r - 3, cy - 8, 0xFFFF3333);
            put_pixel(cx + r - 3, cy - 2, 0xFF33CC33);
            put_pixel(cx + r - 3, cy + 4, 0xFF3366FF);
            break;
        }
        case APP_TERMINAL: {
            // Dark green terminal box with >_ prompt
            draw_text(cx - 14, cy - 7, ">_", 0xFF33FF66, 2);
            break;
        }
        case APP_SNOWPAD: {
            // iPad tablet with Apple glow
            draw_fill_circle(cx, cy, r, 0xFF005599);
            // Tablet frame
            for (int y = cy - 14; y <= cy + 14; y++) {
                for (int x = cx - 10; x <= cx + 10; x++) {
                    if (y == cy - 14 || y == cy + 14 || x == cx - 10 || x == cx + 10)
                        put_pixel(x, y, 0xFFFFFFFF);
                    else
                        put_pixel(x, y, 0xFF003366);
                }
            }
            draw_fill_circle(cx, cy + 12, 1, 0xFFFFFFFF); // Home button
            draw_text(cx - 6, cy - 4, "OS", 0xFF66CCFF, 1);
            break;
        }
        case APP_MAIL: {
            // Folded white envelope
            for (int y = cy - 10; y <= cy + 10; y++) {
                for (int x = cx - 16; x <= cx + 16; x++) {
                    put_pixel(x, y, 0xFFFFFFFF);
                }
            }
            // Flap diagonal lines
            for (int x = 0; x <= 16; x++) {
                put_pixel(cx - 16 + x, cy - 10 + x / 2, 0xFFCCCCCC);
                put_pixel(cx + 16 - x, cy - 10 + x / 2, 0xFFCCCCCC);
            }
            break;
        }
    }
}

// Wallpaper
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

// Status Bar
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

// Rounded rect icon with glass gloss
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

// Glass dock shelf
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

// iPadOS touch pointer
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

    printf("[SPRINGBOARD v3] Running authentic iOS 3.2 UI with full icon emblems...\n");

    while (g_running) {
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

        draw_wallpaper();
        draw_status_bar();

        // 12 Grid Icons with Artworks
        for (size_t i = 0; i < NUM_ICONS; i++) {
            draw_icon(g_icons[i].x, g_icons[i].y, g_icons[i].w, g_icons[i].h, 20, g_icons[i].color);
            // Draw emblem
            draw_icon_emblem(g_icons[i].type, g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h / 2, g_icons[i].w);
            // Text label with shadow
            draw_text_centered(g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h + 10, g_icons[i].name, 0xA0000000, 1);
            draw_text_centered(g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h + 9, g_icons[i].name, 0xFFFFFFFF, 1);
        }

        // Dock & Dock Icons
        draw_dock();
        for (size_t i = 0; i < NUM_DOCK_ICONS; i++) {
            draw_icon(g_dock_icons[i].x, g_dock_icons[i].y, g_dock_icons[i].w, g_dock_icons[i].h, 18, g_dock_icons[i].color);
            draw_icon_emblem(g_dock_icons[i].type, g_dock_icons[i].x + g_dock_icons[i].w / 2, g_dock_icons[i].y + g_dock_icons[i].h / 2, g_dock_icons[i].w);

            // Reflection on glass
            int ref_y = g_dock_icons[i].y + g_dock_icons[i].h + 4;
            for (int ry = 0; ry < 22; ry++) {
                uint8_t ref_alpha = (uint8_t)(40 * (1.0f - (float)ry / 22.0f));
                uint32_t ref_col = (ref_alpha << 24) | (g_dock_icons[i].color & 0x00FFFFFF);
                for (int rx = g_dock_icons[i].x + 6; rx < g_dock_icons[i].x + g_dock_icons[i].w - 6; rx++) {
                    put_pixel(rx, ref_y + ry, ref_col);
                }
            }
        }

        // Pointer
        draw_cursor(mx, my, mdown);

        // Blit
        memcpy(g_fb, g_backbuffer, screensize);
        usleep(16666); // ~60 FPS
    }

    if (mouse_fd >= 0) close(mouse_fd);
    munmap(g_fb, screensize);
    close(fbfd);
    return 0;
}
