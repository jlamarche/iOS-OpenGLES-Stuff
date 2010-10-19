//
// Wavefront_OBJ_Loaderconstants.h
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright Jeff LaMarche 2008. All rights reserved.
//

// How many times a second to refresh the screen
#define kRenderingFrequency 60.0

// For setting up perspective, define near, far, and angle of view
#define kZNear			0.01
#define kZFar			1000.0
#define kFieldOfView	45.0

#define kGroupIndexVertex			0
#define kGroupIndexTextureCoordIndex	1
#define kGroupIndexNormalIndex			2

// Macros
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define CONVERT_UV_U_TO_ST_S(u) ((2*u) / M_PI)