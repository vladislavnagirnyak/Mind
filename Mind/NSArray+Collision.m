//
//  NSArray+Collision.m
//  Mind
//
//  Created by Влад Нагирняк on 07.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#import "NSArray+Collision.h"

@implementation NSArray(Collision)

- (void)collision: (void(^)(id first, id second))action {
    if (self.count > 1)
    for (size_t i = 0; i < self.count - 1; i++) {
        for (size_t j = i + 1; j < self.count; j++) {
            action([self objectAtIndex:i], [self objectAtIndex:j]);
        }
    }
}

@end
