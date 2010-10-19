//
//  OpenGLWaveFrontMaterial.h
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/18/08.
//  Copyright 2008 Jeff LaMarche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "OpengLWaveFrontCommon.h"
@class OpenGLTexture3D;

@interface OpenGLWaveFrontMaterial : NSObject 
{
	NSString			*name;
	Color3D				diffuse;
	Color3D				ambient;
	Color3D				specular;
	GLfloat				shininess;
	OpenGLTexture3D		*texture;
}
@property (nonatomic, retain) NSString *name;
@property Color3D diffuse;
@property Color3D ambient;
@property Color3D specular;
@property GLfloat shininess;
@property (nonatomic, retain) OpenGLTexture3D *texture;
+ (id)defaultMaterial;
+ (id)materialsFromMtlFile:(NSString *)path;
- (id)initWithName:(NSString *)inName shininess:(GLfloat)inShininess diffuse:(Color3D)inDiffuse ambient:(Color3D)inAmbient specular:(Color3D)inSpecular;
- (id)initWithName:(NSString *)inName shininess:(GLfloat)inShininess diffuse:(Color3D)inDiffuse ambient:(Color3D)inAmbient specular:(Color3D)inSpecular texture:(OpenGLTexture3D *)inTexture;
@end
