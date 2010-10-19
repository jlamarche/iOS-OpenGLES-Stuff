/*
 *  JDLGLUtils.h
 *  Space Castle
 *
 *  Created by Jeff LaMarche on 9/27/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <CoreGraphics/CoreGraphics.h>

 
void GLDrawCircle (int circleSegments, CGFloat circleSize, CGPoint center, bool filled);
void GLDrawEllipse (int segments, CGFloat width, CGFloat height, CGPoint center, bool filled);
void GLDrawSpokes (int spokeCount, CGFloat radius, CGPoint center);
void GLDrawEllipticalSpokes(int spokeCount, CGFloat width, CGFloat height, CGPoint center);
void GLDrawEllipticalSpokesWithGradient(int spokeCount, CGFloat width, CGFloat height, CGPoint center, UIColor *innerColor, UIColor *outerColor);