//
//  GLViewController.h
//  Part6Project
//
//  Created by jeff on 4/30/09.
//  Copyright Jeff LaMarche 2009. All rights reserved.
//

#import "GLViewController.h"
#import "GLView.h"
#import "OpenGLCommon.h"
#import "ConstantsAndMacros.h"


@implementation GLViewController
- (void)drawView:(GLView*)view;
{
    
    static GLfloat  rot = 0.0;
    
    // This is the same result as using Vertex3D, just faster to type and
    // can be made const this way
    
    static const ColoredVertexData3D vertexData[] = {
        {
            {0, -0.525731, 0.850651},           // Vertex |
            {0.000000, -0.417775, 0.675974},    // Normal | Vertex 0
            {1.0, 0.0, 0.0, 1.0}                // Color  |
        },
        {
            {0.850651, 0, 0.525731},            // Vertex |
            {0.675973, 0.000000, 0.417775},     // Normal | Vertex 1
            {1.0, 0.5, 0.0, 1.0}                // Color  |
        },
        {
            {0.850651, 0, -0.525731},           // Vertex |
            {0.675973, -0.000000, -0.417775},   // Normal | Vertex 2
            {1.0, 1.0, 0.0, 1.0}                // Color  |
        },
        {
            {-0.850651, 0, -0.525731},          // Vertex |
            {-0.675973, 0.000000, -0.417775},   // Normal | Vertex 3
            {0.5, 1.0, 0.0, 1.0}                // Color  |
        },
        {
            {-0.850651, 0, 0.525731},           // Vertex |
            {-0.675973, -0.000000, 0.417775},   // Normal | Vertex 4
            {0.0, 1.0, 0.0, 1.0}                // Color  |
        },
        {
            {-0.525731, 0.850651, 0},           // Vertex |
            {-0.417775, 0.675974, 0.000000},    // Normal | Vertex 5
            {0.0, 1.0, 0.5, 1.0}                // Color  | 
        },
        {
            {0.525731, 0.850651, 0},            // Vertex |
            {0.417775, 0.675973, -0.000000},    // Normal | Vertex 6
            {0.0, 1.0, 1.0, 1.0}                // Color  |
        },
        {
            {0.525731, -0.850651, 0},           // Vertex |
            {0.417775, -0.675974, 0.000000},    // Normal | Vertex 7
            {0.0, 0.5, 1.0, 1.0}                // Color  | 
        },
        {
            {-0.525731, -0.850651, 0},          // Vertex |
            {-0.417775, -0.675974, 0.000000},   // Normal | Vertex 8
            {0.0, 0.0, 1.0, 1.0},               // Color  |
        }, 
        {
            {0, -0.525731, -0.850651},          // Vertex |
            {0.000000, -0.417775, -0.675973},   // Normal | Vertex 9
            {0.5, 0.0, 1.0, 1.0}                // Color  |
        },
        {
            {0, 0.525731, -0.850651},           // Vertex |
            {0.000000, 0.417775, -0.675974},    // Normal | Vertex 10
            {1.0, 0.0, 1.0, 1.0}                // Color  |
        },
        {
            {0, 0.525731, 0.850651},            // Vertex |
            {0.000000, 0.417775, 0.675973},     // Normal | Vertex 11
            {1.0, 0.0, 0.5, 1.0}                // Color  |
        }
    };
    static const GLubyte icosahedronFaces[] = {
        1, 2, 6,
        1, 7, 2,
        3, 4, 5,
        4, 3, 8,
        6, 5, 11,
        5, 6, 10,
        9, 10, 2,
        10, 9, 3,
        7, 8, 9,
        8, 7, 0,
        11, 0, 1,
        0, 11, 4,
        6, 2, 10,
        1, 6, 11,
        3, 5, 10,
        5, 4, 11,
        2, 7, 9,
        7, 1, 0,
        3, 9, 8,
        4, 8, 0,
    };
    static Matrix3D    translateMatrix;
    Matrix3DSetTranslation(translateMatrix, 0.0, 0.0, -3.0);
    static Matrix3D    rotationMatrix;
    Matrix3DSetRotationByDegrees(rotationMatrix, rot, 1.0f, 1.0f, 1.0f);    
    static Matrix3D    finalMatrix;
    Matrix3DMultiply(translateMatrix, rotationMatrix, finalMatrix);
    glLoadMatrixf(finalMatrix);
    
    glClearColor(0.0, 0.0, 0.05, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnable(GL_COLOR_MATERIAL);
    glEnableClientState(GL_NORMAL_ARRAY);
    
    glVertexPointer(3, GL_FLOAT, sizeof(ColoredVertexData3D), &vertexData[0].vertex);
    glColorPointer(4, GL_FLOAT, sizeof(ColoredVertexData3D), &vertexData[0].color);
    glNormalPointer(GL_FLOAT, sizeof(ColoredVertexData3D), &vertexData[0].normal);
    glDrawElements(GL_TRIANGLES, 60, GL_UNSIGNED_BYTE, icosahedronFaces);

    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisable(GL_COLOR_MATERIAL);
    static NSTimeInterval lastDrawTime;
    if (lastDrawTime)
    {
        NSTimeInterval timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastDrawTime;
        rot+=50 * timeSinceLastDraw;  
    }
    lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
}
-(void)setupView:(GLView*)view
{
	const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0; 
	GLfloat size; 
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION); 
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0); 
	CGRect rect = view.bounds; 
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / 
			   (rect.size.width / rect.size.height), zNear, zFar); 
	glViewport(0, 0, rect.size.width, rect.size.height);  
	glMatrixMode(GL_MODELVIEW);
    
    // Enable lighting
    glEnable(GL_LIGHTING);
    
    // Turn the first light on
    glEnable(GL_LIGHT0);
    
    // Define the ambient component of the first light
    static const Color3D light0Ambient[] = {{0.3, 0.3, 0.3, 1.0}};
	glLightfv(GL_LIGHT0, GL_AMBIENT, (const GLfloat *)light0Ambient);
    
    // Define the diffuse component of the first light
    static const Color3D light0Diffuse[] = {{0.4, 0.4, 0.4, 1.0}};
	glLightfv(GL_LIGHT0, GL_DIFFUSE, (const GLfloat *)light0Diffuse);
    
    // Define the specular component and shininess of the first light
    static const Color3D light0Specular[] = {{0.7, 0.7, 0.7, 1.0}};
    glLightfv(GL_LIGHT0, GL_SPECULAR, (const GLfloat *)light0Specular);
    
    // Define the position of the first light
    // const GLfloat light0Position[] = {10.0, 10.0, 10.0}; 
    static const Vertex3D light0Position[] = {{10.0, 10.0, 10.0}};
	glLightfv(GL_LIGHT0, GL_POSITION, (const GLfloat *)light0Position); 
	
    // Calculate light vector so it points at the object
    static const Vertex3D objectPoint[] = {{0.0, 0.0, -3.0}};
    const Vertex3D lightVector = Vector3DMakeWithStartAndEndPoints(light0Position[0], objectPoint[0]);
    glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, (GLfloat *)&lightVector);
    
    // Define a cutoff angle. This defines a 90° field of vision, since the cutoff
    // is number of degrees to each side of an imaginary line drawn from the light's
    // position along the vector supplied in GL_SPOT_DIRECTION above
    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 25.0);
    
	glLoadIdentity(); 
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f); 
}
@end
