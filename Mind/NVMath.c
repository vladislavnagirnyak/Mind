//
//  NVMath.c
//  Mind
//
//  Created by Влад Нагирняк on 02.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#include "NVMath.h"

CGPoint VNormalize(CGPoint v) {
    CGFloat length = VLength(v);
    if (length) {
        length = 1.0 / length;
    }
    return VMulN(v, length);
}

CGPoint VRotate(CGPoint v, CGFloat angle) {
    return V(v.x * cos(angle) - v.y * sin(angle),
             v.y * cos(angle) + v.x * sin(angle));
}

CGFloat VAngle(CGPoint v1, CGPoint v2) {
    v1 = VNormalize(v1);
    v2 = VNormalize(v2);
    CGFloat cosine = VDot(v1, v2);
    
    return acos(cosine);
    //return cosine < 0 ? acos(-cosine) + M_PI_2 : acos(cosine);
}

CGFloat VDot(CGPoint v1, CGPoint v2) {
    return v1.x * v2.x + v1.y * v2.y;
}

CGFloat VLength(CGPoint v) {
    return sqrt(v.x * v.x + v.y * v.y);
}

CGPoint VAdd(CGPoint v1, CGPoint v2) {
    return V(v1.x + v2.x, v1.y + v2.y);
}

CGPoint VSub(CGPoint v1, CGPoint v2) {
    return V(v1.x - v2.x, v1.y - v2.y);
}

CGPoint VDiv(CGPoint v1, CGPoint v2) {
    return V(v1.x / v2.x, v1.y / v2.y);
}

CGPoint VMul(CGPoint v1, CGPoint v2) {
    return V(v1.x * v2.x, v1.y * v2.y);
}

CGPoint VMulN(CGPoint v1, CGFloat f) {
    return V(v1.x * f, v1.y * f);
}

CGPoint VDivN(CGPoint v1, CGFloat f) {
    return V(v1.x / f, v1.y / f);
}

CGPoint VNegate(CGPoint v) {
    return V(-v.x, -v.y);
}

NVCircle NVCircleMake(CGPoint center, CGFloat radius) {
    NVCircle circle;
    circle.center = center;
    circle.radius = radius;
    return circle;
}

NVRay NVRayMake(CGPoint position, CGPoint direction) {
    NVRay ray;
    ray.position = position;
    ray.direction = direction;
    return ray;
}

NVCoord NVCoordMake(long long x, long long y)
{
    NVCoord coord;
    coord.x = x;
    coord.y = y;
    return coord;
}

NVStraight NVStraightMakeFromRay(NVRay ray)
{
    NVStraight s;
    s.a = ray.direction.y;
    s.b = -ray.direction.x;
    s.c = -ray.position.x * ray.direction.y + ray.position.y * ray.direction.x;
    return s;
}

int isEqual(NVCoord c1, NVCoord c2)
{
    return c1.x == c2.x && c1.y == c2.y;
}

int inRange(NVCoord coord, NVCoord start, NVCoord end)
{
    NVCoord s = start, e = end;
    
    if (start.x < end.x) {
        s.x = start.x;
        e.x = end.x;
    } else {
        s.x = end.x;
        e.x = start.x;
    }
    
    if (start.y < end.y) {
        s.y = start.y;
        e.y = end.y;
    } else {
        s.y = end.y;
        e.y = start.y;
    }
    
    return coord.x >= s.x && coord.x <= e.x
        && coord.y >= s.y && coord.y <= e.y;
}

int IntersectCircleRay(NVCircle c, NVRay r, NVQuadCurve *curve)
{
    CGPoint dir = VSub(c.center, r.position);
    
    float beta = VAngle(r.direction, dir);
    float dirLength = VLength(dir);
    CGFloat lengthAlpha = dirLength * sin(beta); // / (sin(M_PI_2) == 1)
    
    if (lengthAlpha < c.radius &&
        VDot(dir, r.direction) > 0 &&
        dirLength - c.radius < VLength(r.direction)) {
        
        if (curve) {
            CGFloat lengthPartGamma = sqrt(c.radius * c.radius - lengthAlpha * lengthAlpha);
            CGFloat lengthGamma = dirLength * sin(M_PI_2 - beta);
        
            CGPoint normRayDir = VNormalize(r.direction);
        
            curve->start = VAdd(r.position, VMulN(normRayDir, lengthGamma - lengthPartGamma));
            curve->end = VAdd(r.position, VMulN(normRayDir, lengthGamma + lengthPartGamma));
            curve->control = VAdd(c.center, VMulN(VNormalize(VSub(VAdd(r.position, VMulN(normRayDir, lengthGamma)), c.center)), c.radius * 2 - lengthAlpha));
        }
        
        return 1;
    }
    
    return 0;
}

int IntersectCircleCircle(NVCircle c1, NVCircle c2)
{
    return VLength(VSub(c1.center, c2.center)) < c1.radius + c2.radius;
}

int IntersectCircleStraight(NVCircle cir, NVStraight s, CGPoint *p)
{
    double r = cir.radius, a = s.a, b = s.b, c = s.c;
    c = s.a * cir.center.x + s.b * cir.center.y + c;
    
    double x0 = -a*c/(a*a+b*b) + cir.center.x;
    double y0 = -b*c/(a*a+b*b) + cir.center.y;
    
    if (c*c > r*r*(a*a+b*b) + FLT_EPSILON) {
        return 0;
    }
    else if (fabs (c*c - r*r*(a*a+b*b)) < FLT_EPSILON) {
        *p = V(x0, y0);
        return 1;
    }
    else {
        double d = r*r - c*c/(a*a+b*b);
        double mult = sqrt (d / (a*a+b*b));
        double ax,ay,bx,by;
        ax = x0 + b * mult;
        bx = x0 - b * mult;
        ay = y0 - a * mult;
        by = y0 + a * mult;
        *p = V(ax, ay);
        *(p + 1) = V(bx, by);
        return 1;
    }
}

CGPoint NormalizedPos(CGPoint point, CGRect bounds)
{
    point = VSub(point, bounds.origin);
    point = VDiv(point, V(bounds.size.width, bounds.size.height));
    return point;
}

CGPoint UnnormalizedPos(CGPoint point, CGRect bounds)
{
    point = VMul(point, V(bounds.size.width, bounds.size.height));
    point = VAdd(point, bounds.origin);
    return point;
}