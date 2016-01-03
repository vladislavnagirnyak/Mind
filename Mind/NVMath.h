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

struct NVCircle {
    CGPoint center;
    CGFloat radius;
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

#endif /* NVMath_h */
