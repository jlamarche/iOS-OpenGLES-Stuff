//
//  OpenGLWaveFrontObject.m
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright 2008 Jeff LaMarche. All rights reserved.
//
// This file will load certain .obj files into memory and display them in OpenGL ES.
// Because of limitations of OpenGL ES, not all .obj files can be loaded - faces larger
// than triangles cannot be handled, so files must be exported with only triangles.


#import "OpenGLWaveFrontObject.h"
#import "ConstantsAndMacros.h"
#import "OpenGLWaveFrontGroup.h"
#import "OpenGLWaveFrontMaterial.h"
#import "OpenGLTexture3D.h"

static inline void	processOneVertex(VertexTextureIndex *rootNode, GLuint vertexIndex, GLuint vertexTextureIndex, GLuint *vertexCount, Vertex3D	*vertices, GLfloat  *allTextureCoords, GLfloat *textureCoords, GLuint componentsPerTextureCoord, GLushort *faceVertexIndex)
{
	//NSLog(@"Processing Vertex: %d, Texture Index: %d", vertexIndex, vertexTextureIndex);
	BOOL alreadyExists = VertexTextureIndexContainsVertexIndex(rootNode, vertexIndex);
	VertexTextureIndex *vertexNode = VertexTextureIndexAddNode(rootNode, vertexIndex, vertexTextureIndex);
	if (vertexNode->actualVertex == UINT_MAX)
	{
		if (!alreadyExists || rootNode == vertexNode)
		{
			
			vertexNode->actualVertex = vertexNode->originalVertex;
			
			// Wavefront's texture coord order is flip-flopped from what OpenGL expects
			for (int i = 0; i < componentsPerTextureCoord; i++)
				textureCoords[(vertexNode->actualVertex * componentsPerTextureCoord) + i] = allTextureCoords[(vertexNode->textureCoords * componentsPerTextureCoord) + componentsPerTextureCoord - (i+1)] ;
			
		}
		else
		{
			vertices[*vertexCount].x = vertices[vertexNode->originalVertex].x;
			vertices[*vertexCount].y = vertices[vertexNode->originalVertex].y;
			vertices[*vertexCount].z = vertices[vertexNode->originalVertex].z;
			vertexNode->actualVertex = *vertexCount;
			
			for (int i = 0; i < componentsPerTextureCoord; i++)
				textureCoords[(vertexNode->actualVertex * componentsPerTextureCoord) + i] = allTextureCoords[(vertexNode->textureCoords * componentsPerTextureCoord) + componentsPerTextureCoord - (i+1)];
			*vertexCount = *vertexCount + 1;
		}
	}
	*faceVertexIndex = vertexNode->actualVertex;
}

@interface OpenGLWaveFrontObject (private)
- (void)calculateNormals;
@end

