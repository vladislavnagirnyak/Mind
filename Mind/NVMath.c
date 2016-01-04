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

int IntersectCircleRay(NVCircle circle, NVRay ray) {
    CGPoint dir = VSub(circle.center, ray.position);
    
    float beta = VAngle(ray.direction, dir);
    float dirLength = VLength(dir);
    CGFloat lengthAlpha = dirLength * sin(beta); // / (sin(M_PI_2) == 1)
    
    if (lengthAlpha < circle.radius &&
        VDot(dir, ray.direction) > 0 &&
        dirLength - circle.radius < VLength(ray.direction)) {
        return 1;
    }
    
    return 0;
}

int IntersectCircleCircle(NVCircle circle1, NVCircle circle2) {
    return VLength(VSub(circle1.center, circle2.center)) < circle1.radius + circle2.radius;
}