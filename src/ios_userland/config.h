/*
 * iOS Userland Configuration for SnowPad OS
 * DYLD setup for iPhone OS 3.2 userland on Intel Atom x86
 */

// DYLD Framework Path - Points to iOS frameworks directory
// This allows dyld to find iOS dylibs without conflicting with macOS dylibs
#define DYLD_FRAMEWORK_PATH "/System/iOS/Frameworks"

// iOS 3.2 Userland Directories
#define IOS_ROOT "/System/iOS"
#define IOS_APPLICATIONS "/Applications"
#define IOS_LIBRARY "/System/Library"

// Framework groups
#define IOS_FRAMEWORKS "/System/iOS/Frameworks"
#define IOS_PRIVATE frameworks
#define IOS_COREFOUNDATION "/System/iOS/Frameworks/CoreFoundation.framework"
#define IOS_UIKIT "/System/iOS/Frameworks/UIKit.framework"
#define IOS_GRAPHICSERVICES "/System/iOS/Frameworks/GraphicsServices.framework"
#define IOS_MOBILECORE "/System/iOS/Frameworks/MobileCoreServices.framework"
#define IOS_FOUNDATION "/System/iOS/Frameworks/Foundation.framework"

// iOS Applications
#define IOS_SPRINGBOARD "/Applications/SpringBoard.app"
#define IOS_MOBILESAFARI "/Applications/MobileSafari.app"
#define IOS_PREFERENCES "/Applications/Preferences.app"
#define IOS_MUSICPLAYER "/Applications/MusicPlayer.app"     /* iPod */
#define IOS_NOTES "/Applications/Notes.app"

// Simulated i386 Architecture Note
// Original iOS binaries are ARM, SnowPad OS runs i386 (x86) native binaries
// Framework injection requires x86-compatible Mach-O binaries or translation layer

/* End of iOS Userland Configuration */