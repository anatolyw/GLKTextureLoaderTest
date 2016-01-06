// Fragment Shader

static const char* EmitterFS = STRINGIFY
(

// Uniforms
uniform highp float     u_Trancparency;
uniform sampler2D       u_Texture;
uniform highp vec3      u_eColor;

void main(void)
{
    highp vec4 texture = texture2D(u_Texture, gl_PointCoord);
    highp vec4 color = vec4(1.0);
    
    // Calculate color with offset
    color.rgb = u_eColor;
    color.rgb = clamp(color.rgb, vec3(0.0), vec3(1.0));
    
    color.a = u_Trancparency;
    
    // Required OpenGL ES 2.0 outputs
    gl_FragColor = texture * color;
}

);