#import "GLViewController.h"
#import "GLProgram.h"
#import "GLView.h"
#import "GLCommon.h"
#import "GLTexture.h"

// START:extension
@interface GLViewController ()
{
    GLuint      positionAttribute;
    GLuint      textureCoordinateAttribute;
    GLuint      matrixUniform;
    GLuint      textureUniform;
    
    Matrix3D    rotationMatrix;
    Matrix3D    translationMatrix;
    Matrix3D    modelViewMatrix;
    Matrix3D    projectionMatrix;
    Matrix3D    matrix;
    
    
}
@end
// END:extension

@implementation GLViewController
@synthesize program, texture;
// START:setup
- (void)setup
{
    GLProgram *theProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"Shader"
                                                     fragmentShaderFilename:@"Shader"];
    self.program = theProgram;
    [theProgram release];
    
    [self.program addAttribute:@"position"];
    [self.program addAttribute:@"textureCoordinates"];
    
    if (![self.program link])
    {
        NSLog(@"Link failed");
        
        NSString *progLog = [self.program programLog];
        NSLog(@"Program Log: %@", progLog); 
        
        NSString *fragLog = [self.program fragmentShaderLog];
        NSLog(@"Frag Log: %@", fragLog);
        
        NSString *vertLog = [self.program vertexShaderLog];
        NSLog(@"Vert Log: %@", vertLog);
        
        [(GLView *)self.view stopAnimation];
        self.program = nil;
    }
    
    positionAttribute = [program attributeIndex:@"position"];
    textureCoordinateAttribute = [program attributeIndex:@"textureCoordinates"];
    matrixUniform = [program uniformIndex:@"matrix"];
    textureUniform = [program uniformIndex:@"texture"];

    glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ZERO);
    
    GLTexture *theTexture = [[GLTexture alloc] initWithFilename:@"DieTexture.png"];
    self.texture = theTexture;
    [theTexture release];
    
}
// END:setup
// START:draw
- (void)draw
{
    static const Vertex3D vertices[] = 
    {
        {-0.276385, -0.850640, -0.447215},
        {0.000000, 0.000000, -1.000000},  
        {0.723600, -0.525720, -0.447215}, 
        {0.723600, -0.525720, -0.447215}, 
        {0.000000, 0.000000, -1.000000},  
        {0.723600, 0.525720, -0.447215},  
        {-0.894425, 0.000000, -0.447215}, 
        {0.000000, 0.000000, -1.000000},  
        {-0.276385, -0.850640, -0.447215},
        {-0.276385, 0.850640, -0.447215}, 
        {0.000000, 0.000000, -1.000000},  
        {-0.894425, 0.000000, -0.447215}, 
        {0.723600, 0.525720, -0.447215},  
        {0.000000, 0.000000, -1.000000},  
        {-0.276385, 0.850640, -0.447215}, 
        {0.723600, -0.525720, -0.447215}, 
        {0.723600, 0.525720, -0.447215},  
        {0.894425, 0.000000, 0.447215}, 	 
        {-0.276385, -0.850640, -0.447215},
        {0.723600, -0.525720, -0.447215}, 
        {0.276385, -0.850640, 0.447215},  
        {-0.894425, 0.000000, -0.447215}, 
        {-0.276385, -0.850640, -0.447215},
        {-0.723600, -0.525720, 0.447215}, 
        {-0.276385, 0.850640, -0.447215}, 
        {-0.894425, 0.000000, -0.447215}, 
        {-0.723600, 0.525720, 0.447215},  
        {0.723600, 0.525720, -0.447215},  
        {-0.276385, 0.850640, -0.447215}, 
        {0.276385, 0.850640, 0.447215}, 	 
        {0.894425, 0.000000, 0.447215}, 	 
        {0.276385, -0.850640, 0.447215},  
        {0.723600, -0.525720, -0.447215}, 
        {0.276385, -0.850640, 0.447215},  
        {-0.723600, -0.525720, 0.447215}, 
        {-0.276385, -0.850640, -0.447215},
        {-0.723600, -0.525720, 0.447215}, 
        {-0.723600, 0.525720, 0.447215},  
        {-0.894425, 0.000000, -0.447215}, 
        {-0.723600, 0.525720, 0.447215},  
        {0.276385, 0.850640, 0.447215}, 	 
        {-0.276385, 0.850640, -0.447215}, 
        {0.276385, 0.850640, 0.447215}, 	 
        {0.894425, 0.000000, 0.447215}, 	 
        {0.723600, 0.525720, -0.447215},  
        {0.276385, -0.850640, 0.447215},  
        {0.894425, 0.000000, 0.447215}, 	 
        {0.000000, 0.000000, 1.000000}, 	 
        {-0.723600, -0.525720, 0.447215}, 
        {0.276385, -0.850640, 0.447215},  
        {0.000000, 0.000000, 1.000000}, 	 
        {-0.723600, 0.525720, 0.447215},  
        {-0.723600, -0.525720, 0.447215}, 
        {0.000000, 0.000000, 1.000000}, 	 
        {0.276385, 0.850640, 0.447215}, 	 
        {-0.723600, 0.525720, 0.447215},  
        {0.000000, 0.000000, 1.000000}, 	 
        {0.894425, 0.000000, 0.447215}, 	 
        {0.276385, 0.850640, 0.447215}, 	 
        {0.000000, 0.000000, 1.000000}, 
    };
    static const TextureCoord textureCoordinates[] = 
    {
        {0.648752, 0.445995},
        {0.914415, 0.532311},
        {0.722181, 0.671980},
        {0.722181, 0.671980},
        {0.914415, 0.532311},
        {0.914415, 0.811645},
        {0.254949, 0.204901},
        {0.254949, 0.442518},
        {0.028963, 0.278329},
        {0.480936, 0.278329},
        {0.254949, 0.442518},
        {0.254949, 0.204901},
        {0.838115, 0.247091},
        {0.713611, 0.462739},
        {0.589108, 0.247091},
        {0.722181, 0.671980},
        {0.914415, 0.811645},
        {0.648752, 0.897968},
        {0.648752, 0.445995},
        {0.722181, 0.671980},
        {0.484562, 0.671981},
        {0.254949, 0.204901},
        {0.028963, 0.278329},
        {0.115283, 0.012663},
        {0.480936, 0.278329},
        {0.254949, 0.204901},
        {0.394615, 0.012663},
        {0.838115, 0.247091},
        {0.589108, 0.247091},
        {0.713609, 0.031441},
        {0.648752, 0.897968},
        {0.484562, 0.671981},
        {0.722181, 0.671980},
        {0.644386, 0.947134},
        {0.396380, 0.969437},
        {0.501069, 0.743502},
        {0.115283, 0.012663},
        {0.394615, 0.012663},
        {0.254949, 0.204901},
        {0.464602, 0.031442},
        {0.713609, 0.031441},
        {0.589108, 0.247091},
        {0.713609, 0.031441},
        {0.962618, 0.031441},
        {0.838115, 0.247091},
        {0.028963, 0.613069},
        {0.254949, 0.448877},
        {0.254949, 0.686495},
        {0.115283, 0.878730},
        {0.028963, 0.613069},
        {0.254949, 0.686495},
        {0.394615, 0.878730},
        {0.115283, 0.878730},
        {0.254949, 0.686495},
        {0.480935, 0.613069},
        {0.394615, 0.878730},
        {0.254949, 0.686495},
        {0.254949, 0.448877},
        {0.480935, 0.613069},
        {0.254949, 0.686495},
    };
    
    static GLfloat  rot = 0.0f;
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.program use];
        
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(positionAttribute);
    
    glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glEnableVertexAttribArray(textureCoordinateAttribute);
    
    static const Vector3D rotationVector = {1.f, 1.f, 1.f};
    Matrix3DSetRotationByDegrees(rotationMatrix, rot, rotationVector);
    Matrix3DSetTranslation(translationMatrix, 0.f, 0.f, -3.f);
    Matrix3DMultiply(translationMatrix, rotationMatrix, modelViewMatrix);

    Matrix3DSetPerspectiveProjectionWithFieldOfView(projectionMatrix, 45.f, 
                                                 0.1f, 100.f, 
                                                 self.view.frame.size.width / 
                                                 self.view.frame.size.height);
    
    
    Matrix3DMultiply(projectionMatrix, modelViewMatrix, matrix);
    glUniformMatrix4fv(matrixUniform, 1, FALSE, matrix);
    
    glActiveTexture (GL_TEXTURE0);
    [texture use];
    glUniform1i (textureUniform, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices) / sizeof(Vertex3D));
    

    
    rot += 2.f;
    if (rot > 360.f)
        rot -= 360.f;
}
// END:draw
#pragma mark -
- (void)viewDidUnload 
{
    [super viewDidUnload];
}
- (void)dealloc 
{
    [program release], program = nil;
    [super dealloc];
}
@end
