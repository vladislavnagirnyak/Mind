//
//  NVTreeNode.m
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import "NVTreeNode.h"

@implementation NVTreeNode

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _value = dictionary[@"body"];
        NSArray *children = dictionary[@"children"];
        
        if (children) {
            if ([children isKindOfClass:[NSArray class]]) {
                NSMutableArray *newChildren = [NSMutableArray arrayWithCapacity:children.count];
                for (id childDic in children) {
                    if ([childDic isKindOfClass:[NSDictionary class]]) {
                        NVTreeNode *newChild = [[NVTreeNode alloc] initWithDictionary:childDic];
                        if (newChild) {
                            newChild.parent = self;
                            [newChildren addObject:newChild];
                        } else {
                            [NSException raise:NSInternalInconsistencyException format:@"Child is nil!"];
                            return nil;
                        }
                    }
                }
                
                if (newChildren.count) {
                    _children = newChildren;
                }
            } else {
                [NSException raise:NSInternalInconsistencyException format:@"Children is not an array!"];
                return nil;
            }
        }
    }
    return self;
}

@end
