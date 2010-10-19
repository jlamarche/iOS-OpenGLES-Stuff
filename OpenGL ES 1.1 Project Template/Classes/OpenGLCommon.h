//  OpenGLCommon.h
//  QuatTest
//
//  Created by jeff on 4/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_EMBEDDED
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#else
#import <OpenGL/OpenGL.h>
#endif
#import "ConstantsAndMacros.h"

@class OpenGLWaveFrontMaterial;
#pragma mark -
#pragma mark Color3D
#pragma mark -
typedef struct {
	GLfloat	red;
	GLfloat	green;
	GLfloat	blue;
	GLfloat alpha;
} Color3D;
static inline Color3D Color3DMake(CGFloat inRed, CGFloat inGreen, CGFloat inBlue, CGFloat inAlpha)
{
    Color3D ret;
	ret.red = inRed;
	ret.green = inGreen;
	ret.blue = inBlue;
	ret.alpha = inAlpha;
    return ret;
}
static inline void Color3DSet(Color3D *color, CGFloat inRed, CGFloat inGreen, CGFloat inBlue, CGFloat inAlpha)
{
    color->red = inRed;
    color->green = inGreen;
    color->blue = inBlue;
    color->alpha = inAlpha;
}
static inline Color3D Color3DInterpolate(Color3D color1, Color3D color2, GLfloat percent)
{
	Color3D ret;
	ret.red = color1.red + ((color2.red - color1.red) * percent);
	ret.blue = color1.blue + ((color2.blue - color1.blue) * percent);
	ret.green = color1.green + ((color2.green - color1.green) * percent);
	ret.alpha = color1.alpha + ((color2.alpha - color1.alpha) * percent);
	
	if (ret.red > 1.0)
		ret.red -= 1.0;
	if (ret.green > 1.0)
		ret.green -= 1.0;
	if (ret.blue > 1.0)
		ret.blue -= 1.0;
	if (ret.alpha > 1.0)
		ret.alpha = 1.0;
	if (ret.red < 0.0)
		ret.red += 1.0;
	if (ret.green < 0.0)
		ret.green += 1.0;
	if (ret.blue < 0.0)
		ret.blue += 1.0;
	if (ret.alpha < 0.0)
		ret.alpha += 1.0;
	return ret;
}
#pragma mark -
#pragma mark Vertex3D
#pragma mark -
typedef struct {
	GLfloat	x;
	GLfloat y;
	GLfloat z;
} Vertex3D;

static inline Vertex3D Vertex3DMake(CGFloat inX, CGFloat inY, CGFloat inZ)
{
	Vertex3D ret;
	ret.x = inX;
	ret.y = inY;
	ret.z = inZ;
	return ret;
}
static inline void Vertex3DSet(Vertex3D *vertex, CGFloat inX, CGFloat inY, CGFloat inZ)
{
    vertex->x = inX;
    vertex->y = inY;
    vertex->z = inZ;
}
#pragma mark -
#pragma mark Vector3D
#pragma mark -
typedef Vertex3D Vector3D;
#define Vector3DMake(x,y,z) (Vector3D)Vertex3DMake(x, y, z)
#define Vector3DSet(vector,x,y,z) Vertex3DSet(vector, x, y, z)
static inline GLfloat Vector3DMagnitude(Vector3D vector)
{
	return sqrtf((vector.x * vector.x) + (vector.y * vector.y) + (vector.z * vector.z)); 
}
static inline void Vector3DNormalize(Vector3D *vector)
{
	GLfloat vecMag = Vector3DMagnitude(*vector);
	if ( vecMag == 0.0 )
	{
		vector->x = 1.0;
		vector->y = 0.0;
		vector->z = 0.0;
        return;
	}
	vector->x /= vecMag;
	vector->y /= vecMag;
	vector->z /= vecMag;
}
static inline GLfloat Vector3DDotProduct(Vector3D vector1, Vector3D vector2)
{		
	return vector1.x*vector2.x + vector1.y*vector2.y + vector1.z*vector2.z;
	
}
static inline Vector3D Vector3DCrossProduct(Vector3D vector1, Vector3D vector2)
{
	Vector3D ret;
	ret.x = (vector1.y * vector2.z) - (vector1.z * vector2.y);
	ret.y = (vector1.z * vector2.x) - (vector1.x * vector2.z);
	ret.z = (vector1.x * vector2.y) - (vector1.y * vector2.x);
	return ret;
}
static inline Vector3D Vector3DMakeWithStartAndEndPoints(Vertex3D start, Vertex3D end)
{
	Vector3D ret;
	ret.x = end.x - start.x;
	ret.y = end.y - start.y;
	ret.z = end.z - start.z;
	Vector3DNormalize(&ret);
	return ret;
}
static inline Vector3D Vector3DAdd(Vector3D vector1, Vector3D vector2)
{
	Vector3D ret;
	ret.x = vector1.x + vector2.x;
	ret.y = vector1.y + vector2.y;
	ret.z = vector1.z + vector2.z;
	return ret;
}
static inline void Vector3DFlip (Vector3D *vector)
{
	vector->x = -vector->x;
	vector->y = -vector->y;
	vector->z = -vector->z;
}
static inline void Vector3DRotateToDirection (GLfloat pitch, GLfloat azimuth, Vector3D *vector)
{
	vector->x = -sin(DEGREES_TO_RADIANS(azimuth)) * cos(DEGREES_TO_RADIANS(pitch));
	vector->y = sin(DEGREES_TO_RADIANS(pitch));
	vector->z = cos(DEGREES_TO_RADIANS(pitch)) * cos(DEGREES_TO_RADIANS(azimuth));	
}
#pragma mark -
#pragma mark Rotation3D
#pragma mark -
// A Rotation3D is just a Vertex3D used to store three angles (pitch, yaw, roll) instead of cartesian coordinates. 
// For simplicity, we just reuse the Vertex3D, even though the member names should probably be either xRot, yRot, 
// and zRot, or else pitch, yaw, roll. 
typedef Vertex3D Rotation3D;
#define Rotation3DMake(x,y,z) (Rotation3D)Vertex3DMake(x, y, z)
#pragma mark -
#pragma mark Face3D
#pragma mark -
// Face3D is used to hold three integers which will be integer index values to another array
typedef struct {
	GLushort	v1;
	GLushort	v2;
	GLushort	v3;
} Face3D;
static inline Face3D Face3DMake(int v1, int v2, int v3)
{
	Face3D ret;
	ret.v1 = v1;
	ret.v2 = v2;
	ret.v3 = v3;
	return ret;
}
#pragma mark -
#pragma mark Triangle3D
#pragma mark -
typedef struct {
	Vertex3D v1;
	Vertex3D v2;
	Vertex3D v3;
} Triangle3D;
static inline Triangle3D Triangle3DMake(Vertex3D inV1, Vertex3D inV2, Vertex3D inV3)
{
	Triangle3D ret;
	ret.v1 = inV1;
	ret.v2 = inV2;
	ret.v3 = inV3;
	return ret;
}
static inline Vector3D Triangle3DCalculateSurfaceNormal(Triangle3D triangle)
{
	Vector3D u = Vector3DMakeWithStartAndEndPoints(triangle.v2, triangle.v1);
	Vector3D v = Vector3DMakeWithStartAndEndPoints(triangle.v3, triangle.v1);
	
	Vector3D ret;
	ret.x = (u.y * v.z) - (u.z * v.y);
	ret.y = (u.z * v.x) - (u.x * v.z);
	ret.z = (u.x * v.y) - (u.y * v.x);
	return ret;
}
#pragma mark -
#pragma mark Interleaving
#pragma mark -
typedef struct {
    GLfloat     s;
    GLfloat     t;
} TextureCoord3D;

