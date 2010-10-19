/*
 *  JDLGLUtils.c
 *  Space Castle
 *
 *  Created by Jeff LaMarche on 9/27/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "JDLGLUtils.h"
#include <math.h>
#include "Constants.h"
#include "UIColor-OpenGL.h"

void GLDrawCircle (int circleSegments, CGFloat circleSize, CGPoint center, bool filled) 
{
	GLDrawEllipse(circleSegments, circleSize, circleSize, center, filled);
}
void GLDrawEllipse (int segments, CGFloat width, CGFloat height, CGPoint center, bool filled)
{
	glTranslatef(center.x, center.y, 0.0);
	GLfloat vertices[segments*2];
	int count=0;
	for (GLfloat i = 0; i < 360.0f; i+=(360.0f/segments))
	{
		vertices[count++] = (cos(degreesToRadian(i))*width);
		vertices[count++] = (sin(degreesToRadian(i))*height);
	}
	glVertexPointer (2, GL_FLOAT , 0, vertices);	
	glDrawArrays ((filled) ? GL_TRIANGLE_FAN : GL_LINE_LOOP, 0, segments);
}
void GLDrawSpokes (int spokeCount, CGFloat radius, CGPoint center)
{
	GLDrawEllipticalSpokes(spokeCount, radius, radius, center);
}
void GLDrawEllipticalSpokes(int spokeCount, CGFloat width, CGFloat height, CGPoint center)
{
	glTranslatef(center.x, center.y, 0.0);
	for (GLfloat i = 0; i < 360.0f; i+=(360.0f/spokeCount))
	{
		GLfloat vertices[4] = {0.0, 0.0, cos(degreesToRadian(i))*width, sin(degreesToRadian(i))*height};
		glVertexPointer(2, GL_FLOAT, 0, vertices);
		glDrawArrays (GL_LINES, 0, 2);
	}
}
void GLDrawEllipticalSpokesWithGradient(int spokeCount, CGFloat width, CGFloat height, CGPoint center, UIColor *innerColor, UIColor *outerColor)
{	
	glTranslatef(center.x, center.y, 0.0);
	for (GLfloat i = 0; i < 360.0f; i+=(360.0f/spokeCount))
	{
		glEnableClientState (GL_COLOR_ARRAY);
		[innerColor setColorArrayToColor:outerColor];
		GLfloat vertices[4] = {0.0, 0.0, cos(degreesToRadian(i))*width, sin(degreesToRadian(i))*height};
		glVertexPointer(2, GL_FLOAT, 0, vertices);
		glDrawArrays (GL_LINES, 0, 2);
		glDisableClientState(GL_COLOR_ARRAY);
	}
}