#include "../specular.glsl"
#include "../diffuse.glsl"
#include "falloff.glsl"

/*
original_author: Patricio Gonzalez Vivo
description: calculate directional light
use: lightDirectional(<vec3> _diffuseColor, <vec3> _specularColor, <vec3> _N, <vec3> _V, <float> _NoV, <float> _f0, out <vec3> _diffuse, out <vec3> _specular)
options:
    - DIFFUSE_FNC: diffuseOrenNayar, diffuseBurley, diffuseLambert (default)
    - LIGHT_POSITION: in GlslViewer is u_light
    - LIGHT_DIRECTION
    - LIGHT_COLOR: in GlslViewer is u_lightColor
    - LIGHT_INTENSITY: in GlslViewer is u_lightIntensity
*/

#ifndef LIGHT_POSITION
#define LIGHT_POSITION vec3(0.0, 10.0, -50.0)
#endif

#ifndef LIGHT_COLOR
#define LIGHT_COLOR vec3(0.5)
#endif

#ifndef LIGHT_INTENSITY
#define LIGHT_INTENSITY 1.0
#endif

#ifndef FNC_LIGHT_DIRECTIONAL
#define FNC_LIGHT_DIRECTIONAL

void lightDirectional(vec3 _diffuseColor, vec3 _specularColor, vec3 _N, vec3 _V, float _NoV, float _roughness, float _f0, float _shadow, inout vec3 _diffuse, inout vec3 _specular) {
    #ifdef LIGHT_DIRECTION
    vec3 s = normalize(LIGHT_DIRECTION);
    #else 
    vec3 s = normalize(LIGHT_POSITION);
    #endif
    float NoL = dot(_N, s);
    float dif = diffuseOrenNayar(s, _N, _V, _NoV, NoL, _roughness);
    float spec = specularCookTorrance(s, _N, _V, _NoV, NoL, _roughness, _f0);
    _diffuse  += max(vec3(0.0), LIGHT_INTENSITY * (_diffuseColor * LIGHT_COLOR * dif) * _shadow);
    _specular += max(vec3(0.0), LIGHT_INTENSITY * (_specularColor * LIGHT_COLOR * spec) * _shadow);
}


// void lightDirectional(float3 _diffuseColor, float3 _specularColor, float3 _N, float3 _V, float _NoV, float _roughness, float _f0, inout float3 _diffuse, inout float3 _specular) {
//     return lightDirectional(_diffuseColor, _specularColor, _N, _V, _NoV, _roughness, _f0, 1.0, _diffuse, _specular);
// }


#endif