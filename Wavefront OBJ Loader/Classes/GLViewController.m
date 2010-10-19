//
//  GLViewController.h
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright Jeff LaMarche 2008. All rights reserved.
//

#import "GLViewController.h"
#import "GLView.h"

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
@implementation GLViewController
@synthesize plane;
@synthesize cylinder;
@synthesize cube;
@synthesize sphere;
- (void)drawView:(GLView*)view;
{
	static GLfloat rotation = 0.0;
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity(); 
	glColor4f(0.0, 0.5, 1.0, 1.0);
	[plane drawSelf];
	
	if (cube)
		[cube drawSelf];
	
	if (cylinder)
		[cylinder drawSelf];
	
	if (sphere)
		[sphere drawSelf];
		
	static NSTimeInterval lastDrawTime;
	if (lastDrawTime)
	{
		NSTimeInterval timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastDrawTime;
		rotation+=50 * timeSinceLastDraw;				
		Rotation3D rot;
		rot.x = rotation;
		rot.y = rotation;
		rot.z = rotation;
		plane.currentRotation = rot;
		cylinder.currentRotation = rot;
		cube.currentRotation = rot;
		sphere.currentRotation = rot;
	}
	lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
}

-(void)setupView:(GLView*)view
{		
	const GLfloat			lightAmbient[] = {0.2, 0.2, 0.2, 1.0};
	const GLfloat			lightDiffuse[] = {1.0, 1.0, 1.0, 1.0};
	
	const GLfloat			lightPosition[] = {5.0, 5.0, 15.0, 0.0}; 
	const GLfloat			light2Position[] = {-5.0, -5.0, 15.0, 0.0};
	const GLfloat			lightShininess = 0.0;
	const GLfloat			zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0; 
	GLfloat size; 
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
	
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0); 
	CGRect rect = view.bounds; 
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / 
			   (rect.size.width / rect.size.height), zNear, zFar); 
	glViewport(0, 0, rect.size.width, rect.size.height);  
	glMatrixMode(GL_MODELVIEW);
	glShadeModel(GL_SMOOTH); 
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition); 
	glLightfv(GL_LIGHT0, GL_SHININESS, &lightShininess);
	
	glEnable(GL_LIGHT1);
	glLightfv(GL_LIGHT1, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT2, GL_DIFFUSE, lightDiffuse);
	glLightfv(GL_LIGHT2, GL_POSITION, light2Position); 
	glLightfv(GL_LIGHT2, GL_SHININESS, &lightShininess);
	
	glLoadIdentity(); 
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f); 	
	
	
	glGetError(); // Clear error codes
	
	NSTimeInterval planeStart = [NSDate timeIntervalSinceReferenceDate];
	NSLog(@"Beggining Load of Plane at %f",  planeStart);
	NSString *path = [[NSBundle mainBundle] pathForResource:@"plane3" ofType:@"obj"];
	OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
	Vertex3D position = Vertex3DMake(0.0, 3.0, -8.0);
	theObject.currentPosition = position;
	self.plane = theObject;
	[theObject release];
	NSTimeInterval planeEnd = [NSDate timeIntervalSinceReferenceDate];
	NSLog(@"End Load of Plane at %f", planeEnd);
	NSLog(@"Duration: %f", planeEnd - planeStart);
	path = [[NSBundle mainBundle] pathForResource:@"texturedcube" ofType:@"obj"];
	theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
	position = Vertex3DMake(-1.5, -3.0, -8.0);
	theObject.currentPosition = position;
	self.cube = theObject;
	[theObject release];	
	
	path = [[NSBundle mainBundle] pathForResource:@"uvcube2" ofType:@"obj"];
	theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
	position.z = -8.0;
	position.y = -0.3;
	position.x = 1.5;
	theObject.currentPosition = position;
	self.cylinder = theObject;
	[theObject release];
	
	path = [[NSBundle mainBundle] pathForResource:@"earth" ofType:@"obj"];
	theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
	position.z = -8.0;
	position.y = -3.0;
	position.x = 2.0;
	theObject.currentPosition = position;
	self.sphere = theObject;
	[theObject release];
	

	
}
- (void)didReceiveMemoryWarning 
{
	
    [super didReceiveMemoryWarning]; 
}

- (void)dealloc 
{
	[plane release];
	[cylinder release];
	[cube release];
	[sphere release];
    [super dealloc];
}

@end
