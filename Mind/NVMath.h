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

typedef struct {
    CGFloat a;
    CGFloat b;
    CGFloat c;
} NVStraight;

typedef struct {
    CGPoint start;
    CGPoint control;
    CGPoint end;
} NVQuadCurve;

typedef struct {
    CGPoint start;
    CGPoint controls[2];
    CGPoint end;
} NVCubicCurve;

typedef struct {
    long long x;
    long long y;
} NVCoord;

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
NVCoord NVCoordMake(long long x, long long y);
NVStraight NVStraightMakeFromRay(NVRay ray);

int isEqual(NVCoord c1, NVCoord c2);
int inRange(NVCoord coord, NVCoord start, NVCoord end);

int IntersectCircleRay(NVCircle c, NVRay r, NVQuadCurve *curve);
int IntersectCircleCircle(NVCircle c1, NVCircle c2);
int IntersectCircleStraight(NVCircle c, NVStraight s, CGPoint *p);

#endif /* NVMath_h */
