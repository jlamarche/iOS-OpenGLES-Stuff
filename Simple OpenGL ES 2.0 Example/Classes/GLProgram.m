#import "GLProgram.h"

#pragma mark Function Pointer Definitions
typedef void (*GLInfoFunction)(GLuint program, 
                               GLenum pname, 
                               GLint* params);
typedef void (*GLLogFunction) (GLuint program, 
                               GLsizei bufsize, 
                               GLsizei* length, 
                               GLchar* infolog);
#pragma mark -
#pragma mark Private Extension Method Declaration
@interface GLProgram()
{
    NSMutableArray  *attributes;
    GLuint          program,
    vertShader, 
    fragShader;
}
- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
                 file:(NSString *)file;
- (NSString *)logForOpenGLObject:(GLuint)object 
                    infoCallback:(GLInfoFunction)infoFunc 
                         logFunc:(GLLogFunction)logFunc;
@end
#pragma mark -

@implementation GLProgram
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename 
            fragmentShaderFilename:(NSString *)fShaderFilename
{
    if (self = [super init])
    {
        attributes = [[NSMutableArray alloc] init];
        NSString *vertShaderPathname, *fragShaderPathname;
        program = glCreateProgram();
        
        vertShaderPathname = [[NSBundle mainBundle] 
                              pathForResource:vShaderFilename 
                              ofType:@"vsh"];
        if (![self compileShader:&vertShader 
                            type:GL_VERTEX_SHADER 
                            file:vertShaderPathname])
            NSLog(@"Failed to compile vertex shader");
        
        fragShaderPathname = [[NSBundle mainBundle] 
                              pathForResource:fShaderFilename 
                              ofType:@"fsh"];
        if (![self compileShader:&fragShader 
                            type:GL_FRAGMENT_SHADER 
                            file:fragShaderPathname])
            NSLog(@"Failed to compile fragment shader");
        
        glAttachShader(program, vertShader);
        glAttachShader(program, fragShader);
    }
    
    return self;
}
- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
                 file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = 
    (GLchar *)[[NSString stringWithContentsOfFile:file 
                                         encoding:NSUTF8StringEncoding 
                                            error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    return status == GL_TRUE;
}
#pragma mark -
- (void)addAttribute:(NSString *)attributeName
{
    if (![attributes containsObject:attributeName])
    {
        [attributes addObject:attributeName];
        glBindAttribLocation(program, 
                             [attributes indexOfObject:attributeName], 
                             [attributeName UTF8String]);
    }
}
- (GLuint)attributeIndex:(NSString *)attributeName
{
    return [attributes indexOfObject:attributeName];
}
- (GLuint)uniformIndex:(NSString *)uniformName
{
    return glGetUniformLocation(program, [uniformName UTF8String]);
}
#pragma mark -
- (BOOL)link
{
    GLint status;
    
    glLinkProgram(program);
    glValidateProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
        return NO;
    
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return YES;
}
- (void)use
{
    glUseProgram(program);
}
#pragma mark -
- (NSString *)logForOpenGLObject:(GLuint)object 
                    infoCallback:(GLInfoFunction)infoFunc 
                         logFunc:(GLLogFunction)logFunc
{
    GLint logLength = 0, charsWritten = 0;
    
    infoFunc(object, GL_INFO_LOG_LENGTH, &logLength);    
    if (logLength < 1)
        return nil;
    
    char *logBytes = malloc(logLength);
    logFunc(object, logLength, &charsWritten, logBytes);
    NSString *log = [[[NSString alloc] initWithBytes:logBytes 
                                              length:logLength 
                                            encoding:NSUTF8StringEncoding] 
                     autorelease];
    free(logBytes);
    return log;
}
- (NSString *)vertexShaderLog
{
    return [self logForOpenGLObject:vertShader 
                       infoCallback:(GLInfoFunction)&glGetShaderiv 
                            logFunc:(GLLogFunction)&glGetShaderInfoLog];
    
}
- (NSString *)fragmentShaderLog
{
    return [self logForOpenGLObject:fragShader 
                       infoCallback:(GLInfoFunction)&glGetShaderiv 
                            logFunc:(GLLogFunction)&glGetShaderInfoLog];
}
- (NSString *)programLog
{
    return [self logForOpenGLObject:program 
                       infoCallback:(GLInfoFunction)&glGetProgramiv 
                            logFunc:(GLLogFunction)&glGetProgramInfoLog];
}
#pragma mark -
- (void)dealloc
{
    [attributes release];
    
    if (vertShader)
        glDeleteShader(vertShader);
    
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (program)
        glDeleteProgram(program);
    
    [super dealloc];
}
@end
