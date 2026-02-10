#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProxyManager : NSObject

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, copy) NSString *proxyHost;
@property (nonatomic, assign) uint16_t proxyPort;

+ (instancetype)sharedInstance;

- (void)setupHooks;
- (void)attachFloatingButton;
- (void)toggleProxy:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
