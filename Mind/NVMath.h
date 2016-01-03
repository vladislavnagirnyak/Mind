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

struct NVCircle {
    CGPoint center;
    CGFloat radius;
};

struct NVRay {
    CGPoint position;
    CGPoint direction;
};

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

struct NVCircle NVCircleMake(CGPoint center, CGFloat radius);
struct NVRay NVRayMake(CGPoint position, CGPoint direction);

int IntersectCircleRay(struct NVCircle circle, struct NVRay ray);
int IntersectCircleCircle(struct NVCircle circle1, struct NVCircle circle2);

#endif /* NVMath_h */
