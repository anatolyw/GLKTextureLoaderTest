// Vertex Shader

static const char* EmitterVS = STRINGIFY
(

// Attributes
attribute vec2      a_pPosition;

// Uniforms
uniform mat4        u_ProjectionMatrix;
uniform mat4        u_ModelViewMatrix;
uniform float       u_eSize;

void main(void)
{
    // Required OpenGL ES 2.0 outputs
    gl_Position = u_ProjectionMatrix * u_ModelViewMatrix * vec4(a_pPosition, 0.0, 1.0);
    gl_PointSize = u_eSize;
}

);