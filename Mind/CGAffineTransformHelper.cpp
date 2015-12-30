//
//  CGAffineTransformHelper.cpp
//  Mind
//
//  Created by Влад Нагирняк on 26.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#include "CGAffineTransformHelper.hpp"
#include <math.h>

CGAffineTransformHelper::CGAffineTransformHelper(CGAffineTransform transform) : CGAffineTransform(transform)
{
    
}

void CGAffineTransformHelper::set(CGPoint scale, CGFloat angle, CGPoint translation)
{
    a = scale.x * cos(angle);
    b = scale.y * sin(angle);
    c = scale.x * -sin(angle);
    d = scale.y * cos(angle);
    
    tx = translation.x;
    ty = translation.y;
}

void CGAffineTransformHelper::setScale(CGPoint scale)
{
    CGFloat angle = getRotation();
    
    set(scale, angle, getTranslation());
}

void CGAffineTransformHelper::setRotation(CGFloat angle)
{
    CGPoint scale = getScale();
    
    set(scale, angle, getTranslation());
}

void CGAffineTransformHelper::setTranslation(CGPoint translation)
{
    tx = translation.x;
    ty = translation.y;
}

CGPoint CGAffineTransformHelper::getScale()
{
    return CGPoint { sqrt(a * a + c * c), sqrt(b * b + d * d) };
}

CGFloat CGAffineTransformHelper::getRotation()
{
    return atan2f(b, a);
}

CGPoint CGAffineTransformHelper::getTranslation()
{
    return CGPoint { tx, ty };
}

CGFloat clip(CGFloat min, CGFloat max, CGFloat value)
{
    return value < min ? min : (value > max ? max : value);
}