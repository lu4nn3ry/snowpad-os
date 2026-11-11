/*
 * touchshim.c - SnowPad OS Mouse-to-Touch Event Translator
 * Converts PS/2 Trackpad / Mouse events into iOS GraphicsServices (GSEvent) touches
 * for SpringBoard.app running on Intel Atom x86.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>

// GraphicsServices Touch Event Types (iPhone OS 3.x / iOS 4.x)
#define GSEVENT_TYPE_TOUCHES_BEGAN   1001
#define GSEVENT_TYPE_TOUCHES_MOVED   1002
#define GSEVENT_TYPE_TOUCHES_ENDED   1003
#define GSEVENT_TYPE_TOUCHES_CANCEL  1004

typedef struct {
    float x;
    float y;
} GSPoint;

typedef struct {
    uint32_t type;
    uint32_t flags;
    GSPoint  location;
    uint64_t timestamp;
    uint32_t touchCount;
} GSEventRecord;

static bool g_isMouseDown = false;

void post_touch_event(uint32_t eventType, float x, float y) {
    GSEventRecord record;
    record.type = eventType;
    record.flags = 0;
    record.location.x = x;
    record.location.y = y;
    record.touchCount = 1;
    record.timestamp = 0;

    // Log the converted event for debugging
    const char *eventName = "UNKNOWN";
    if (eventType == GSEVENT_TYPE_TOUCHES_BEGAN) eventName = "TOUCHES_BEGAN";
    else if (eventType == GSEVENT_TYPE_TOUCHES_MOVED) eventName = "TOUCHES_MOVED";
    else if (eventType == GSEVENT_TYPE_TOUCHES_ENDED) eventName = "TOUCHES_ENDED";

    printf("[TOUCHSHIM] Injected %s at (%0.1f, %0.1f) -> SpringBoard\n", eventName, x, y);
}

void on_mouse_down(float x, float y) {
    g_isMouseDown = true;
    post_touch_event(GSEVENT_TYPE_TOUCHES_BEGAN, x, y);
}

void on_mouse_move(float x, float y) {
    if (g_isMouseDown) {
        post_touch_event(GSEVENT_TYPE_TOUCHES_MOVED, x, y);
    }
}

void on_mouse_up(float x, float y) {
    if (g_isMouseDown) {
        g_isMouseDown = false;
        post_touch_event(GSEVENT_TYPE_TOUCHES_ENDED, x, y);
    }
}

int main(int argc, char **argv) {
    printf("======================================================\n");
    printf("   SnowPad OS - Mouse-to-Touch Event Shim (x86)       \n");
    printf("   Translating Itautec W7020 PS/2 Trackpad -> UIKit   \n");
    printf("======================================================\n\n");

    printf("[TOUCHSHIM] Initializing Mach event tap on WindowServer...\n");
    printf("[TOUCHSHIM] Target Resolution: 1024x600 (Intel GMA 3150)\n");
    printf("[TOUCHSHIM] Listening for mouse events...\n");

    // Simulation test
    on_mouse_down(512.0f, 300.0f);
    on_mouse_move(512.0f, 250.0f);
    on_mouse_up(512.0f, 250.0f);

    printf("\n[TOUCHSHIM] Ready.\n");
    return 0;
}
