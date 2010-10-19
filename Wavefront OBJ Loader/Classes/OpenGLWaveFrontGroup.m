//
//  OpenGLWaveFrontGroup.m
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/18/08.
//  Copyright 2008 Jeff LaMarche. All rights reserved.
//

#import "OpenGLWaveFrontGroup.h"

@implementation OpenGLWaveFrontGroup
@synthesize name;
@synthesize numberOfFaces;
@synthesize faces;
@synthesize material;



- (id)initWithName:(NSString *)inName 
	 numberOfFaces:(GLuint)inNumFaces
		  material:(OpenGLWaveFrontMaterial *)inMaterial;

{
	if ((self = [super init]))
	{
		self.name = inName;
		self.numberOfFaces = inNumFaces;
		self.material = inMaterial;

		faces = malloc(sizeof(Face3D) * numberOfFaces);
		
	}
	return self;
}

- (void)dealloc
{
	[name release];
	if (faces)
		free(faces);
	[material release];
	[super dealloc];
}
@end
