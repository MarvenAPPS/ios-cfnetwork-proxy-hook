#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FloatingButton : UIView

@property (nonatomic, copy, nullable) void (^toggleChanged)(BOOL enabled);

@end

NS_ASSUME_NONNULL_END
