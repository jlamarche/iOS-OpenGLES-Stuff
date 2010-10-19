#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class GLProgram, GLTexture;

@interface GLViewController : UIViewController 
{
}
@property (nonatomic, retain) GLProgram *program;
@property (nonatomic, retain) GLTexture *texture;
- (void)draw;
- (void)setup;
@end
