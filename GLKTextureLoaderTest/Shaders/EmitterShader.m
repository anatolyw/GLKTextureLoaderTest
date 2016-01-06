//
//  EmitterShader.m
//  GLParticles3
//
//  Created by RRC on 5/2/13.
//
//

#import "EmitterShader.h"
#import "ShaderProcessor.h"

// Shaders
#define STRINGIFY(A) #A
#include "Emitter.vsh"
#include "Emitter.fsh"

@implementation EmitterShader

- (void)loadShader
{
    // Program
    ShaderProcessor* shaderProcessor = [[ShaderProcessor alloc] init];
    self.program = [shaderProcessor BuildProgram:EmitterVS with:EmitterFS];
    
    // Attributes
    self.a_pPosition = glGetAttribLocation(self.program, "a_pPosition");
    
    // Uniforms
    self.u_Trancparency = glGetUniformLocation(self.program, "u_Trancparency");
    self.u_ProjectionMatrix = glGetUniformLocation(self.program, "u_ProjectionMatrix");
    self.u_ModelViewMatrix = glGetUniformLocation(self.program, "u_ModelViewMatrix");
    self.u_Texture = glGetUniformLocation(self.program, "u_Texture");
    self.u_eSize = glGetUniformLocation(self.program, "u_eSize");
    self.u_eColor = glGetUniformLocation(self.program, "u_eColor");
}

@end
