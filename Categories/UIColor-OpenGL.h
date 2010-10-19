//
//  UIColor-OpenGL.h
//  GLTest
//
//  Created by Jeff LaMarche on 8/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/EAGLDrawable.h>

@interface UIColor(OpenGL)
- (void)setOpenGLColor;
- (void)setColorArrayToColor:(UIColor *)toColor;
@end
