#include "../../sample.glsl"

/*
original_author: Patricio Gonzalez Vivo
description: two dimension Gaussian Blur to be applied in only one passes
use: gaussianBlur2D(<sampler2D> texture, <vec2> st, <vec2> pixel_direction , const int kernelSize)
options:
    - SAMPLER_FNC(TEX, UV): optional depending the target version of GLSL (texture2D(...) or texture(...))
    - GAUSSIANBLUR2D_TYPE: Default `vec4`
    - GAUSSIANBLUR2D_SAMPLER_FNC(POS_UV): Default `texture2D(tex, POS_UV)`
    - GAUSSIANBLUR2D_KERNELSIZE: Use only for WebGL 1.0 and OpenGL ES 2.0 . For example RaspberryPis is not happy with dynamic loops. Default is 'kernelSize'
*/

#ifndef GAUSSIANBLUR2D_TYPE
#ifdef GAUSSIANBLUR_TYPE
#define GAUSSIANBLUR2D_TYPE GAUSSIANBLUR_TYPE
#else
#define GAUSSIANBLUR2D_TYPE vec4
#endif
#endif

#ifndef GAUSSIANBLUR2D_SAMPLER_FNC
#ifdef GAUSSIANBLUR_SAMPLER_FNC
#define GAUSSIANBLUR2D_SAMPLER_FNC(POS_UV) GAUSSIANBLUR_SAMPLER_FNC(POS_UV)
#else
#define GAUSSIANBLUR2D_SAMPLER_FNC(POS_UV) SAMPLER_FNC(tex, POS_UV)
#endif
#endif

#ifndef FNC_GAUSSIANBLUR2D
#define FNC_GAUSSIANBLUR2D
GAUSSIANBLUR2D_TYPE gaussianBlur2D(in sampler2D tex, in vec2 st, in vec2 offset, const int kernelSize) {
    GAUSSIANBLUR2D_TYPE accumColor = GAUSSIANBLUR2D_TYPE(0.);
    
    #ifndef GAUSSIANBLUR2D_KERNELSIZE
    
    #if defined(PLATFORM_WEBGL)
    #define GAUSSIANBLUR2D_KERNELSIZE 20
    float kernelSizef = float(kernelSize);
    #else
    #define GAUSSIANBLUR2D_KERNELSIZE kernelSize
    float kernelSizef = float(GAUSSIANBLUR2D_KERNELSIZE);
    #endif

    #else
    float kernelSizef = float(GAUSSIANBLUR2D_KERNELSIZE);
    #endif

    float accumWeight = 0.;
    const float k = .15915494; // 1 / (2*PI)
    float kernelSize2 = kernelSizef * kernelSizef;

    for (int j = 0; j < GAUSSIANBLUR2D_KERNELSIZE; j++) {
        #if defined(PLATFORM_WEBGL)
        if (j >= kernelSize)
            break;
        #endif
        float y = -.5 * (kernelSizef - 1.) + float(j);
        for (int i = 0; i < GAUSSIANBLUR2D_KERNELSIZE; i++) {
            #if defined(PLATFORM_WEBGL)
            if (i >= kernelSize)
                break;
            #endif
            float x = -.5 * (kernelSizef - 1.) + float(i);
            float weight = (k / kernelSizef) * exp(-(x * x + y * y) / (2. * kernelSize2));
            accumColor += weight * GAUSSIANBLUR2D_SAMPLER_FNC(st + vec2(x, y) * offset);
            accumWeight += weight;
        }
    }
    return accumColor / accumWeight;
}
#endif
