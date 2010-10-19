#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>

@class GLViewController;

@interface GLView : UIView
{        
}
@property (nonatomic, retain) IBOutlet GLViewController *controller;
@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
- (void)startAnimation;
- (void)stopAnimation;
@end
