//
//  NVMath.h
//  Mind
//
//  Created by Влад Нагирняк on 02.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#ifndef NVMath_h
#define NVMath_h

#include <QuartzCore/QuartzCore.h>

#define V(x, y) CGPointMake((x), (y))
#define R(p, d) NVRayMake((p), (d))
#define C(c, r) NVCircleMake((c), (r))

typedef struct {
    CGPoint center;
    CGFloat radius;
} NVCircle;

typedef struct {
    CGPoint position;
    CGPoint direction;
} NVRay;

CGPoint VNormalize(CGPoint v);
CGPoint VRotate(CGPoint v, CGFloat angle);
CGFloat VAngle(CGPoint v1, CGPoint v2);
CGFloat VDot(CGPoint v1, CGPoint v2);
CGFloat VLength(CGPoint v);
CGPoint VAdd(CGPoint v1, CGPoint v2);
CGPoint VSub(CGPoint v1, CGPoint v2);
CGPoint VDiv(CGPoint v1, CGPoint v2);
CGPoint VMul(CGPoint v1, CGPoint v2);
CGPoint VNegate(CGPoint v);

CGPoint VMulN(CGPoint v1, CGFloat f);
CGPoint VDivN(CGPoint v1, CGFloat f);

NVCircle NVCircleMake(CGPoint center, CGFloat radius);
NVRay NVRayMake(CGPoint position, CGPoint direction);

int IntersectCircleRay(NVCircle circle, NVRay ray);
int IntersectCircleCircle(NVCircle circle1, NVCircle circle2);

#endif /* NVMath_h */
