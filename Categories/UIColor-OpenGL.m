//
//  UIColor-OpenGL.m
//  GLTest
//
//  Created by Jeff LaMarche on 8/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "UIColor-OpenGL.h"

@implementation UIColor(OpenGL)
- (void)setOpenGLColor
{
	int numComponents = CGColorGetNumberOfComponents(self.CGColor);
	const CGFloat *components = CGColorGetComponents(self.CGColor);
	if (numComponents == 2)
	{
		CGFloat all = components[0];
		CGFloat alpha = components[1];		
		glColor4f(all,all, all, alpha);
	}
	else
	{
		
		CGFloat red = components[0];
		CGFloat green = components[1];
		CGFloat blue = components[2];
		CGFloat alpha = components[3];
		glColor4f(red,green, blue, alpha);
	}
	
}
- (void)setColorArrayToColor:(UIColor *)toColor
{
	GLfloat *colorArray = malloc(sizeof(GLfloat) * 8);

	int numComponents = CGColorGetNumberOfComponents(self.CGColor);
	const CGFloat *components = CGColorGetComponents(self.CGColor);

	
	if (numComponents == 2)
	{
		colorArray[0] = components[0];
		colorArray[1] = components[0];
		colorArray[2] = components[0];
		colorArray[3] = components[1];
	}
	else
	{
		// Assuming RGBA if not grayscale
		colorArray[0] = components[0];
		colorArray[1] = components[1];
		colorArray[2] = components[2];
		colorArray[3] = components[3];
	}
	
	int otherColorNumComponents = CGColorGetNumberOfComponents(toColor.CGColor);
	const CGFloat *otherComponents = CGColorGetComponents(toColor.CGColor);
	if (otherColorNumComponents == 2)
	{
		colorArray[4] = otherComponents[0];
		colorArray[5] = otherComponents[0];
		colorArray[6] = otherComponents[0];
		colorArray[7] = otherComponents[1];
	}
	else
	{
		// Assuming RGBA if not grayscale
		colorArray[4] = otherComponents[0];
		colorArray[5] = otherComponents[1];
		colorArray[6] = otherComponents[2];
		colorArray[7] = otherComponents[3];
	}
	
	glColorPointer (4, GL_FLOAT, 4*sizeof(GLfloat), colorArray);
	free(colorArray);
	
}
@end
