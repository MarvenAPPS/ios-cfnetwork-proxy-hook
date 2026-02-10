#import "ProxyManager.h"
#import "FloatingButton.h"
#import "CFNetworkHooks.h"

#import <objc/runtime.h>

@implementation ProxyManager
{
    FloatingButton *_floatingButton;
}

+ (instancetype)sharedInstance
{
    static ProxyManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enabled = NO;
        _proxyHost = @"127.0.0.1";
        _proxyPort = 8080;
    }
    return self;
}

- (void)setupHooks
{
    NSLog(@"[ProxyHook] Setting up CFNetwork hooks");
    CFNetworkHooksSetup();
}

- (void)attachFloatingButton
{
    if (_floatingButton) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        
        // iOS 13+ compatible way to get key window
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    for (UIWindow *window in windowScene.windows) {
                        if (window.isKeyWindow) {
                            keyWindow = window;
                            break;
                        }
                    }
                    if (keyWindow) break;
                }
            }
        }
        
        // Fallback for older iOS
        if (!keyWindow) {
            keyWindow = [[UIApplication sharedApplication] delegate].window;
        }
        
        if (!keyWindow) {
            NSLog(@"[ProxyHook] No keyWindow found; delaying floating button attach");
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleWindowDidBecomeKey:)
                                                         name:UIWindowDidBecomeKeyNotification
                                                       object:nil];
            return;
        }

        [self createFloatingButtonInWindow:keyWindow];
    });
}

- (void)handleWindowDidBecomeKey:(NSNotification *)notification
{
    UIWindow *window = notification.object;
    if (window && !_floatingButton) {
        [self createFloatingButtonInWindow:window];
    }
}

- (void)createFloatingButtonInWindow:(UIWindow *)window
{
    CGRect frame = CGRectMake(CGRectGetWidth(window.bounds) - 70.0,
                              120.0,
                              56.0,
                              56.0);

    _floatingButton = [[FloatingButton alloc] initWithFrame:frame];
    ProxyManager __weak *weakSelf = self;
    _floatingButton.toggleChanged = ^(BOOL enabled) {
        [weakSelf toggleProxy:enabled];
    };

    [window addSubview:_floatingButton];
    NSLog(@"[ProxyHook] Floating button attached");
}

- (void)toggleProxy:(BOOL)enabled
{
    _enabled = enabled;
    NSLog(@"[ProxyHook] Proxy toggled: %@", enabled ? @"ON" : @"OFF");
    CFNetworkHooksSetEnabled(enabled);
}

@end
