

#import <UIKit/UIKit.h>

// forward Class Declaration.
@class UIView,UshahidiProjAppDelegate;

//Interface For the Touch on Map.

@interface UIViewTouch : UIView {
    UIView *viewTouched;
	UshahidiProjAppDelegate *app;
}

@property (nonatomic, retain) UIView * viewTouched;

// Definitions of Methods of Implementation

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end