//
//  RLEmmiterBrush.m
//  GLKTextureLoaderTest
//
//  Created by Anatoly Weinstein on 06/01/16.
//  Copyright © 2016 Anatoly Weinstein. All rights reserved.
//

#import "RLEmmiterBrush.h"

#import "EmitterShader.h"
#import "RLToolSettings.h"

typedef struct Particles
{
    GLKVector2  pPosition;
} Particles;

typedef struct Emitter
{
    Particles*  eParticles;
    GLsizei  eCount;
} Emitter;

@interface RLEmmiterBrush ()

@property (assign) Emitter emitter;
@property (strong) EmitterShader* shader;

@end

@implementation RLEmmiterBrush
{
    // Instance variables
    GLuint      _particleBuffer;
    GLuint      _texture;
    GLKMatrix4  _projectionMatrix;
}

#pragma mark - Clean

- (void)cleanEmitter {
    if (self.emitter.eParticles) {
        free(self.emitter.eParticles);
    }
}

- (void)dealloc {
    NSLog(@"RLEmmiterBrush:dealloc");
    [self cleanEmitter];
}

#pragma mark - Math Helpers

- (float)randomFloatBetween:(float)min and:(float)max {
    float range = max - min;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * range) + min;
}

#pragma mark - Load Helpers

- (void)loadShader {
    self.shader = [[EmitterShader alloc] init];
    [self.shader loadShader];
    glUseProgram(self.shader.program);
    glUseProgram(0);
}

- (void)loadTexture {
    
    NSLog(@"loadTexture = '%@'", [RLToolSettings shared].brushPath);
    
    if(nil == [RLToolSettings shared].brushPath) {
        NSLog(@"Error: brushPath is nill");
        return;
    }
    
    NSMutableDictionary *options = [@{ GLKTextureLoaderOriginBottomLeft : @NO} mutableCopy];
    if ([RLToolSettings shared].applyPremultiplication) {
        options[GLKTextureLoaderApplyPremultiplication] = @YES;
    }
    
    NSError* error;
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:[RLToolSettings shared].brushPath options:options error:&error];
    if(texture == nil) {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
        
        NSString* defaultBrush = [[NSBundle mainBundle] pathForResource:@"brushSoft.png" ofType:nil];
        NSError* error2;
        texture = [GLKTextureLoader textureWithContentsOfFile:defaultBrush options:options error:&error2];
        if(texture == nil) {
            NSLog(@"Error loading default brush: %@", [error2 localizedDescription]);
        }
    }
    
    _texture = texture.name;
    glBindTexture(GL_TEXTURE_2D, _texture);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)loadLineEmitterFromPoint:(CGPoint)start toPoint:(CGPoint)end {
    
    [self cleanEmitter];
    
    float brushStep = [RLToolSettings shared].brushStep;
    
    Emitter newEmitter = {0};
    newEmitter.eCount = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / brushStep), 1);
    newEmitter.eParticles = malloc(newEmitter.eCount * sizeof(Particles));
	for(NSUInteger i = 0; i < newEmitter.eCount; ++i) {
        // Assign a position
		newEmitter.eParticles[i].pPosition = GLKVector2Make(start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)newEmitter.eCount),
                                                            start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)newEmitter.eCount));
	}
    
    // Set Emitter & VBO
    self.emitter = newEmitter;
    glGenBuffers(1, &_particleBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _particleBuffer);
    // glBufferData (GLenum target, GLsizeiptr size, const GLvoid *data, GLenum usage)
    // glBufferData cause leaks,
    // see explanation here: http://stackoverflow.com/questions/12715046/memory-usage-keeps-increasing-over-time-glkit-ios
    // there is a call to glDeleteBuffers in renderWithModelViewMatrix method to fix leak
    glBufferData(GL_ARRAY_BUFFER, sizeof(Particles)*self.emitter.eCount, self.emitter.eParticles, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

#pragma mark - Public Interface

- (id)initWithProjectionMatrix:(GLKMatrix4)projectionMatrix {
    if((self = [super init]))
    {
        _particleBuffer = 0;
        _texture = 0;
        _projectionMatrix = projectionMatrix;
        
        [self loadShader];
        [self loadTexture];
    }
    return self;
}

- (void)renderWithModelViewMatrix:(GLKMatrix4)modelViewMatrix fromPoint:(CGPoint)start toPoint:(CGPoint)end {
    
    [self loadLineEmitterFromPoint:start toPoint:end];

    // "Set"
    glUseProgram(self.shader.program);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glBindBuffer(GL_ARRAY_BUFFER, _particleBuffer);

    float brushSize = [RLToolSettings shared].brushSize;
    float transparency = [RLToolSettings shared].transparency;
    
    // Uniforms
    glUniform1i(self.shader.u_Texture, 0);
    glUniformMatrix4fv(self.shader.u_ProjectionMatrix, 1, 0, _projectionMatrix.m);
    glUniformMatrix4fv(self.shader.u_ModelViewMatrix, 1, 0, modelViewMatrix.m);
    glUniform1f(self.shader.u_eSize, brushSize);

    glUniform1f(self.shader.u_Trancparency, transparency);
    glUniform3f(self.shader.u_eColor,
                [RLToolSettings shared].color.r * transparency,
                [RLToolSettings shared].color.g * transparency,
                [RLToolSettings shared].color.b * transparency);

    // Attributes
    glEnableVertexAttribArray(self.shader.a_pPosition);
    glVertexAttribPointer(self.shader.a_pPosition,    2, GL_FLOAT, GL_FALSE, sizeof(Particles), (void*)(offsetof(Particles, pPosition)));
    
    // Draw particles
    glDrawArrays(GL_POINTS, 0, self.emitter.eCount);
    glDisableVertexAttribArray(self.shader.a_pPosition);
    
    // "Reset"
    glUseProgram(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDeleteBuffers(1, &_particleBuffer);
}

@end
