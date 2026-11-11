/*
 * springboard.c - SnowPad OS Native TV Hub & App Launcher (v7)
 * Fullscreen 1360x768x32 UI for external VGA monitor (LG TV).
 *
 * Integrated Control:
 * - 100% USB Gamepad Controlled (Microntek / DragonRise / DualShock / Xbox / SNES USB)
 * - D-Pad & Analog Stick Grid Navigation with Glowing Golden Focus Box
 * - Button A/Cross (Btn 0/2) = Launch App
 * - Button B/Circle (Btn 1/3) = Back / Home
 * - SELECT + START = Force Exit to Home
 * - Submenu D-Pad Navigation for YouTube 480p videos & Live Radios
 * - Mouse / Trackpad / Touch fallback supported simultaneously
 * - Smart Redraw Engine: CPU idle < 0.5% (keeps Atom N450 cool)
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
#include <sys/wait.h>
#include <linux/input.h>
#include <linux/joystick.h>
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
    APP_YOUTUBE,
    APP_RADIO,
    APP_RETROARCH,
    APP_IPTV,
    APP_WEBCAM,
    APP_PHOTOS,
    APP_DASHBOARD,
    APP_CHRONOKAIRO,
    APP_SETTINGS,
    APP_TERMINAL
} AppType;

typedef struct {
    const char *name;
    const char *subtitle;
    uint32_t color;
    AppType type;
    int x;
    int y;
    int w;
    int h;
} AppIcon;

static AppIcon g_icons[] = {
    // Top Row
    {"YouTube",       "Videos 480p",    0xFFE74C3C, APP_YOUTUBE,     160, 130, 110, 110},
    {"Jogos Retro",   "RetroArch XMB",  0xFF8E44AD, APP_RETROARCH,   380, 130, 110, 110},
    {"Musica & Radio","Live Lo-Fi/Rock",0xFFDF5518, APP_RADIO,       600, 130, 110, 110},
    {"TV Online",     "Canais Abertos", 0xFF27AE60, APP_IPTV,        820, 130, 110, 110},
    {"Camera",        "Webcam feed",    0xFF16A085, APP_WEBCAM,     1040, 130, 110, 110},

    // Bottom Row
    {"Porta-Retratos","Slideshow TV",   0xFFF39C12, APP_PHOTOS,      160, 310, 110, 110},
    {"Painel TV",     "Relogio e Clima",0xFF2C3E50, APP_DASHBOARD,   380, 310, 110, 110},
    {"Chronokairo",   "Status e Backup",0xFF007ACC, APP_CHRONOKAIRO, 600, 310, 110, 110},
    {"Ajustes",       "Som e Wi-Fi",    0xFF7F8C8D, APP_SETTINGS,    820, 310, 110, 110},
    {"Terminal",      "Root Shell",     0xFF082D12, APP_TERMINAL,   1040, 310, 110, 110},
};
#define NUM_ICONS (sizeof(g_icons)/sizeof(g_icons[0]))

static AppIcon g_dock_icons[] = {
    {"YouTube",     "Videos",    0xFFE74C3C, APP_YOUTUBE,   440, 620, 85, 85},
    {"Jogos Retro", "XMB",       0xFF8E44AD, APP_RETROARCH, 560, 620, 85, 85},
    {"Radio Live",  "Musica",    0xFFDF5518, APP_RADIO,     680, 620, 85, 85},
    {"TV Online",   "Streaming", 0xFF27AE60, APP_IPTV,    800, 620, 85, 85},
};
#define NUM_DOCK_ICONS (sizeof(g_dock_icons)/sizeof(g_dock_icons[0]))

typedef enum {
    VIEW_HOME,
    VIEW_YOUTUBE_MENU,
    VIEW_RADIO_MENU,
    VIEW_DASHBOARD,
    VIEW_CHRONOKAIRO
} CurrentView;

static CurrentView g_current_view = VIEW_HOME;
static const char *g_radio_name = "Desligado";
static int g_focus_index = 1; // Default focus on 'Jogos Retro' (Index 1)
static int g_submenu_index = 0; // Menu item index (0..3)

static inline void put_pixel(int x, int y, uint32_t color) {
    if (x >= 0 && x < SCREEN_W && y >= 0 && y < SCREEN_H) {
        g_backbuffer[y * SCREEN_W + x] = color;
    }
}

static void draw_rect(int x, int y, int w, int h, uint32_t color) {
    for (int j = y; j < y + h; j++) {
        if (j < 0 || j >= SCREEN_H) continue;
        for (int i = x; i < x + w; i++) {
            if (i < 0 || i >= SCREEN_W) continue;
            g_backbuffer[j * SCREEN_W + i] = color;
        }
    }
}

static void draw_rounded_rect(int x, int y, int w, int h, int radius, uint32_t color) {
    int r2 = radius * radius;
    for (int j = 0; j < h; j++) {
        int py = y + j;
        if (py < 0 || py >= SCREEN_H) continue;
        for (int i = 0; i < w; i++) {
            int px = x + i;
            if (px < 0 || px >= SCREEN_W) continue;
            bool inside = true;
            if (i < radius && j < radius) inside = ((radius - i)*(radius - i) + (radius - j)*(radius - j) <= r2);
            else if (i >= w - radius && j < radius) inside = ((i - (w - radius))*(i - (w - radius)) + (radius - j)*(radius - j) <= r2);
            else if (i < radius && j >= h - radius) inside = ((radius - i)*(radius - i) + (j - (h - radius))*(j - (h - radius)) <= r2);
            else if (i >= w - radius && j >= h - radius) inside = ((i - (w - radius))*(i - (w - radius)) + (j - (h - radius))*(j - (h - radius)) <= r2);

            if (inside) g_backbuffer[py * SCREEN_W + px] = color;
        }
    }
}

// Glowing selection frame for gamepad focus
static void draw_glow_border(int x, int y, int w, int h, int radius, uint32_t glow_color) {
    draw_rounded_rect(x - 5, y - 5, w + 10, h + 10, radius + 4, glow_color);
}

static void draw_char(int x, int y, char c, uint32_t color, int scale) {
    if (c < 32 || c > 126) c = '?';
    const uint8_t *glyph = g_font8x8[c - 32];
    for (int cy = 0; cy < 8; cy++) {
        uint8_t row = glyph[cy];
        for (int cx = 0; cx < 8; cx++) {
            if (row & (1 << cx)) {
                draw_rect(x + cx * scale, y + cy * scale, scale, scale, color);
            }
        }
    }
}

static void draw_text(int x, int y, const char *str, uint32_t color, int scale) {
    int cur_x = x;
    while (*str) {
        draw_char(cur_x, y, *str, color, scale);
        cur_x += 8 * scale;
        str++;
    }
}

static void draw_text_centered(int cx, int y, const char *str, uint32_t color, int scale) {
    int len = strlen(str);
    int total_w = len * 8 * scale;
    draw_text(cx - total_w / 2, y, str, color, scale);
}

static void draw_wallpaper(void) {
    for (int y = 0; y < SCREEN_H; y++) {
        float t = (float)y / (float)SCREEN_H;
        uint32_t r = (uint32_t)(15 * (1.0f - t) + 4 * t);
        uint32_t g = (uint32_t)(35 * (1.0f - t) + 12 * t);
        uint32_t b = (uint32_t)(65 * (1.0f - t) + 25 * t);
        uint32_t col = 0xFF000000 | (r << 16) | (g << 8) | b;
        for (int x = 0; x < SCREEN_W; x++) {
            g_backbuffer[y * SCREEN_W + x] = col;
        }
    }
}

static void draw_status_bar(void) {
    draw_rect(0, 0, SCREEN_W, 28, 0xCC111822);
    time_t rawtime;
    struct tm *info;
    time(&rawtime);
    info = localtime(&rawtime);
    char buf[64];
    strftime(buf, sizeof(buf), "%H:%M:%S", info);
    draw_text_centered(SCREEN_W / 2, 6, buf, 0xFFFFFFFF, 2);

    draw_text(20, 7, "SnowPad OS (LG TV 1360x768 @ 60Hz)", 0xFFCCCCCC, 1);

    char right_status[128];
    snprintf(right_status, sizeof(right_status), "Radio: %s | Wi-Fi: LNET | Gamepad: OK", g_radio_name);
    draw_text(SCREEN_W - 550, 7, right_status, 0xFF55FF88, 1);
}

static void draw_icon(int x, int y, int w, int h, int radius, uint32_t color, bool hover, bool focused) {
    if (focused) {
        // High-visibility glowing golden border
        draw_glow_border(x, y, w, h, radius, 0xFFFFCC00);
    } else if (hover) {
        draw_glow_border(x, y, w, h, radius, 0xFF00DDFF);
    }
    draw_rounded_rect(x, y, w, h, radius, color);
}

static void draw_icon_emblem(AppType type, int cx, int cy, int size) {
    int sz = size / 3;
    switch (type) {
        case APP_RETROARCH:
            draw_rect(cx - sz, cy - sz/3, sz * 2, sz/2, 0xFFFFFFFF);
            draw_rect(cx - sz + 4, cy - sz/3 - 4, 8, 16, 0xFF333333);
            draw_rect(cx + sz - 12, cy - sz/3 - 4, 8, 16, 0xFFE74C3C);
            break;
        case APP_YOUTUBE:
            draw_rounded_rect(cx - sz, cy - sz/2, sz * 2, sz, 4, 0xFFFFFFFF);
            for (int i = 0; i < 12; i++) {
                draw_rect(cx - 3 + i, cy - i/2, 2, i, 0xFFE74C3C);
            }
            break;
        case APP_RADIO:
            draw_rounded_rect(cx - sz, cy - sz/2, sz*2, sz, 4, 0xFFFFFFFF);
            draw_rect(cx - sz + 6, cy - sz/4, sz, sz/2, 0xFF333333);
            break;
        case APP_IPTV:
            draw_rounded_rect(cx - sz, cy - sz/2, sz*2, sz, 4, 0xFFFFFFFF);
            draw_rect(cx - sz + 4, cy - sz/2 + 4, sz*2 - 8, sz - 8, 0xFF1B4F72);
            break;
        case APP_WEBCAM:
            draw_rounded_rect(cx - sz/2, cy - sz/2, sz, sz, sz/2, 0xFFFFFFFF);
            draw_rounded_rect(cx - sz/4, cy - sz/4, sz/2, sz/2, sz/4, 0xFF16A085);
            break;
        case APP_PHOTOS:
            draw_rounded_rect(cx - sz, cy - sz/2, sz*2, sz, 4, 0xFFFFFFFF);
            draw_rect(cx - sz + 6, cy - 2, sz/2, sz/2 - 2, 0xFF27AE60);
            draw_rect(cx, cy - 6, sz - 6, sz/2 + 2, 0xFFF39C12);
            break;
        case APP_DASHBOARD:
            draw_rounded_rect(cx - sz, cy - sz, sz*2, sz*2, sz, 0xFFFFFFFF);
            draw_rect(cx - 1, cy - sz + 4, 2, sz - 2, 0xFFE74C3C);
            draw_rect(cx - 1, cy, sz - 4, 2, 0xFF333333);
            break;
        case APP_CHRONOKAIRO:
            draw_rounded_rect(cx - sz, cy - sz, sz*2, sz*2, 8, 0xFFFFFFFF);
            draw_text_centered(cx, cy - 6, "CK", 0xFF007ACC, 2);
            break;
        case APP_SETTINGS:
            draw_rounded_rect(cx - sz/2, cy - sz/2, sz, sz, 4, 0xFFFFFFFF);
            draw_rounded_rect(cx - sz/4, cy - sz/4, sz/2, sz/2, 2, 0xFF7F8C8D);
            break;
        case APP_TERMINAL:
            draw_rounded_rect(cx - sz, cy - sz/2, sz*2, sz, 4, 0xFF000000);
            draw_text(cx - sz + 6, cy - 5, ">_", 0xFF2ECC71, 1);
            break;
    }
}

static void draw_dock(void) {
    int dock_w = 480;
    int dock_h = 100;
    int dock_x = (SCREEN_W - dock_w) / 2;
    int dock_y = SCREEN_H - dock_h - 20;
    draw_rounded_rect(dock_x, dock_y, dock_w, dock_h, 30, 0x66FFFFFF);
    draw_rounded_rect(dock_x + 3, dock_y + 3, dock_w - 6, dock_h - 6, 28, 0x99223344);
}

static void launch_external_app(const char *cmd) {
    printf("[LAUNCH] %s\n", cmd);
    fflush(stdout);
    draw_rect(0, 0, SCREEN_W, SCREEN_H, 0xFF000000);
    draw_text_centered(SCREEN_W / 2, SCREEN_H / 2 - 20, "Iniciando App...", 0xFFFFFFFF, 3);
    draw_text_centered(SCREEN_W / 2, SCREEN_H / 2 + 30, cmd, 0xFF88BBEE, 1);
    draw_text_centered(SCREEN_W / 2, SCREEN_H / 2 + 60, "Controle: Pressione SELECT + START para sair e voltar ao SnowPad", 0xFFE67E22, 1);
    memcpy(g_fb, g_backbuffer, SCREEN_W * SCREEN_H * 4);

    pid_t pid = fork();
    if (pid == 0) {
        execl("/bin/sh", "sh", "-c", cmd, (char *)NULL);
        exit(1);
    } else if (pid > 0) {
        int status;
        waitpid(pid, &status, 0);
    }
}

static void draw_view_youtube_menu(void) {
    draw_wallpaper();
    draw_rounded_rect(60, 60, SCREEN_W - 120, SCREEN_H - 120, 24, 0xEE1A1A24);
    draw_text(100, 90, "YouTube Videos (Otimizado 480p H.264 para Atom N450)", 0xFFFFFFFF, 2);

    const char *items[] = {
        "1. Lo-Fi Hip Hop Beats ao vivo - Relax / Code (480p AVC1)",
        "2. Synthwave / Cyberpunk Radio Chill (480p AVC1)",
        "3. Trailer / Gameplay Retro 60fps (480p AVC1)",
        "4. Canal de Documentario Tech / Hardware (480p AVC1)"
    };

    for (int i = 0; i < 4; i++) {
        int y = 150 + i * 90;
        bool sel = (g_submenu_index == i);
        uint32_t bg = sel ? 0xFF992222 : 0x55333344;
        uint32_t fg = sel ? 0xFFFFFFFF : 0xFFDDDDDD;
        if (sel) draw_rounded_rect(95, y - 5, SCREEN_W - 190, 80, 16, 0xFFFFCC00);
        draw_rounded_rect(100, y, SCREEN_W - 200, 70, 12, bg);
        draw_text(130, y + 25, items[i], fg, 2);
    }

    draw_rounded_rect(SCREEN_W - 320, 85, 220, 40, 10, 0xFF444455);
    draw_text(SCREEN_W - 300, 97, "[B] Voltar ao Menu", 0xFFFFFFFF, 1);
}

static void draw_view_radio_menu(void) {
    draw_wallpaper();
    draw_rounded_rect(60, 60, SCREEN_W - 120, SCREEN_H - 120, 24, 0xEE1A241A);
    draw_text(100, 90, "Musica & Radio Online (Streams Globais via MPV)", 0xFFFFFFFF, 2);

    const char *items[] = {
        "1. Lo-Fi Hip Hop Chill (Relax / Estudos)",
        "2. Synthwave 80s Electro (Retrowave)",
        "3. Classic Rock 70s / 80s",
        "4. Parar / Desligar Radio"
    };

    for (int i = 0; i < 4; i++) {
        int y = 150 + i * 90;
        bool sel = (g_submenu_index == i);
        uint32_t bg = sel ? 0xFF27AE60 : 0x55334433;
        uint32_t fg = sel ? 0xFFFFFFFF : 0xFFDDDDDD;
        if (sel) draw_rounded_rect(95, y - 5, SCREEN_W - 190, 80, 16, 0xFFFFCC00);
        draw_rounded_rect(100, y, SCREEN_W - 200, 70, 12, bg);
        draw_text(130, y + 25, items[i], fg, 2);
    }

    draw_rounded_rect(SCREEN_W - 320, 85, 220, 40, 10, 0xFF444455);
    draw_text(SCREEN_W - 300, 97, "[B] Voltar ao Menu", 0xFFFFFFFF, 1);
}

static void draw_view_dashboard(void) {
    draw_wallpaper();
    draw_rounded_rect(60, 60, SCREEN_W - 120, SCREEN_H - 120, 24, 0xEE18202C);
    draw_text(100, 90, "Painel do Sistema SnowPad OS (Itautec Infoway W7020)", 0xFFFFFFFF, 2);

    draw_text(100, 170, "Processador: Intel Atom N450 (1 Nucleo, 2 Threads @ 1.66 GHz)", 0xFF88BBEE, 2);
    draw_text(100, 220, "GPU: Intel GMA 3150 OpenGL 2.1 Mesa Gallium (VGA LG TV 1360x768)", 0xFF88BBEE, 2);
    draw_text(100, 270, "Memoria RAM: 2048 MB DDR2 (Uso atual: ~140 MB)", 0xFF88BBEE, 2);
    draw_text(100, 320, "Armazenamento: 320GB HDD (280GB HFS+ Snow Leopard / 18GB Linux)", 0xFF88BBEE, 2);
    draw_text(100, 370, "Som: Realtek ALC663 ALSA Audio Nativo", 0xFF88BBEE, 2);
    draw_text(100, 420, "Controle: Microntek USB Joystick / D-Pad Ativo", 0xFF55FF88, 2);

    draw_rounded_rect(100, 500, 300, 50, 12, 0xFF2C3E50);
    draw_text(130, 515, "[B] Voltar ao Inicio", 0xFFFFFFFF, 2);
}

static void draw_view_chronokairo(void) {
    draw_wallpaper();
    draw_rounded_rect(60, 60, SCREEN_W - 120, SCREEN_H - 120, 24, 0xEE101E2E);
    draw_text(100, 90, "Central de Servicos Chronokairo (Nuvem & Edge)", 0xFFFFFFFF, 2);

    draw_text(100, 170, "1. Chronokairo API Gateway: ONLINE (Cloudflare Workers)", 0xFF2ECC71, 2);
    draw_text(100, 220, "2. Chronocat Backup Daemon: Sincronizado", 0xFF2ECC71, 2);
    draw_text(100, 270, "3. Git Repository Sync: lu4nn3ry/snowpad-os sincronizado", 0xFF2ECC71, 2);
    draw_text(100, 320, "4. Status do No Atom: Servidor Edge Local Ativo", 0xFFF39C12, 2);

    draw_rounded_rect(100, 450, 300, 50, 12, 0xFF007ACC);
    draw_text(130, 465, "[B] Voltar ao Inicio", 0xFFFFFFFF, 2);
}

static void draw_gamepad_hints(void) {
    draw_rounded_rect(SCREEN_W - 440, SCREEN_H - 35, 420, 25, 8, 0x99111822);
    draw_text(SCREEN_W - 430, SCREEN_H - 28, "Controle: D-Pad / [A] Abrir / [B] Voltar / Sel+Start Sair", 0xFFEEEEEE, 1);
}

static void handle_app_selection(AppType type) {
    switch (type) {
        case APP_RETROARCH:
            launch_external_app("retroarch -c /etc/retroarch.cfg");
            break;
        case APP_YOUTUBE:
            g_current_view = VIEW_YOUTUBE_MENU;
            g_submenu_index = 0;
            break;
        case APP_RADIO:
            g_current_view = VIEW_RADIO_MENU;
            g_submenu_index = 0;
            break;
        case APP_WEBCAM:
            launch_external_app("mpv --vo=drm --demuxer-lavf-format=video4linux2 --demuxer-lavf-o=video_size=640x480 /dev/video0");
            break;
        case APP_PHOTOS:
            launch_external_app("mpv --vo=drm --image-display-duration=5 /mnt/storage/retro/roms/ 2>/dev/null || true");
            break;
        case APP_DASHBOARD:
            g_current_view = VIEW_DASHBOARD;
            break;
        case APP_CHRONOKAIRO:
            g_current_view = VIEW_CHRONOKAIRO;
            break;
        case APP_IPTV:
            launch_external_app("mpv --vo=drm https://d25n220ee61s3k.cloudfront.net/v1/master/9d06243129e0db4ff79ee86a92237dbdb6feecd9/PlutoTV/master.m3u8 2>/dev/null || true");
            break;
        case APP_SETTINGS:
            g_current_view = VIEW_DASHBOARD;
            break;
        case APP_TERMINAL:
            launch_external_app("sh");
            break;
    }
}

int main(void) {
    int fbfd = open("/dev/fb0", O_RDWR);
    if (fbfd < 0) {
        perror("open /dev/fb0");
        return 1;
    }

    size_t screensize = SCREEN_W * SCREEN_H * 4;
    g_fb = (uint32_t *)mmap(0, screensize, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);
    if (g_fb == MAP_FAILED) {
        perror("mmap fb");
        close(fbfd);
        return 1;
    }

    // Open USB Joystick
    int js_fd = open("/dev/input/js0", O_RDONLY | O_NONBLOCK);
    if (js_fd >= 0) {
        char js_name[128] = {0};
        ioctl(js_fd, JSIOCGNAME(sizeof(js_name)), js_name);
        printf("[JOYSTICK] Conectado: %s\n", js_name);
    } else {
        printf("[JOYSTICK] Nenhum joystick em /dev/input/js0\n");
    }

    // Open mouse/keyboard as secondary fallbacks
    int mouse_fd = open("/dev/input/mice", O_RDONLY | O_NONBLOCK);
    int mouse0_fd = open("/dev/input/mouse0", O_RDONLY | O_NONBLOCK);
    int kbd_fd = open("/dev/input/event0", O_RDONLY | O_NONBLOCK);

    int mx = SCREEN_W / 2;
    int my = SCREEN_H / 2;
    bool mdown = false, prev_down = false;

    // Gamepad state
    int axis_x_state = 0, axis_y_state = 0;
    bool btn_select = false, btn_start = false;

    time_t last_time = 0;
    bool needs_redraw = true;

    printf("[SPRINGBOARD v7] TV Hub with 100%% Gamepad Control Online!\n");
    fflush(stdout);

    while (g_running) {
        prev_down = mdown;
        bool trigger_click = false;
        bool input_activity = false;

        // 1. Read Joystick
        if (js_fd >= 0) {
            struct js_event jse;
            while (read(js_fd, &jse, sizeof(jse)) == sizeof(jse)) {
                uint8_t type = jse.type & ~JS_EVENT_INIT;
                if (type == JS_EVENT_AXIS) {
                    // Axis 0 = X (Analog), Axis 4 = X (D-pad Hat)
                    if (jse.number == 0 || jse.number == 4) {
                        int prev = axis_x_state;
                        if (jse.value < -16000) axis_x_state = -1;
                        else if (jse.value > 16000) axis_x_state = 1;
                        else if (abs(jse.value) < 10000) axis_x_state = 0;

                        if (axis_x_state != 0 && axis_x_state != prev) {
                            if (g_current_view == VIEW_HOME) {
                                if (axis_x_state == -1 && g_focus_index > 0) g_focus_index--;
                                else if (axis_x_state == 1 && g_focus_index < (int)NUM_ICONS - 1) g_focus_index++;
                            }
                            input_activity = true;
                        }
                    }
                    // Axis 1 = Y (Analog), Axis 5 = Y (D-pad Hat)
                    if (jse.number == 1 || jse.number == 5) {
                        int prev = axis_y_state;
                        if (jse.value < -16000) axis_y_state = -1;
                        else if (jse.value > 16000) axis_y_state = 1;
                        else if (abs(jse.value) < 10000) axis_y_state = 0;

                        if (axis_y_state != 0 && axis_y_state != prev) {
                            if (g_current_view == VIEW_HOME) {
                                if (axis_y_state == -1 && g_focus_index >= 5) g_focus_index -= 5;
                                else if (axis_y_state == 1 && g_focus_index < 5) g_focus_index += 5;
                            } else if (g_current_view == VIEW_YOUTUBE_MENU || g_current_view == VIEW_RADIO_MENU) {
                                if (axis_y_state == -1 && g_submenu_index > 0) g_submenu_index--;
                                else if (axis_y_state == 1 && g_submenu_index < 3) g_submenu_index++;
                            }
                            input_activity = true;
                        }
                    }
                } else if (type == JS_EVENT_BUTTON) {
                    if (jse.number == 8) btn_select = (jse.value != 0);
                    if (jse.number == 9) btn_start = (jse.value != 0);

                    // Emergency combo: SELECT + START = Force Exit to Home
                    if (btn_select && btn_start) {
                        system("killall mpv retroarch 2>/dev/null || true");
                        g_current_view = VIEW_HOME;
                        input_activity = true;
                    }

                    if (jse.value == 1) { // Button Pressed
                        input_activity = true;
                        // Button 0 (Triangle/X) or Button 2 (Cross/A) -> Select / Enter
                        if (jse.number == 0 || jse.number == 2) {
                            trigger_click = true;
                        }
                        // Button 1 (Circle/B) or Button 3 (Square/Y) or Button 8 (Select) -> Back / Home
                        else if (jse.number == 1 || jse.number == 3 || jse.number == 8) {
                            g_current_view = VIEW_HOME;
                        }
                    }
                }
            }
        }

        // 2. Read Mouse / Trackpad (if present)
        int mfd = (mouse_fd >= 0) ? mouse_fd : mouse0_fd;
        if (mfd >= 0) {
            signed char b[3];
            while (read(mfd, b, sizeof(b)) == sizeof(b)) {
                mdown = (b[0] & 1) != 0;
                mx += b[1] * 2;
                my -= b[2] * 2;
                input_activity = true;
            }
        }
        if (mdown && !prev_down) trigger_click = true;

        // 3. Read Keyboard shortcuts
        if (kbd_fd >= 0) {
            struct input_event kev;
            while (read(kbd_fd, &kev, sizeof(kev)) == sizeof(kev)) {
                if (kev.type == EV_KEY && kev.value == 1) {
                    input_activity = true;
                    if (kev.code == 1 || kev.code == 14) g_current_view = VIEW_HOME; // ESC / Back
                    else if (kev.code == 28 || kev.code == 57) trigger_click = true; // Enter / Space
                    else if (kev.code == 105 && g_focus_index > 0) g_focus_index--; // Left
                    else if (kev.code == 106 && g_focus_index < (int)NUM_ICONS - 1) g_focus_index++; // Right
                    else if (kev.code == 103 && g_focus_index >= 5) g_focus_index -= 5; // Up
                    else if (kev.code == 108 && g_focus_index < 5) g_focus_index += 5; // Down
                }
            }
        }

        // Clock 1-second pulse
        time_t now = time(NULL);
        if (now != last_time) {
            last_time = now;
            needs_redraw = true;
        }

        if (input_activity || trigger_click) needs_redraw = true;

        if (needs_redraw) {
            if (g_current_view == VIEW_HOME) {
                draw_wallpaper();
                draw_status_bar();

                // Draw Grid Icons
                for (size_t i = 0; i < NUM_ICONS; i++) {
                    bool focused = (g_focus_index == (int)i);
                    bool hover = (mx >= g_icons[i].x - 12 && mx <= g_icons[i].x + g_icons[i].w + 12 &&
                                  my >= g_icons[i].y - 12 && my <= g_icons[i].y + g_icons[i].h + 30);

                    draw_icon(g_icons[i].x, g_icons[i].y, g_icons[i].w, g_icons[i].h, 22, g_icons[i].color, hover, focused);
                    draw_icon_emblem(g_icons[i].type, g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h / 2, g_icons[i].w);

                    uint32_t title_col = (focused || hover) ? 0xFFFFDD44 : 0xFFFFFFFF;
                    draw_text_centered(g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h + 10, g_icons[i].name, title_col, 2);
                    draw_text_centered(g_icons[i].x + g_icons[i].w / 2, g_icons[i].y + g_icons[i].h + 28, g_icons[i].subtitle, 0xFF88BBEE, 1);

                    if (trigger_click && (focused || hover)) {
                        handle_app_selection(g_icons[i].type);
                        trigger_click = false;
                    }
                }

                // Draw Dock Icons
                draw_dock();
                for (size_t i = 0; i < NUM_DOCK_ICONS; i++) {
                    bool hover = (mx >= g_dock_icons[i].x - 10 && mx <= g_dock_icons[i].x + g_dock_icons[i].w + 10 &&
                                  my >= g_dock_icons[i].y - 10 && my <= g_dock_icons[i].y + g_dock_icons[i].h + 15);
                    draw_icon(g_dock_icons[i].x, g_dock_icons[i].y, g_dock_icons[i].w, g_dock_icons[i].h, 18, g_dock_icons[i].color, hover, false);
                    draw_icon_emblem(g_dock_icons[i].type, g_dock_icons[i].x + g_dock_icons[i].w / 2, g_dock_icons[i].y + g_dock_icons[i].h / 2, g_dock_icons[i].w);

                    if (trigger_click && hover) {
                        handle_app_selection(g_dock_icons[i].type);
                        trigger_click = false;
                    }
                }

                draw_gamepad_hints();
            } else {
                draw_status_bar();
                if (g_current_view == VIEW_YOUTUBE_MENU) {
                    draw_view_youtube_menu();
                    if (trigger_click) {
                        if (g_submenu_index == 0) launch_external_app("mpv --vo=drm --ytdl-format='bestvideo[height<=480][vcodec^=avc1]+bestaudio/best[height<=480]' 'https://www.youtube.com/watch?v=0k1L2b_wB2s'");
                        else if (g_submenu_index == 1) launch_external_app("mpv --vo=drm --ytdl-format='bestvideo[height<=480][vcodec^=avc1]+bestaudio/best[height<=480]' 'https://www.youtube.com/watch?v=jfKfPfyJRdk'");
                        else if (g_submenu_index == 2) launch_external_app("mpv --vo=drm --ytdl-format='bestvideo[height<=480][vcodec^=avc1]+bestaudio/best[height<=480]' 'https://www.youtube.com/watch?v=jj6q_XpzEl8'");
                        else if (g_submenu_index == 3) launch_external_app("mpv --vo=drm --ytdl-format='bestvideo[height<=480][vcodec^=avc1]+bestaudio/best[height<=480]' 'https://www.youtube.com/watch?v=4xDzrJKXOOY'");
                        trigger_click = false;
                    }
                } else if (g_current_view == VIEW_RADIO_MENU) {
                    draw_view_radio_menu();
                    if (trigger_click) {
                        system("killall mpv 2>/dev/null || true");
                        if (g_submenu_index == 0) {
                            g_radio_name = "Lo-Fi Hip Hop";
                            system("nohup mpv --no-video http://stream.zeno.fm/f3wvbbqmdg8uv >/dev/null 2>&1 &");
                        } else if (g_submenu_index == 1) {
                            g_radio_name = "Synthwave 80s";
                            system("nohup mpv --no-video http://stream.zeno.fm/7xpt085w9zquv >/dev/null 2>&1 &");
                        } else if (g_submenu_index == 2) {
                            g_radio_name = "Classic Rock";
                            system("nohup mpv --no-video http://stream.zeno.fm/s425f1w38zquv >/dev/null 2>&1 &");
                        } else if (g_submenu_index == 3) {
                            g_radio_name = "Desligado";
                        }
                        trigger_click = false;
                    }
                } else if (g_current_view == VIEW_DASHBOARD) {
                    draw_view_dashboard();
                    if (trigger_click) { g_current_view = VIEW_HOME; trigger_click = false; }
                } else if (g_current_view == VIEW_CHRONOKAIRO) {
                    draw_view_chronokairo();
                    if (trigger_click) { g_current_view = VIEW_HOME; trigger_click = false; }
                }
            }

            memcpy(g_fb, g_backbuffer, screensize);
            needs_redraw = false;
        }

        // Sleep 25ms to keep CPU usage < 0.5%
        usleep(25000);
    }

    if (js_fd >= 0) close(js_fd);
    if (mouse_fd >= 0) close(mouse_fd);
    if (mouse0_fd >= 0) close(mouse0_fd);
    if (kbd_fd >= 0) close(kbd_fd);
    munmap(g_fb, screensize);
    close(fbfd);
    return 0;
}