typedef struct {
    Vertex3D    vertex;
    Vector3D    normal;
} VertexData3D;
typedef struct {
    Vertex3D        vertex;
    Vector3D        normal;
    TextureCoord3D  texCoord;
} TexturedVertexData3D;
typedef struct {
    Vertex3D    vertex;
    Vector3D    normal;
    Color3D     color;
} ColoredVertexData3D;

#pragma mark -
#pragma mark Matrices
#pragma mark -

typedef GLfloat Matrix3D[16];
// OpenGL ES hardware accelerates Vector * Matrix but not Matrix * Matrix
/* 
 These defines, the fast sine function, and the vectorized version of the 
 matrix multiply function below are based on the Matrix4Mul method from 
 the vfp-math-library. Thi code has been modified, and are subject to  
 the original license terms and ownership as follow:
 
 VFP math library for the iPhone / iPod touch
 
 Copyright (c) 2007-2008 Wolfgang Engel and Matthias Grundmann
 http://code.google.com/p/vfpmathlibrary/
 
 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising
 from the use of this software.
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it freely,
 subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must
 not claim that you wrote the original software. If you use this
 software in a product, an acknowledgment in the product documentation
 would be appreciated but is not required.
 
 2. Altered source versions must be plainly marked as such, and must
 not be misrepresented as being the original software.
 
 3. This notice may not be removed or altered from any source distribution.
 */
static inline float fastAbs(float x) { return (x < 0) ? -x : x; }
static inline GLfloat fastSinf(GLfloat x)
{
	// fast sin function; maximum error is 0.001
	const float P = 0.225;
	
	x = x * M_1_PI;
	int k = (int) round(x);
	x = x - k;
    
	float y = (4 - 4 * fastAbs(x)) * x;
    
	y = P * (y * fastAbs(y) - y) + y;
    
	return (k&1) ? -y : y;
}

