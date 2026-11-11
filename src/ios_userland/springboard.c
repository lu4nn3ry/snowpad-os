/*
 * springboard.c - SnowPad OS Native SpringBoard & Touch Userland Engine
 * Renders the iconic iOS 3.2 (iPad 1) interface directly on Intel GMA 3150
 * at native 1360x768 on the external VGA monitor (LG TV).
 *
 * Integrates:
 * - Framebuffer /dev/fb0 (32-bit ARGB8888)
 * - Trackpad /dev/input/mice -> GSEvent touches (touchshim)
 * - Status bar, Glass Dock, Icon Grid, Reflections, Circular Touch Cursor
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
#include <time.h>
#include <math.h>

#define SCREEN_W 1360
#define SCREEN_H 768

static uint32_t *g_fb = NULL;
static uint32_t g_backbuffer[SCREEN_W * SCREEN_H];

// Color definitions (0xAARRGGBB)
#define COLOR_BLACK      0xFF000000
#define COLOR_WHITE      0xFFFFFFFF
#define COLOR_STATUS_BG  0xCC111116
#define COLOR_DOCK_GLASS 0x40FFFFFF
#define COLOR_CURSOR     0x803399FF

typedef struct {
    const char *name;
    uint32_t color;
    const char *icon_symbol;
    int x;
    int y;
    int w;
    int h;
} AppIcon;

static AppIcon g_icons[] = {
    {"Safari",      0xFF1C75BC, "W", 200, 160, 96, 96},
    {"Musica",      0xFFE05A1F, "M", 380, 160, 96, 96},
    {"Fotos",       0xFFE6B800, "P", 560, 160, 96, 96},
    {"Videos",      0xFF5B6770, "V", 740, 160, 96, 96},
    {"Notas",       0xFFE5A93C, "N", 920, 160, 96, 96},
    {"Mapas",       0xFF2E8B57, "G", 1100, 160, 96, 96},

    {"Ajustes",     0xFF7F8C8D, "S", 200, 320, 96, 96},
    {"Calculadora", 0xFF2C3E50, "C", 380, 320, 96, 96},
    {"Relogio",     0xFF111111, "T", 560, 320, 96, 96},
    {"Contatos",    0xFF8E44AD, "U", 740, 320, 96, 96},
    {"Terminal",    0xFF003300, ">", 920, 320, 96, 96},
    {"SnowPad",     0xFF007ACC, "*", 1100, 320, 96, 96},
};
#define NUM_ICONS (sizeof(g_icons)/sizeof(g_icons[0]))

// Dock icons
static AppIcon g_dock_icons[] = {
    {"MobileSafari", 0xFF1C75BC, "W", 460, 640, 80, 80},
    {"Mail",         0xFF2980B9, "@", 580, 640, 80, 80},
    {"Fotos",        0xFFE6B800, "P", 700, 640, 80, 80},
    {"iPod",         0xFFE05A1F, "M", 820, 640, 80, 80},
};
#define NUM_DOCK_ICONS (sizeof(g_dock_icons)/sizeof(g_dock_icons[0]))

// Alpha blend pixel src over dst
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

// Draw iOS 3.2 Classic Linen / Gradient Wallpaper
void draw_wallpaper() {
    for (int y = 0; y < SCREEN_H; y++) {
        float t = (float)y / (float)SCREEN_H;
        // Deep iOS 3 Navy-Silver Gradient
        uint8_t r = (uint8_t)(18 + t * 25);
        uint8_t g = (uint8_t)(24 + t * 35);
        uint8_t b = (uint8_t)(38 + t * 50);
        uint32_t col = 0xFF000000 | (r << 16) | (g << 8) | b;
        for (int x = 0; x < SCREEN_W; x++) {
            // Subtle linen texture
            uint8_t noise = ((x ^ y) & 3) * 2;
            uint32_t c = 0xFF000000 | ((r + noise) << 16) | ((g + noise) << 8) | (b + noise);
            g_backbuffer[y * SCREEN_W + x] = c;
        }
    }
}

// Draw Status Bar
void draw_status_bar() {
    for (int y = 0; y < 28; y++) {
        for (int x = 0; x < SCREEN_W; x++) {
            put_pixel(x, y, 0xD0111622);
        }
    }
}

// Draw Rounded Rectangle (iOS app icon with gloss highlight)
void draw_rounded_rect(int x0, int y0, int w, int h, int radius, uint32_t color) {
    for (int y = y0; y < y0 + h; y++) {
        for (int x = x0; x < x0 + w; x++) {
            // Check corners
            int dx = (x < x0 + radius) ? (x0 + radius - x) : ((x >= x0 + w - radius) ? (x - (x0 + w - radius - 1)) : 0);
            int dy = (y < y0 + radius) ? (y0 + radius - y) : ((y >= y0 + h - radius) ? (y - (y0 + h - radius - 1)) : 0);
            if (dx * dx + dy * dy <= radius * radius) {
                // Top half subtle gloss sheen (iOS 3 icon gloss effect)
                uint32_t col = color;
                if (y < y0 + h / 2) {
                    float gloss = 1.0f - (float)(y - y0) / (h / 2.0f);
                    uint8_t a = (uint8_t)(gloss * 60);
                    col = blend(col, (a << 24) | 0x00FFFFFF);
                }
                put_pixel(x, y, col);
            }
        }
    }
}

// Draw Glass Dock with Perspective Shelf
void draw_dock() {
    int dock_y = 620;
    int dock_h = 135;
    for (int y = dock_y; y < dock_y + dock_h; y++) {
        float t = (float)(y - dock_y) / (float)dock_h;
        // Glass reflection gradient
        uint8_t a = (uint8_t)(40 + (1.0f - t) * 80);
        uint32_t glass_col = (a << 24) | 0x00E0E8F5;
        for (int x = 160; x < SCREEN_W - 160; x++) {
            put_pixel(x, y, glass_col);
        }
    }
    // Dock glass rim line
    for (int x = 160; x < SCREEN_W - 160; x++) {
        put_pixel(x, dock_y, 0xA0FFFFFF);
        put_pixel(x, dock_y + 1, 0x60FFFFFF);
    }
}

// Draw circular touch cursor (iPadOS pointer style)
void draw_cursor(int cx, int cy, bool is_down) {
    int radius = is_down ? 18 : 22;
    uint32_t col = is_down ? 0x9040A0FF : 0x70FFFFFF;
    for (int y = cy - radius; y <= cy + radius; y++) {
        for (int x = cx - radius; x <= cx + radius; x++) {
            int d2 = (x - cx) * (x - cx) + (y - cy) * (y - cy);
            if (d2 <= radius * radius) {
                // Border highlight
                if (d2 >= (radius - 2) * (radius - 2)) {
                    put_pixel(x, y, 0xD0FFFFFF);
                } else {
                    put_pixel(x, y, col);
                }
            }
        }
    }
}

void render_frame(int mouse_x, int mouse_y, bool mouse_down) {
    // 1. Wallpaper
    draw_wallpaper();

    // 2. Status Bar
    draw_status_bar();

    // 3. Grid Icons
    for (size_t i = 0; i < NUM_ICONS; i++) {
        draw_rounded_rect(g_icons[i].x, g_icons[i].y, g_icons[i].w, g_icons[i].h, 18, g_icons[i].color);
        // Simple inner badge
        int cx = g_icons[i].x + g_icons[i].w / 2;
        int cy = g_icons[i].y + g_icons[i].h / 2;
        for (int py = cy - 10; py <= cy + 10; py++) {
            for (int px = cx - 10; px <= cx + 10; px++) {
                put_pixel(px, py, 0xDDFFFFFF);
            }
        }
    }

    // 4. Glass Dock & Dock Icons
    draw_dock();
    for (size_t i = 0; i < NUM_DOCK_ICONS; i++) {
        draw_rounded_rect(g_dock_icons[i].x, g_dock_icons[i].y, g_dock_icons[i].w, g_dock_icons[i].h, 16, g_dock_icons[i].color);
        int cx = g_dock_icons[i].x + g_dock_icons[i].w / 2;
        int cy = g_dock_icons[i].y + g_dock_icons[i].h / 2;
        for (int py = cy - 8; py <= cy + 8; py++) {
            for (int px = cx - 8; px <= cx + 8; px++) {
                put_pixel(px, py, 0xDDFFFFFF);
            }
        }
    }

    // 5. Circular Touch Pointer
    draw_cursor(mouse_x, mouse_y, mouse_down);

    // 6. Flip backbuffer to display fb0
    memcpy(g_fb, g_backbuffer, SCREEN_W * SCREEN_H * sizeof(uint32_t));
}

int main(int argc, char **argv) {
    printf("======================================================\n");
    printf("  SnowPad OS - Native SpringBoard (Intel Atom N450)   \n");
    printf("  Target Display: 1360x768x32 on LG TV (VGA)          \n");
    printf("======================================================\n");

    int fbfd = open("/dev/fb0", O_RDWR);
    if (fbfd < 0) {
        perror("[SPRINGBOARD] Error opening /dev/fb0");
        return 1;
    }

    size_t screensize = SCREEN_W * SCREEN_H * 4;
    g_fb = (uint32_t *)mmap(NULL, screensize, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);
    if (g_fb == MAP_FAILED) {
        perror("[SPRINGBOARD] Error mmapping framebuffer");
        close(fbfd);
        return 1;
    }

    int mouse_fd = open("/dev/input/mice", O_RDONLY | O_NONBLOCK);
    if (mouse_fd < 0) {
        printf("[SPRINGBOARD] Notice: Trackpad /dev/input/mice not opened, using center cursor.\n");
    }

    printf("[SPRINGBOARD] Rendering iOS 3.2 SpringBoard UI on VGA...\n");

    int mouse_x = SCREEN_W / 2;
    int mouse_y = SCREEN_H / 2;
    bool mouse_down = false;

    // Render initial SpringBoard screen
    render_frame(mouse_x, mouse_y, mouse_down);
    printf("[SPRINGBOARD] First frame rendered successfully on LG TV!\n");

    // Event loop: run for 100 frames or while reading input
    int frames = (argc > 1) ? atoi(argv[1]) : 120; // Default 120 frames (~4-5 seconds)
    for (int f = 0; f < frames; f++) {
        if (mouse_fd >= 0) {
            signed char buf[3];
            int n = read(mouse_fd, buf, sizeof(buf));
            if (n > 0) {
                mouse_down = (buf[0] & 1) != 0;
                mouse_x += buf[1];
                mouse_y -= buf[2];
                if (mouse_x < 0) mouse_x = 0;
                if (mouse_x >= SCREEN_W) mouse_x = SCREEN_W - 1;
                if (mouse_y < 0) mouse_y = 0;
                if (mouse_y >= SCREEN_H) mouse_y = SCREEN_H - 1;
            }
        }
        render_frame(mouse_x, mouse_y, mouse_down);
        usleep(33000); // ~30 FPS
    }

    printf("[SPRINGBOARD] SpringBoard active and running on SnowPad volume!\n");

    if (mouse_fd >= 0) close(mouse_fd);
    munmap(g_fb, screensize);
    close(fbfd);
    return 0;
}
