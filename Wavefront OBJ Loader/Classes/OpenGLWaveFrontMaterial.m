//
//  OpenGLWaveFrontMaterial.m
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/18/08.
//  Copyright 2008 Jeff LaMarche. All rights reserved.
//

#import "OpenGLWaveFrontMaterial.h"
#import "OpenGLTexture3D.h"

@implementation OpenGLWaveFrontMaterial
@synthesize name;
@synthesize diffuse;
@synthesize ambient;
@synthesize specular;
@synthesize shininess;
@synthesize texture;

+ (id)defaultMaterial
{
	return [[[OpenGLWaveFrontMaterial alloc] initWithName:@"default" 
												shininess:65.0 
												  diffuse:Color3DMake(0.8, 0.8, 0.8, 1.0) 
												  ambient:Color3DMake(0.2, 0.2, 0.2, 1.0) 
												 specular:Color3DMake(0.0, 0.0, 0.0, 1.0)] autorelease];
	
}
+ (id)materialsFromMtlFile:(NSString *)path
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	[ret setObject:[OpenGLWaveFrontMaterial defaultMaterial] forKey:@"default"];
	NSString *mtlData = [NSString stringWithContentsOfFile:path];
	NSArray *mtlLines = [mtlData componentsSeparatedByString:@"\n"];
	// Can't use fast enumeration here, need to manipulate line order
	for (int i = 0; i < [mtlLines count]; i++)
	{
		NSString *line = [mtlLines objectAtIndex:i];
		if ([line hasPrefix:@"newmtl"]) // Start of new material
		{
			// Determine start of next material
			int mtlEnd = -1;
			for (int j = i+1; j < [mtlLines count]; j++)
			{
				NSString *innerLine = [mtlLines objectAtIndex:j];
				if ([innerLine hasPrefix:@"newmtl"])
				{
					mtlEnd = j-1;
					
					break;
				}
					
			}
			if (mtlEnd == -1)
				mtlEnd = [mtlLines count]-1;
	
			
			OpenGLWaveFrontMaterial *material = [[OpenGLWaveFrontMaterial alloc] init];
			for (int j = i; j <= mtlEnd; j++)
			{
				NSString *parseLine = [mtlLines objectAtIndex:j];
				// ignore Ni, d, and illum, and texture - at least for now
				if ([parseLine hasPrefix:@"newmtl "])
					material.name = [parseLine substringFromIndex:7];
				else if ([parseLine hasPrefix:@"Ns "])
					material.shininess = [[parseLine substringFromIndex:3] floatValue];
				else if ([parseLine hasPrefix:@"Ka spectral"]) // Ignore, don't want consumed by next else
				{
					
				}
				else if ([parseLine hasPrefix:@"Ka "])  // CIEXYZ currently not supported, must be specified as RGB
				{
					NSArray *colorParts = [[parseLine substringFromIndex:3] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					material.ambient = Color3DMake([[colorParts objectAtIndex:0] floatValue], [[colorParts objectAtIndex:1] floatValue], [[colorParts objectAtIndex:2] floatValue], 1.0);
				}
				else if ([parseLine hasPrefix:@"Kd "])
				{
					NSArray *colorParts = [[parseLine substringFromIndex:3] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					material.diffuse =  Color3DMake([[colorParts objectAtIndex:0] floatValue], [[colorParts objectAtIndex:1] floatValue], [[colorParts objectAtIndex:2] floatValue], 1.0);
				}
				else if ([parseLine hasPrefix:@"Ks "])
				{
					NSArray *colorParts = [[parseLine substringFromIndex:3] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					material.specular =  Color3DMake([[colorParts objectAtIndex:0] floatValue], [[colorParts objectAtIndex:1] floatValue], [[colorParts objectAtIndex:2] floatValue], 1.0);
				}
				else if ([parseLine hasPrefix:@"map_Kd "])
				{
					glEnableClientState(GL_TEXTURE);
					NSString *texName = [parseLine substringFromIndex:7];
					NSString *baseName = [[texName componentsSeparatedByString:@"."] objectAtIndex:0];
					
					// Okay, since PVRT files are compressed and not supported by UIImage, we have to have a way
					// of knowing the size of the PVRT file beforehand. What we'll do is, when we create the PVRT
					// file, we'll incorporate the size into the filename, so texture1.jpg becomes texture1-512.pvr4
					// when converted to a PVRT file, assuming it's 512x512 pixes.
					NSString *textureFilename = nil;
					int width = 0, height = 0;
					for (int i=4; i <= 1028; i*=2)
					{
						
						NSString *newBase = [NSString stringWithFormat:@"%@-%d", baseName, i];
						NSString *path = [[NSBundle mainBundle] pathForResource:newBase ofType:@"pvr4"];
						if (path != nil)
						{
							textureFilename = [NSString stringWithFormat:@"%@.pvr4", newBase];
							width = i;
							height = i;
							break;
						}
						path =  [[NSBundle mainBundle] pathForResource:newBase ofType:@"pvr2"];
						if (path != nil)
						{
							textureFilename = [NSString stringWithFormat:@"%@.pvr4", newBase];
							width = i;
							height = i;
							break;
						}
						
					}
					// No PVRT file found use original file
					if (textureFilename == nil)
						textureFilename = texName;
					// TODO: Look for PVRT file
					OpenGLTexture3D *theTex = [[OpenGLTexture3D alloc] initWithFilename:textureFilename width:width height:height];
					material.texture = theTex;
					[theTex release];
				}
					
			}
			
			[ret setObject:material forKey:material.name];
			[material release];
			
			i = mtlEnd;
		}
	}
	return ret;
}

#pragma mark -
- (id)initWithName:(NSString *)inName shininess:(GLfloat)inShininess diffuse:(Color3D)inDiffuse ambient:(Color3D)inAmbient specular:(Color3D)inSpecular
{
	return [self initWithName:inName shininess:inShininess diffuse:inDiffuse ambient:inAmbient specular:inSpecular texture:nil];
}
- (id)initWithName:(NSString *)inName shininess:(GLfloat)inShininess diffuse:(Color3D)inDiffuse ambient:(Color3D)inAmbient specular:(Color3D)inSpecular texture:(OpenGLTexture3D *)inTexture
{
	if ((self = [super init]))
	{
		self.name = (inName == nil) ? @"default" : inName;
		self.diffuse = inDiffuse;
		self.ambient = inAmbient;
		self.specular = inSpecular;
		self.shininess = shininess;
		self.texture = inTexture;
	}
	return self;
}
#pragma mark -
- (NSString *)description
{
	return [NSString stringWithFormat:@"Material: %@ (Shininess: %f, Diffuse: {%f, %f, %f, %f}, Ambient: {%f, %f, %f, %f}, Specular: {%f, %f, %f, %f})", self.name, self.shininess, self.diffuse.red, self.diffuse.green, self.diffuse.blue, self.diffuse.alpha, self.ambient.red, self.ambient.green, self.ambient.blue, self.ambient.alpha, self.specular.red, self.specular.green, self.specular.blue, self.specular.alpha];
}
- (void)dealloc 
{
	[name release];
	[texture release];
	[super dealloc];
}
@end
