//
//  CGAffineTransformHelper.hpp
//  Mind
//
//  Created by Влад Нагирняк on 26.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#ifndef CGAffineTransformHelper_hpp
#define CGAffineTransformHelper_hpp

#include <CoreGraphics/CoreGraphics.h>

class CGAffineTransformHelper : public CGAffineTransform
{
public:
    CGAffineTransformHelper(CGAffineTransform transform);
    
    void setScale(CGPoint scale);
    void setRotation(CGFloat angle);
    void setTranslation(CGPoint translation);
    void set(CGPoint scale, CGFloat angle, CGPoint translation);
    
    CGPoint getScale();
    CGFloat getRotation();
    CGPoint getTranslation();
};

CGFloat clip(CGFloat min, CGFloat max, CGFloat value);

#endif /* CGAffineTransformHelper_hpp */
