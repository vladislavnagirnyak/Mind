//
//  NVTree.h
//  Mind
//
//  Created by Влад Нагирняк on 08.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVNode.h"

@interface NVTree : NSObject<NSCoding>

@property NVNode *root;

- (instancetype)initWithRoot:(NVNode*)root;

@end
