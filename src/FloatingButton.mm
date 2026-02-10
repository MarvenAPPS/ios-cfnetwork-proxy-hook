#import "FloatingButton.h"

@interface FloatingButton ()
{
    UIButton *_iconButton;
    UISwitch *_toggleSwitch;
    CGPoint _initialTouchPoint;
    CGPoint _initialCenter;
}
@end

@implementation FloatingButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        self.layer.cornerRadius = frame.size.height / 2.0;
        self.layer.masksToBounds = YES;

        _iconButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _iconButton.frame = CGRectMake(4, 4, 32, 32);
        [_iconButton setTitle:@"PX" forState:UIControlStateNormal];
        _iconButton.tintColor = [UIColor whiteColor];
        [_iconButton addTarget:self
                         action:@selector(iconTapped)
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_iconButton];

        _toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        CGRect swFrame = _toggleSwitch.frame;
        swFrame.origin.x = CGRectGetMaxX(_iconButton.frame) + 4;
        swFrame.origin.y = (CGRectGetHeight(frame) - CGRectGetHeight(swFrame)) / 2.0;
        _toggleSwitch.frame = swFrame;
        [_toggleSwitch addTarget:self
                           action:@selector(switchChanged:)
                 forControlEvents:UIControlEventValueChanged];
        [self addSubview:_toggleSwitch];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)iconTapped
{
    // Placeholder for future settings panel
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Proxy Hook"
                                                                   message:@"Toggle the switch to enable or disable the proxy. Settings UI TBD."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (root.presentedViewController) {
        root = root.presentedViewController;
    }
    [root presentViewController:alert animated:YES completion:nil];
}

- (void)switchChanged:(UISwitch *)sender
{
    if (self.toggleChanged) {
        self.toggleChanged(sender.on);
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _initialTouchPoint = location;
        _initialCenter = self.center;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat dx = location.x - _initialTouchPoint.x;
        CGFloat dy = location.y - _initialTouchPoint.y;
        self.center = CGPointMake(_initialCenter.x + dx, _initialCenter.y + dy);
    }
}

@end