#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#define VFP_CLOBBER_S0_S31 "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8",  \
"s9", "s10", "s11", "s12", "s13", "s14", "s15", "s16",  \
"s17", "s18", "s19", "s20", "s21", "s22", "s23", "s24",  \
"s25", "s26", "s27", "s28", "s29", "s30", "s31"
#define VFP_VECTOR_LENGTH(VEC_LENGTH) "fmrx    r0, fpscr                         \n\t" \
"bic     r0, r0, #0x00370000               \n\t" \
"orr     r0, r0, #0x000" #VEC_LENGTH "0000 \n\t" \
"fmxr    fpscr, r0                         \n\t"
#define VFP_VECTOR_LENGTH_ZERO "fmrx    r0, fpscr            \n\t" \
"bic     r0, r0, #0x00370000  \n\t" \
"fmxr    fpscr, r0            \n\t" 
#endif
static inline void Matrix3DMultiply(Matrix3D m1, Matrix3D m2, Matrix3D result)
{
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    __asm__ __volatile__ ( VFP_VECTOR_LENGTH(3)
                          
                          // Interleaving loads and adds/muls for faster calculation.
                          // Let A:=src_ptr_1, B:=src_ptr_2, then
                          // function computes A*B as (B^T * A^T)^T.
                          
                          // Load the whole matrix into memory.
                          "fldmias  %2, {s8-s23}    \n\t"
                          // Load first column to scalar bank.
                          "fldmias  %1!, {s0-s3}    \n\t"
                          // First column times matrix.
                          "fmuls s24, s8, s0        \n\t"
                          "fmacs s24, s12, s1       \n\t"
                          
                          // Load second column to scalar bank.
                          "fldmias %1!,  {s4-s7}    \n\t"
                          
                          "fmacs s24, s16, s2       \n\t"
                          "fmacs s24, s20, s3       \n\t"
                          // Save first column.
                          "fstmias  %0!, {s24-s27}  \n\t" 
                          
                          // Second column times matrix.
                          "fmuls s28, s8, s4        \n\t"
                          "fmacs s28, s12, s5       \n\t"
                          
                          // Load third column to scalar bank.
                          "fldmias  %1!, {s0-s3}    \n\t"
                          
                          "fmacs s28, s16, s6       \n\t"
                          "fmacs s28, s20, s7       \n\t"
                          // Save second column.
                          "fstmias  %0!, {s28-s31}  \n\t" 
                          
                          // Third column times matrix.
                          "fmuls s24, s8, s0        \n\t"
                          "fmacs s24, s12, s1       \n\t"
                          
                          // Load fourth column to scalar bank.
                          "fldmias %1,  {s4-s7}    \n\t"
                          
                          "fmacs s24, s16, s2       \n\t"
                          "fmacs s24, s20, s3       \n\t"
                          // Save third column.
                          "fstmias  %0!, {s24-s27}  \n\t" 
                          
                          // Fourth column times matrix.
                          "fmuls s28, s8, s4        \n\t"
                          "fmacs s28, s12, s5       \n\t"
                          "fmacs s28, s16, s6       \n\t"
                          "fmacs s28, s20, s7       \n\t"
                          // Save fourth column.
                          "fstmias  %0!, {s28-s31}  \n\t" 
                          
                          VFP_VECTOR_LENGTH_ZERO
                          : "=r" (result), "=r" (m2)
                          : "r" (m1), "0" (result), "1" (m2)
                          : "r0", "cc", "memory", VFP_CLOBBER_S0_S31
                          );
#else
    result[0] = m1[0] * m2[0] + m1[4] * m2[1] + m1[8] * m2[2] + m1[12] * m2[3];
    result[1] = m1[1] * m2[0] + m1[5] * m2[1] + m1[9] * m2[2] + m1[13] * m2[3];
    result[2] = m1[2] * m2[0] + m1[6] * m2[1] + m1[10] * m2[2] + m1[14] * m2[3];
    result[3] = m1[3] * m2[0] + m1[7] * m2[1] + m1[11] * m2[2] + m1[15] * m2[3];
    
    result[4] = m1[0] * m2[4] + m1[4] * m2[5] + m1[8] * m2[6] + m1[12] * m2[7];
    result[5] = m1[1] * m2[4] + m1[5] * m2[5] + m1[9] * m2[6] + m1[13] * m2[7];
    result[6] = m1[2] * m2[4] + m1[6] * m2[5] + m1[10] * m2[6] + m1[14] * m2[7];
    result[7] = m1[3] * m2[4] + m1[7] * m2[5] + m1[11] * m2[6] + m1[15] * m2[7];
    
    result[8] = m1[0] * m2[8] + m1[4] * m2[9] + m1[8] * m2[10] + m1[12] * m2[11];
    result[9] = m1[1] * m2[8] + m1[5] * m2[9] + m1[9] * m2[10] + m1[13] * m2[11];
    result[10] = m1[2] * m2[8] + m1[6] * m2[9] + m1[10] * m2[10] + m1[14] * m2[11];
    result[11] = m1[3] * m2[8] + m1[7] * m2[9] + m1[11] * m2[10] + m1[15] * m2[11];
    
    result[12] = m1[0] * m2[12] + m1[4] * m2[13] + m1[8] * m2[14] + m1[12] * m2[15];
    result[13] = m1[1] * m2[12] + m1[5] * m2[13] + m1[9] * m2[14] + m1[13] * m2[15];
    result[14] = m1[2] * m2[12] + m1[6] * m2[13] + m1[10] * m2[14] + m1[14] * m2[15];
    result[15] = m1[3] * m2[12] + m1[7] * m2[13] + m1[11] * m2[14] + m1[15] * m2[15];
#endif
    
}
static inline void Matrix3DSetIdentity(Matrix3D matrix)
{
    matrix[0] = matrix[5] =  matrix[10] = matrix[15] = 1.0;
    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.0;
    matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0.0;    
    matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
}
static inline void Matrix3DSetTranslation(Matrix3D matrix, GLfloat xTranslate, GLfloat yTranslate, GLfloat zTranslate)
{
    matrix[0] = matrix[5] =  matrix[10] = matrix[15] = 1.0;
    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.0;
    matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0.0;    
    matrix[11] = 0.0;
    matrix[12] = xTranslate;
    matrix[13] = yTranslate;
    matrix[14] = zTranslate;   
}
static inline void Matrix3DSetScaling(Matrix3D matrix, GLfloat xScale, GLfloat yScale, GLfloat zScale)
{
    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.0;
    matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0.0;
    matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
    matrix[0] = xScale;
    matrix[5] = yScale;
    matrix[10] = zScale;
    matrix[15] = 1.0;
}
static inline void Matrix3DSetUniformScaling(Matrix3D matrix, GLfloat scale)
{
    Matrix3DSetScaling(matrix, scale, scale, scale);
}
static inline void Matrix3DSetXRotationUsingRadians(Matrix3D matrix, GLfloat degrees)
{
    matrix[0] = matrix[15] = 1.0;
    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.0;
    matrix[7] = matrix[8] = 0.0;    
    matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
    
    matrix[5] = cosf(degrees);
    matrix[6] = -fastSinf(degrees);
    matrix[9] = -matrix[6];
    matrix[10] = matrix[5];
}
static inline void Matrix3DSetXRotationUsingDegrees(Matrix3D matrix, GLfloat degrees)
{
    Matrix3DSetXRotationUsingRadians(matrix, degrees * M_PI / 180.0);
}
static inline void Matrix3DSetYRotationUsingRadians(Matrix3D matrix, GLfloat degrees)
{
    matrix[0] = cosf(degrees);
    matrix[2] = fastSinf(degrees);
    matrix[8] = -matrix[2];
    matrix[10] = matrix[0];
    matrix[1] = matrix[3] = matrix[4] = matrix[6] = matrix[7] = 0.0;
    matrix[9] = matrix[11] = matrix[13] = matrix[12] = matrix[14] = 0.0;
    matrix[5] = matrix[15] = 1.0;
}
static inline void Matrix3DSetYRotationUsingDegrees(Matrix3D matrix, GLfloat degrees)
{
    Matrix3DSetYRotationUsingRadians(matrix, degrees * M_PI / 180.0);
}
static inline void Matrix3DSetZRotationUsingRadians(Matrix3D matrix, GLfloat degrees)
{
    matrix[0] = cosf(degrees);
    matrix[1] = fastSinf(degrees);
    matrix[4] = -matrix[1];
    matrix[5] = matrix[0];
    matrix[2] = matrix[3] = matrix[6] = matrix[7] = matrix[8] = 0.0;
    matrix[9] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
    matrix[10] = matrix[15] = 1.0;
}
static inline void Matrix3DSetZRotationUsingDegrees(Matrix3D matrix, GLfloat degrees)
{
    Matrix3DSetZRotationUsingRadians(matrix, degrees * M_PI / 180.0);
}
static inline void Matrix3DSetRotationByRadians(Matrix3D matrix, GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{
    GLfloat mag = sqrtf((x*x) + (y*y) + (z*z));
    if (mag == 0.0)
    {
        x = 1.0;
        y = 0.0;
        z = 0.0;
    }
    else if (mag != 1.0)
    {
        x /= mag;
        y /= mag;
        z /= mag;
    }
    
    GLfloat c = cosf(angle);
    GLfloat s = fastSinf(angle);
    matrix[3] = matrix[7] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
    matrix[15] = 1.0;
    
    
    matrix[0] = (x*x)*(1-c) + c;
    matrix[1] = (y*x)*(1-c) + (z*s);
    matrix[2] = (x*z)*(1-c) - (y*s);
    matrix[4] = (x*y)*(1-c)-(z*s);
    matrix[5] = (y*y)*(1-c)+c;
    matrix[6] = (y*z)*(1-c)+(x*s);
    matrix[8] = (x*z)*(1-c)+(y*s);
    matrix[9] = (y*z)*(1-c)-(x*s);
    matrix[10] = (z*z)*(1-c)+c;
    
}
static inline void Matrix3DSetRotationByDegrees(Matrix3D matrix, GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{
    Matrix3DSetRotationByRadians(matrix, angle * M_PI / 180.0, x, y, z);
}
static inline void Matrix3DSetShear(Matrix3D matrix, GLfloat xShear, GLfloat yShear)
{
    matrix[0] = matrix[5] =  matrix[10] = matrix[15] = 1.0;
    matrix[1] = matrix[2] = matrix[3] = 0.0;
    matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0.0;    
    matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
    matrix[1] = xShear;
    matrix[4] = yShear;
}
#pragma mark -
#pragma mark Quaternions
#pragma mark -
typedef struct {
	GLfloat x;
	GLfloat y;
	GLfloat z;
    GLfloat w;
} Quaternion3D;
static inline void Quaternion3DNormalize(Quaternion3D *quaternion) 
{
    GLfloat magnitude;
    
    magnitude = sqrtf((quaternion->x * quaternion->x) +
                      (quaternion->y * quaternion->y) +
                      (quaternion->z * quaternion->z) +
                      (quaternion->w * quaternion->w));
    
    quaternion->x /= magnitude;
    quaternion->y /= magnitude;
    quaternion->z /= magnitude;
    quaternion->w /= magnitude;
}
static inline Quaternion3D Quaternion3DMakeWithMatrix3D(Matrix3D matrix) 
{
    Quaternion3D quat;
    GLfloat trace, s;
    
    // Trace of diagonal
	trace = matrix[0] + matrix[5] + matrix[10];
	if (trace > 0.0f)
	{
		s = sqrtf(trace + 1.0f);
		quat.w = s * 0.5f;
		s = 0.5f / s;
        
		quat.x = (matrix[9] - matrix[6]) * s;
		quat.y = (matrix[2] - matrix[8]) * s;
		quat.z = (matrix[4] - matrix[1]) * s;
	}
	else
	{
		NSInteger biggest;
		enum      {A,E,I};
		if (matrix[0] > matrix[5])
			if (matrix[10] > matrix[0])
				biggest = I;	
			else
				biggest = A;
            else
                if (matrix[10] > matrix[0])
                    biggest = I;
                else
                    biggest = E;
        
		switch (biggest)
		{
			case A:
				s = sqrtf(matrix[0] - (matrix[5] + matrix[10]) + 1.0f);
				if (s > QUATERNION_TRACE_ZERO_TOLERANCE)
				{
					quat.x = s * 0.5f;
					s = 0.5f / s;
					quat.w = (matrix[9] - matrix[6]) * s;
					quat.y = (matrix[1] + matrix[4]) * s;
					quat.z = (matrix[2] + matrix[8]) * s;
					break;
				}
				s = sqrtf(matrix[10] - (matrix[0] + matrix[5]) + 1.0f);
				if (s > QUATERNION_TRACE_ZERO_TOLERANCE)
				{
					quat.z = s * 0.5f;
					s = 0.5f / s;
					quat.w = (matrix[4] - matrix[1]) * s;
					quat.x = (matrix[8] + matrix[2]) * s;
					quat.y = (matrix[9] + matrix[6]) * s;
					break;
				}
				s = sqrtf(matrix[5] - (matrix[10] + matrix[0]) + 1.0f);
				if (s > QUATERNION_TRACE_ZERO_TOLERANCE)
				{
					quat.y = s * 0.5f;
					s = 0.5f / s;
					quat.w = (matrix[2] - matrix[8]) * s;
					quat.z = (matrix[6] + matrix[9]) * s;
					quat.x = (matrix[4] + matrix[1]) * s;
					break;
				}
				break;
                
			case E:
				s = sqrtf(matrix[5] - (matrix[10] + matrix[0]) + 1.0f);
				if (s > QUATERNION_TRACE_ZERO_TOLERANCE)
				{
					quat.y = s * 0.5f;
					s = 0.5f / s;
					quat.w = (matrix[2] - matrix[8]) * s;
					quat.z = (matrix[6] + matrix[9]) * s;
					quat.x = (matrix[4] + matrix[1]) * s;
					break;
				}
				s = sqrtf(matrix[10] - (matrix[0] + matrix[5]) + 1.0f);
				if (s > QUATERNION_TRACE_ZERO_TOLERANCE)
				{
					quat.z = s * 0.5f;
					s = 0.5f / s;
					quat.w = (matrix[4] - matrix[1]) * s;
					quat.x = (matrix[8] + matrix[2]) * s;
					quat.y = (matrix[9] + matrix[6]) * s;
					break;
				}
				s = sqrtf(matrix[0] - (matrix[5] + matrix[10]) + 1.0f);
				if (s > QUATERNION_TRACE_ZERO_TOLERANCE)
				{
					quat.x = s * 0.5f;
					s = 0.5f / s;
					quat.w = (matrix[9] - matrix[6]) * s;
					quat.y = (matrix[1] + matrix[4]) * s;
					quat.z = (matrix[2] + matrix[8]) * s;
					break;
				}
				break;
                
			case I:
				s = sqrtf(matrix[10] - (matrix[0] + matrix[5]) + 1.0f);
				if (s > QUATERNION_TRACE_ZERO_TOLERANCE)
				{
					quat.z = s * 0.5f;
					s = 0.5f / s;
					quat.w = (matrix[4] - matrix[1]) * s;
					quat.x = (matrix[8] + matrix[2]) * s;
					quat.y = (matrix[9] + matrix[6]) * s;
					break;
				}
				s = sqrtf(matrix[0] - (matrix[5] + matrix[10]) + 1.0f);
				if (s > QUATERNION_TRACE_ZERO_TOLERANCE)
				{
					quat.x = s * 0.5f;
					s = 0.5f / s;
					quat.w = (matrix[9] - matrix[6]) * s;
					quat.y = (matrix[1] + matrix[4]) * s;
					quat.z = (matrix[2] + matrix[8]) * s;
					break;
				}
				s = sqrtf(matrix[5] - (matrix[10] + matrix[0]) + 1.0f);
				if (s > QUATERNION_TRACE_ZERO_TOLERANCE)
				{
					quat.y = s * 0.5f;
					s = 0.5f / s;
					quat.w = (matrix[2] - matrix[8]) * s;
					quat.z = (matrix[6] + matrix[9]) * s;
					quat.x = (matrix[4] + matrix[1]) * s;
					break;
				}
				break;
                
			default:
                break;
		}
	} 
    return quat;
}
static inline void Matrix3DSetUsingQuaternion3D(Matrix3D matrix, Quaternion3D quat)
{
    matrix[0]  = (1.0f - (2.0f * ((quat.y * quat.y) + (quat.z * quat.z))));
    matrix[1]  = (2.0f * ((quat.x * quat.y) - (quat.z * quat.w)));
    matrix[2]  = (2.0f * ((quat.x * quat.z) + (quat.y * quat.w)));
    matrix[3] = 0.0f;
    matrix[4]  = (2.0f * ((quat.x * quat.y) + (quat.z * quat.w)));
    matrix[5]  = (1.0f - (2.0f * ((quat.x * quat.x) + (quat.z * quat.z))));
    matrix[6]  = (2.0f * ((quat.y * quat.z) - (quat.x * quat.w)));
    matrix[7] = 0.0f;
    matrix[8]  = (2.0f * ((quat.x * quat.z) - (quat.y * quat.w)));
    matrix[9]  = (2.0f * ((quat.y * quat.z) + (quat.x * quat.w)));
    matrix[10] = (1.0f - (2.0f * ((quat.x * quat.x) + (quat.y * quat.y))));
    matrix[11] = 0.0f;
    matrix[12]  = 0.0f;
    matrix[13]  = 0.0f;
    matrix[14] = 0.0f;
    matrix[15] = 1.0f;
}
static inline Quaternion3D Quaternion3DMakeWithAxisAndAngle(Vector3D axis, GLfloat angle) 
{
    Quaternion3D quat;
    GLfloat sinAngle;
    
    angle *= 0.5f;
    Vector3DNormalize(&axis);
    sinAngle = sinf(angle);
    quat.x = (axis.x * sinAngle);
    quat.y = (axis.y * sinAngle);
    quat.z = (axis.z * sinAngle);
    quat.w = cos(angle);
    
    return quat;
}
static inline void Quaternion3DExtractAxisAndAngle(Quaternion3D quat, Vector3D *axis, GLfloat *angle) 
{
    GLfloat s;
    Quaternion3DNormalize(&quat);
    s = sqrtf(1.0f - (quat.w * quat.w));
    
    if (fabs(s) < 0.0005f) s = 1.0f;
    
    if (axis != NULL) 
    {
        axis->x = (quat.x / s);
        axis->y = (quat.y / s);
        axis->z = (quat.z / s);
    }
    
    if (angle != NULL) 
        *angle = (acosf(quat.w) * 2.0f);
}
static inline void Quaternion3DMultiply(Quaternion3D *quat1, Quaternion3D *quat2) 
{
    Vector3D v1, v2, cp;
    float angle;
    
    v1.x = quat1->x;
    v1.y = quat1->y;
    v1.z = quat1->z;
    v2.x = quat2->x;
    v2.y = quat2->y;
    v2.z = quat2->z;
    angle = (quat1->w * quat2->w) - Vector3DDotProduct(v1, v2);
    
    cp = Vector3DCrossProduct(v1, v2);
    v1.x *= quat2->w;
    v1.y *= quat2->w;
    v1.z *= quat2->w;
    v2.x *= quat1->w;
    v2.y *= quat1->w;
    v2.z *= quat1->w;
    
    quat1->x = v1.x + v2.x + cp.x;
    quat1->y = v1.y + v2.y + cp.y;
    quat1->z = v1.z + v2.z + cp.z;
    quat1->w = angle;
}
static inline void Quaternion3DInvert(Quaternion3D  *quat) 
{
    GLfloat length = 1.0f / ((quat->x * quat->x) +
                             (quat->y * quat->y) +
                             (quat->z * quat->z) +
                             (quat->w * quat->w));
    quat->x *= -length;
    quat->y *= -length;
    quat->z *= -length;
    quat->w *= length;
}
static inline Quaternion3D Quaternion3DMakeWithEulerAngles(GLfloat x, GLfloat y, GLfloat z)
{
    Vector3D vx = Vector3DMake(1.f, 0.f, 0.f);
    Vector3D vy = Vector3DMake(0.f, 1.f, 0.f);
    Vector3D vz = Vector3DMake(0.f, 0.f, 1.f);
    
    Quaternion3D qx = Quaternion3DMakeWithAxisAndAngle(vx, x);
    Quaternion3D qy = Quaternion3DMakeWithAxisAndAngle(vy, y);
    Quaternion3D qz = Quaternion3DMakeWithAxisAndAngle(vz, z);
    
    
    
    Quaternion3DMultiply(&qx, &qy );
    Quaternion3DMultiply(&qx, &qz );
    return qx;
}
static inline Quaternion3D Quaternion3DMakeWithNLERP(Quaternion3D *start, Quaternion3D *finish, GLclampf progress)
{
    Quaternion3D ret;
    GLfloat inverseProgress = 1.0f - progress;
    ret.x = (start->x * inverseProgress) + (finish->x * progress);     
    ret.y = (start->y * inverseProgress) + (finish->y * progress);
    ret.z = (start->z * inverseProgress) + (finish->z * progress);
    ret.w = (start->w * inverseProgress) + (finish->w * progress);
    Quaternion3DNormalize(&ret);
    return ret;
}
static inline GLfloat Quaternion3DDotProduct(Quaternion3D *quart1, Quaternion3D *quart2)
{
    return quart1->x * quart2->x + quart2->y * quart2->y + quart1->z * quart2->z + quart1->w * quart2->w;
}
static inline Quaternion3D Quaternion3DMakeWithSLERP(Quaternion3D *start, Quaternion3D *finish, GLclampf progress)
{
    GLfloat startWeight, finishWeight, difference;
    Quaternion3D ret;
    
    difference = ((start->x * finish->x) + (start->y * finish->y) + (start->z * finish->z) + (start->w * finish->w));
    if ((1.f - fabs(difference)) > .01f) 
    {
        GLfloat theta, oneOverSinTheta;
        
        theta = acosf(fabsf(difference));
        oneOverSinTheta = (1.f / sinf(theta));
        startWeight = (sinf(theta * (1.f - progress)) * oneOverSinTheta);
        finishWeight = (sinf(theta * progress) * oneOverSinTheta);
        if (difference < 0.f) 
            startWeight = -startWeight;
    } else 
    {
        startWeight = (1.f - progress);
        finishWeight = progress;
    }
    ret.x = (start->x * startWeight) + (finish->x * finishWeight);
    ret.y = (start->y * startWeight) + (finish->y * finishWeight);
    ret.z = (start->z * startWeight) + (finish->z * finishWeight);
    ret.w = (start->w * startWeight) + (finish->w * finishWeight);
    Quaternion3DNormalize(&ret);
    
    return ret;
}

#pragma mark -
#pragma mark VertexTextureCombinations
#pragma mark -
// This implements a binary search tree that will help us determine which vertices need to be duplicated. In
// OpenGL, each vertex has to have one and only one set of texture coordinates, so if a single vertex is shared
// by multiple triangles and has different texture coordinates in each, those vertices need to be duplicated
// so that there is one copy of that vertex for every distinct set of texture coordinates.

// This works with index values, not actual Vertex3D values, for speed, and because that's the way the 
// OBJ file format tells us about them
//
// An actualVertex value of UINT_MAX means that the actual integer value hasn't been determined yet. 
typedef struct {
	GLuint	originalVertex;
	GLuint	textureCoords;
	GLuint	actualVertex;
	void	*greater;
	void	*lesser;
	
} VertexTextureIndex;
static inline VertexTextureIndex * VertexTextureIndexMake (GLuint inVertex, GLuint inTextureCoords, GLuint inActualVertex)
{
	VertexTextureIndex *ret = malloc(sizeof(VertexTextureIndex));
	ret->originalVertex = inVertex;
	ret->textureCoords = inTextureCoords;
	ret->actualVertex = inActualVertex;
	ret->greater = NULL;
	ret->lesser = NULL;
	return ret;
}
#define VertexTextureIndexMakeEmpty(x,y) VertexTextureIndexMake(x, y, UINT_MAX)
// recursive search function - looks for a match for a given combination of vertex and 
// texture coordinates. If not found, returns UINT_MAX
static inline GLuint VertexTextureIndexMatch(VertexTextureIndex *node, GLuint matchVertex, GLuint matchTextureCoords)
{
	if (node->originalVertex == matchVertex && node->textureCoords == matchTextureCoords)
		return node->actualVertex;
	
	if (node->greater != NULL)
	{
		GLuint greaterIndex = VertexTextureIndexMatch(node->greater, matchVertex, matchTextureCoords);
		if (greaterIndex != UINT_MAX)
			return greaterIndex;
	}
	
	if (node->lesser != NULL)
	{
		GLuint lesserIndex = VertexTextureIndexMatch(node->lesser, matchVertex, matchTextureCoords);
		return lesserIndex;
	}
	return UINT_MAX;
}
static inline VertexTextureIndex * VertexTextureIndexAddNode(VertexTextureIndex *node, GLuint newVertex, GLuint newTextureCoords)
{
	// If requested new node matches the one being added to, then don't add, just return pointer to match
	if (node->originalVertex == newVertex && node->textureCoords == newTextureCoords)
		return node;
	if (node->originalVertex > newVertex || (node->originalVertex == newVertex && node->textureCoords > newTextureCoords))
	{
		if (node->lesser != NULL)
			return VertexTextureIndexAddNode(node->lesser, newVertex, newTextureCoords);
		else
		{
			VertexTextureIndex *newNode = VertexTextureIndexMakeEmpty(newVertex, newTextureCoords);
			node->lesser = newNode;
			return node->lesser;
		}
	}
	else
	{
		if (node->greater != NULL)
			return VertexTextureIndexAddNode(node->greater, newVertex, newTextureCoords);
		else
		{
			VertexTextureIndex *newNode = VertexTextureIndexMakeEmpty(newVertex, newTextureCoords);
			node->greater = newNode;
			return node->greater;
		}	
	}
	return NULL; // shouldn't ever reach here.
}
static inline BOOL VertexTextureIndexContainsVertexIndex(VertexTextureIndex *node, GLuint matchVertex)
{
	if (node->originalVertex == matchVertex)
		return YES;
	
	BOOL greaterHas = NO;
	BOOL lesserHas = NO;
	
	if (node->greater != NULL)
		greaterHas = VertexTextureIndexContainsVertexIndex(node->greater, matchVertex);
	if (node->lesser != NULL)
		lesserHas = VertexTextureIndexContainsVertexIndex(node->lesser, matchVertex);
	return lesserHas || greaterHas;
}
static inline void VertexTextureIndexFree(VertexTextureIndex *node)
{
	if (node != NULL)
	{
		if (node->greater != NULL)
			VertexTextureIndexFree(node->greater);
		if (node->lesser != NULL)
			VertexTextureIndexFree(node->lesser);
		free(node);
	}
	
}
static inline GLuint VertexTextureIndexCountNodes(VertexTextureIndex *node)
{
	GLuint ret = 0;  
	
	if (node)
	{
		ret++; // count this node
		
		// Add the children
		if (node->greater != NULL)
			ret += VertexTextureIndexCountNodes(node->greater);
		if (node->lesser != NULL)
			ret += VertexTextureIndexCountNodes(node->lesser);
	}
	return ret;
}
#pragma mark -
#pragma mark Missing GLUT Functionality
// This is a modified version of the function of the same name from 
// the Mesa3D project ( http://mesa3d.org/ ), which is  licensed
// under the MIT license, which allows use, modification, and 
// redistribution
static inline void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez,
							 GLfloat centerx, GLfloat centery, GLfloat centerz,
							 GLfloat upx, GLfloat upy, GLfloat upz)
{
	GLfloat m[16];
	GLfloat x[3], y[3], z[3];
	GLfloat mag;
	
	/* Make rotation matrix */
	
	/* Z vector */
	z[0] = eyex - centerx;
	z[1] = eyey - centery;
	z[2] = eyez - centerz;
	mag = sqrtf(z[0] * z[0] + z[1] * z[1] + z[2] * z[2]);
	if (mag) {			/* mpichler, 19950515 */
		z[0] /= mag;
		z[1] /= mag;
		z[2] /= mag;
	}
	
	/* Y vector */
	y[0] = upx;
	y[1] = upy;
	y[2] = upz;
	
	/* X vector = Y cross Z */
	x[0] = y[1] * z[2] - y[2] * z[1];
	x[1] = -y[0] * z[2] + y[2] * z[0];
	x[2] = y[0] * z[1] - y[1] * z[0];
	
	/* Recompute Y = Z cross X */
	y[0] = z[1] * x[2] - z[2] * x[1];
	y[1] = -z[0] * x[2] + z[2] * x[0];
	y[2] = z[0] * x[1] - z[1] * x[0];
	
	/* mpichler, 19950515 */
	/* cross product gives area of parallelogram, which is < 1.0 for
	 * non-perpendicular unit-length vectors; so normalize x, y here
	 */
	
	mag = sqrtf(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]);
	if (mag) {
		x[0] /= mag;
		x[1] /= mag;
		x[2] /= mag;
	}
	
	mag = sqrtf(y[0] * y[0] + y[1] * y[1] + y[2] * y[2]);
	if (mag) {
		y[0] /= mag;
		y[1] /= mag;
		y[2] /= mag;
	}
	
#define M(row,col)  m[col*4+row]
	M(0, 0) = x[0];
	M(0, 1) = x[1];
	M(0, 2) = x[2];
	M(0, 3) = 0.0;
	M(1, 0) = y[0];
	M(1, 1) = y[1];
	M(1, 2) = y[2];
	M(1, 3) = 0.0;
	M(2, 0) = z[0];
	M(2, 1) = z[1];
	M(2, 2) = z[2];
	M(2, 3) = 0.0;
	M(3, 0) = 0.0;
	M(3, 1) = 0.0;
	M(3, 2) = 0.0;
	M(3, 3) = 1.0;
#undef M
	glMultMatrixf(m);
	
	/* Translate Eye to Origin */
	glTranslatef(-eyex, -eyey, -eyez);
	
}
#pragma mark -
#pragma mark Misc
static inline void billboardCurrentMatrix(void)
{
	float modelview[16];
	glGetFloatv(GL_MODELVIEW_MATRIX , modelview);
	
	
	for(int i=0; i<3; i++ ) 
	{	
		for(int j=0; j<3; j++ ) 
		{
			if ( i==j ) modelview[i*4+j] = 1.0;
            else modelview[i*4+j] = 0.0;
        }
	}
	glLoadMatrixf(modelview);
}