@implementation OpenGLWaveFrontObject
@synthesize sourceObjFilePath;
@synthesize sourceMtlFilePath;
@synthesize currentPosition;
@synthesize currentRotation;
@synthesize materials;
@synthesize groups;
- (id)initWithPath:(NSString *)path
{
	
	if ((self = [super init]))
	{
		self.groups = [NSMutableArray array];
		
		self.sourceObjFilePath = path;
		NSString *objData = [NSString stringWithContentsOfFile:path];
		NSUInteger vertexCount = 0, faceCount = 0, textureCoordsCount=0, groupCount = 0;
		// Iterate through file once to discover how many vertices, normals, and faces there are
		NSArray *lines = [objData componentsSeparatedByString:@"\n"];
		BOOL firstTextureCoords = YES;
		NSMutableArray *vertexCombinations = [[NSMutableArray alloc] init];
		for (NSString * line in lines)
		{
			if ([line hasPrefix:@"v "])
				vertexCount++;
			else if ([line hasPrefix:@"vt "])
			{
				textureCoordsCount++;
				if (firstTextureCoords)
				{
					firstTextureCoords = NO;
					NSString *texLine = [line substringFromIndex:3];
					NSArray *texParts = [texLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					valuesPerCoord = [texParts count];
				}
			}
			else if ([line hasPrefix:@"m"])
			{
				NSString *truncLine = [line substringFromIndex:7];
				self.sourceMtlFilePath = truncLine;
				NSString *mtlPath = [[NSBundle mainBundle] pathForResource:[[truncLine lastPathComponent] stringByDeletingPathExtension] ofType:[truncLine pathExtension]];
				self.materials = [OpenGLWaveFrontMaterial materialsFromMtlFile:mtlPath];
			}
			else if ([line hasPrefix:@"g"])
				groupCount++;
			else if ([line hasPrefix:@"f"])
			{
				faceCount++;
				NSString *faceLine = [line substringFromIndex:2];
				NSArray *faces = [faceLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				for (NSString *oneFace in faces)
				{
					NSArray *faceParts = [oneFace componentsSeparatedByString:@"/"];
					
					NSString *faceKey = [NSString stringWithFormat:@"%@/%@", [faceParts objectAtIndex:0], ([faceParts count] > 1) ? [faceParts objectAtIndex:1] : 0];
					if (![vertexCombinations containsObject:faceKey])
						[vertexCombinations addObject:faceKey];
				}
			}
			
		}
		vertices = malloc(sizeof(Vertex3D) *  [vertexCombinations count]);
		GLfloat *allTextureCoords = malloc(sizeof(GLfloat) *  textureCoordsCount * valuesPerCoord);
		textureCoords = (textureCoordsCount > 0) ?  malloc(sizeof(GLfloat) * valuesPerCoord * [vertexCombinations count]) : NULL;
		// Store the counts
		numberOfFaces = faceCount;
		numberOfVertices = [vertexCombinations count];
		GLuint allTextureCoordsCount = 0;
		textureCoordsCount = 0;
		GLuint groupFaceCount = 0;
		GLuint groupCoordCount = 0;
		// Reuse our count variables for second time through
		vertexCount = 0;
		faceCount = 0;
		OpenGLWaveFrontGroup *currentGroup = nil;
		NSUInteger lineNum = 0;
		BOOL usingGroups = YES;
		
		VertexTextureIndex *rootNode = nil;
		for (NSString * line in lines)
		{
			if ([line hasPrefix:@"v "])
			{
				NSString *lineTrunc = [line substringFromIndex:2];
				NSArray *lineVertices = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				vertices[vertexCount].x = [[lineVertices objectAtIndex:0] floatValue];
				vertices[vertexCount].y = [[lineVertices objectAtIndex:1] floatValue];
				vertices[vertexCount].z = [[lineVertices objectAtIndex:2] floatValue];
				// Ignore weight if it exists..
				vertexCount++;
			}
			else if ([line hasPrefix: @"vt "])
			{
				NSString *lineTrunc = [line substringFromIndex:3];
				NSArray *lineCoords = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				//int coordCount = 1;
				for (NSString *oneCoord in lineCoords)
				{
//					if (valuesPerCoord == 2 /* using UV Mapping */ && coordCount++ == 1 /* is U value */)
//						allTextureCoords[allTextureCoordsCount] = CONVERT_UV_U_TO_ST_S([oneCoord floatValue]);
//					else
						allTextureCoords[allTextureCoordsCount] = [oneCoord floatValue];
					//NSLog(@"Setting allTextureCoords[%d] to %f", allTextureCoordsCount, [oneCoord floatValue]);
					allTextureCoordsCount++;
				}
				
				// Ignore weight if it exists..
				textureCoordsCount++;
			}
			else if ([line hasPrefix:@"g "])
			{
				NSString *groupName = [line substringFromIndex:2];
				NSUInteger counter = lineNum+1;
				NSUInteger currentGroupFaceCount = 0;
				NSString *materialName = nil;
				while (counter < [lines count])
				{
					NSString *nextLine = [lines objectAtIndex:counter++];
					if ([nextLine hasPrefix:@"usemtl "])
						materialName = [nextLine substringFromIndex:7];
					else if ([nextLine hasPrefix:@"f "])
					{
						// TODO: Loook for quads and double-increment
						currentGroupFaceCount ++;
					}
					else if ([nextLine hasPrefix:@"g "])
						break;
				}
				
				OpenGLWaveFrontMaterial *material = [materials objectForKey:materialName] ;
				if (material == nil)
					material = [OpenGLWaveFrontMaterial defaultMaterial];
				
				currentGroup = [[OpenGLWaveFrontGroup alloc] initWithName:groupName
															numberOfFaces:currentGroupFaceCount 
																 material:material];
				[groups addObject:currentGroup];
				[currentGroup release];
				groupFaceCount = 0;
				groupCoordCount = 0;
			}
			else if ([line hasPrefix:@"usemtl "])
			{
				NSString *materialKey = [line substringFromIndex:7];
				currentGroup.material = [materials objectForKey:materialKey];
			}
			else if ([line hasPrefix:@"f "])
			{
				NSString *lineTrunc = [line substringFromIndex:2];
				NSArray *faceIndexGroups = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				
				// If no groups in file, create one group that has all the vertices and uses the default material
				if (currentGroup == nil)
				{
					OpenGLWaveFrontMaterial *tempMaterial = nil;
					NSArray *materialKeys = [materials allKeys];
					if ([materialKeys count] == 2)
					{
						// 2 means there's one in file, plus default
						for (NSString *key in materialKeys)
							if (![key isEqualToString:@"default"])
								tempMaterial = [materials objectForKey:key];
					}
					if (tempMaterial == nil)
						tempMaterial = [OpenGLWaveFrontMaterial defaultMaterial];
					
					currentGroup = [[OpenGLWaveFrontGroup alloc] initWithName:@"default"
																numberOfFaces:numberOfFaces 
																	 material:tempMaterial];
					[groups addObject:currentGroup];
					[currentGroup release];
					usingGroups = NO;
				}
				
				// TODO: Look for quads and build two triangles
				
				NSArray *vertex1Parts = [[faceIndexGroups objectAtIndex:0] componentsSeparatedByString:@"/"];
				GLuint vertex1Index = [[vertex1Parts objectAtIndex:kGroupIndexVertex] intValue]-1;
				GLuint vertex1TextureIndex = 0;
				if ([vertex1Parts count] > 1)
					vertex1TextureIndex = [[vertex1Parts objectAtIndex:kGroupIndexTextureCoordIndex] intValue]-1;
				if (rootNode == NULL)
					rootNode =  VertexTextureIndexMake(vertex1Index, vertex1TextureIndex, UINT_MAX);
				
				processOneVertex(rootNode, vertex1Index, vertex1TextureIndex, &vertexCount, vertices, allTextureCoords, textureCoords, valuesPerCoord, &(currentGroup.faces[groupFaceCount].v1));
				NSArray *vertex2Parts = [[faceIndexGroups objectAtIndex:1] componentsSeparatedByString:@"/"];
				processOneVertex(rootNode, [[vertex2Parts objectAtIndex:kGroupIndexVertex] intValue]-1, [vertex2Parts count] > 1 ? [[vertex2Parts objectAtIndex:kGroupIndexTextureCoordIndex] intValue]-1 : 0, &vertexCount, vertices, allTextureCoords, textureCoords, valuesPerCoord, &currentGroup.faces[groupFaceCount].v2);	
				NSArray *vertex3Parts = [[faceIndexGroups objectAtIndex:2] componentsSeparatedByString:@"/"];
				processOneVertex(rootNode, [[vertex3Parts objectAtIndex:kGroupIndexVertex] intValue]-1, [vertex3Parts count] > 1 ? [[vertex3Parts objectAtIndex:kGroupIndexTextureCoordIndex] intValue]-1 : 0, &vertexCount, vertices, allTextureCoords, textureCoords, valuesPerCoord, &currentGroup.faces[groupFaceCount].v3);
				
				faceCount++;
				groupFaceCount++;
			}
			lineNum++;
			
		}
		//NSLog(@"Final vertex count: %d", vertexCount);
		
		[self calculateNormals];
		if (allTextureCoords)
			free(allTextureCoords);
		[vertexCombinations release];
		VertexTextureIndexFree(rootNode);
	}
	return self;
}

- (void)drawSelf
{
	// Save the current transformation by pushing it on the stack
	glPushMatrix();
	
	// Load the identity matrix to restore to origin
	glLoadIdentity();
	
	// Translate to the current position
	glTranslatef(currentPosition.x, currentPosition.y, currentPosition.z);
	
	// Rotate to the current rotation
	glRotatef(currentRotation.x, 1.0, 0.0, 0.0);
	glRotatef(currentRotation.y, 0.0, 1.0, 0.0);
	glRotatef(currentPosition.z, 0.0, 0.0, 1.0);
	
	// Enable and load the vertex array
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, vertices); 
	glNormalPointer(GL_FLOAT, 0, vertexNormals);
	// Loop through each group
	
	if (textureCoords != NULL)
	{
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glTexCoordPointer(valuesPerCoord, GL_FLOAT, 0, textureCoords);
	}
	for (OpenGLWaveFrontGroup *group in groups)
	{
		if (textureCoords != NULL && group.material.texture != nil)
			[group.material.texture bind];
		// Set color and materials based on group's material
		Color3D ambient = group.material.ambient;
		glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, (const GLfloat *)&ambient);
		
		Color3D diffuse = group.material.diffuse;
		glColor4f(diffuse.red, diffuse.green, diffuse.blue, diffuse.alpha);
		glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE,  (const GLfloat *)&diffuse);
		
		Color3D specular = group.material.specular;
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, (const GLfloat *)&specular);
		
		glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, group.material.shininess);
		
		glDrawElements(GL_TRIANGLES, 3*group.numberOfFaces, GL_UNSIGNED_SHORT, &(group.faces[0]));
	}
	if (textureCoords != NULL)
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	// Restore the current transformation by popping it off
	glPopMatrix();
}

