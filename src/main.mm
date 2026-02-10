// main entry point for the dylib
// Handles initialization and sets up the floating button

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProxyManager.h"
#import "FloatingButton.h"

__attribute__((constructor)) static void init_proxy_hook()
{
    @autoreleasepool {
        NSLog(@"[ProxyHook] Initializing CFNetwork proxy hook dylib");

        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [[ProxyManager sharedInstance] setupHooks];
                [[ProxyManager sharedInstance] attachFloatingButton];
            } @catch (NSException *exception) {
                NSLog(@"[ProxyHook] Exception during initialization: %@", exception);
            }
        });
    }
}
