#import "CFNetworkHooks.h"

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#import <objc/runtime.h>

static BOOL gHooksEnabled = NO;

typedef CFReadStreamRef (*CFReadStreamCreateForHTTPRequest_t)(CFAllocatorRef alloc, CFHTTPMessageRef request);
static CFReadStreamCreateForHTTPRequest_t orig_CFReadStreamCreateForHTTPRequest;

static CFReadStreamRef hooked_CFReadStreamCreateForHTTPRequest(CFAllocatorRef alloc, CFHTTPMessageRef request)
{
    if (gHooksEnabled && request) {
        CFURLRef url = CFHTTPMessageCopyRequestURL(request);
        if (url) {
            NSString *urlString = (__bridge_transfer NSString *)CFURLCopyAbsoluteURL(url);
            NSLog(@"[ProxyHook] CFReadStreamCreateForHTTPRequest URL: %@", urlString);
            CFRelease(url);
        }
    }

    return orig_CFReadStreamCreateForHTTPRequest(alloc, request);
}

static void hook_symbol(const char *image, const char *symbol, void *replacement, void **orig)
{
    // Minimalist placeholder – in practice you'd use fishhook, substrate, or ElleKit.
    // For now, we just log the intent.
    NSLog(@"[ProxyHook] Requested hook for %s in %s", symbol, image);
}

void CFNetworkHooksSetup(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hook_symbol("/System/Library/Frameworks/CFNetwork.framework/CFNetwork",
                    "CFReadStreamCreateForHTTPRequest",
                    (void *)&hooked_CFReadStreamCreateForHTTPRequest,
                    (void **)&orig_CFReadStreamCreateForHTTPRequest);

        // Future: add more CFNetwork and NSURLSession hooks here.
    });
}

void CFNetworkHooksSetEnabled(BOOL enabled)
{
    gHooksEnabled = enabled;
    NSLog(@"[ProxyHook] CFNetwork hooks %@", enabled ? @"ENABLED" : @"DISABLED");
}