- (void)calculateNormals
{
	if (surfaceNormals)
		free(surfaceNormals);	
	
	// Calculate surface normals and keep running sum of vertex normals
	surfaceNormals = calloc(numberOfFaces, sizeof(Vector3D));
	vertexNormals = calloc(numberOfVertices, sizeof(Vector3D));
	NSUInteger index = 0;
	NSUInteger *facesUsedIn = calloc(numberOfVertices, sizeof(NSUInteger)); // Keeps track of how many triangles any given vertex is used in
	for (int i = 0; i < [groups count]; i++)
	{
		OpenGLWaveFrontGroup *oneGroup = [groups objectAtIndex:i];
		for (int j = 0; j < oneGroup.numberOfFaces; j++)
		{
			Triangle3D triangle = Triangle3DMake(vertices[oneGroup.faces[j].v1], vertices[oneGroup.faces[j].v2], vertices[oneGroup.faces[j].v3]);
			
			surfaceNormals[index] = Triangle3DCalculateSurfaceNormal(triangle);
#ifdef USE_FAST_NORMALIZE
			Vector3DFastNormalize(&surfaceNormals[index]);
#else
			Vector3DNormalize(&surfaceNormals[index]);
#endif
			vertexNormals[oneGroup.faces[j].v1] = Vector3DAdd(surfaceNormals[index], vertexNormals[oneGroup.faces[j].v1]);
			vertexNormals[oneGroup.faces[j].v2] = Vector3DAdd(surfaceNormals[index], vertexNormals[oneGroup.faces[j].v2]);
			vertexNormals[oneGroup.faces[j].v3] = Vector3DAdd(surfaceNormals[index], vertexNormals[oneGroup.faces[j].v3]);
			
			facesUsedIn[oneGroup.faces[j].v1]++;
			facesUsedIn[oneGroup.faces[j].v2]++;
			facesUsedIn[oneGroup.faces[j].v3]++;
			
			
			index++;
		}
	}
	
	// Loop through vertices again, dividing those that are used in multiple faces by the number of faces they are used in
	for (int i = 0; i < numberOfVertices; i++)
	{
		if (facesUsedIn[i] > 1)
		{
			vertexNormals[i].x /= facesUsedIn[i];
			vertexNormals[i].y /= facesUsedIn[i];
			vertexNormals[i].z /= facesUsedIn[i];
		}
#ifdef USE_FAST_NORMALIZE
		Vector3DFastNormalize(&vertexNormals[i]);
#else
		Vector3DNormalize(&vertexNormals[i]);
#endif
	}
	free(facesUsedIn);
}
- (void)dealloc
{
	[materials release];
	[groups release];
	[sourceObjFilePath release];
	[sourceMtlFilePath release];
	if (vertices)
		free(vertices);
	if (surfaceNormals)
		free(surfaceNormals);
	if (vertexNormals)
		free(vertexNormals);
	if (textureCoords)
		free(textureCoords);
	[super dealloc];
}
@end
