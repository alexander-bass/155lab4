#version 430

layout (location = 0) in vec3 vertPos;
layout (location = 1) in vec2 texCoord;
layout (location = 2) in vec3 vertNormal;
layout (location = 3) in vec3 vertTan;
layout (location = 4) in vec3 vertBitan;

out vec2 tc;
out vec3 varyingNormal;
out vec3 varyingLightDir;
out vec3 varyingVertPos;
out vec3 varyingViewDir;
out vec3 varyingReflectVec;
out vec4 shadow_coord;
out mat3 TBN;

struct PositionalLight
{   vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    vec3 position;
};
struct Material
{   vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float shininess;
    float alpha;  // Added for transparency
};

uniform vec4 globalAmbient;
uniform PositionalLight light;
uniform Material material;
uniform mat4 m_matrix;
uniform mat4 v_matrix;
uniform mat4 p_matrix;
uniform mat4 norm_matrix;
uniform mat4 shadowMVP;
uniform int tileCount;

layout (binding = 0) uniform sampler2D samp;
layout (binding = 1) uniform sampler2DShadow shadowTex;
layout (binding = 2) uniform sampler2D normalMap;
// use the skybox texture for reflections
layout (binding = 3) uniform samplerCube skyboxTex;

void main(void) {
    vec4 worldPos = m_matrix * vec4(vertPos, 1.0);
    varyingVertPos = worldPos.xyz;
    varyingLightDir = light.position - varyingVertPos;
    varyingNormal = (norm_matrix * vec4(vertNormal, 1.0)).xyz;
    
    // Calculate view direction (for reflections)
    varyingViewDir = normalize(vec3(v_matrix[3][0], v_matrix[3][1], v_matrix[3][2]) - varyingVertPos);
    
    // Calculate reflection vector for environment mapping
    varyingReflectVec = reflect(-varyingViewDir, normalize(varyingNormal));
    
    // Calculate TBN matrix
    vec3 T = normalize((norm_matrix * vec4(vertTan, 0.0)).xyz);
    vec3 B = normalize((norm_matrix * vec4(vertBitan, 0.0)).xyz);
    vec3 N = normalize(varyingNormal);
    TBN = mat3(T, B, N);
    
    shadow_coord = shadowMVP * vec4(vertPos, 1.0);

    gl_Position = p_matrix * v_matrix * m_matrix * vec4(vertPos, 1.0);
    
    tc = texCoord * tileCount;
}