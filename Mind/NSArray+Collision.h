//
//  NSArray+Collision.h
//  Mind
//
//  Created by Влад Нагирняк on 07.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType>(Collision)

- (void)collision: (void(^)(ObjectType first, ObjectType second))action;

@end
