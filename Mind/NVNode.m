//
//  NVTreeNode.m
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import "NVNode.h"

@interface NVNode() {
    NSMutableArray<NVNode*>* _children;
}

@end

@implementation NVNode

@synthesize children = _children;

- (instancetype)init {
    self = [super init];
    if (self) {
        _children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withParent:(NVNode*)parent {
    self = [self init];
    if (self) {
        _value = dictionary[@"body"];
        NSArray *children = dictionary[@"children"];
        
        if (parent) {
            self.level = parent.level + 1;
            self.parent = parent;
        }
        
        if (children) {
            if ([children isKindOfClass:[NSArray class]]) {
                for (id childDic in children) {
                    if ([childDic isKindOfClass:[NSDictionary class]]) {
                        NVNode *newChild = [[NVNode alloc] initWithDictionary:childDic withParent:self];
                        if (newChild) {
                            [_children addObject:newChild];
                        } else {
                            [NSException raise:NSInternalInconsistencyException format:@"Child is nil!"];
                            return nil;
                        }
                    }
                }
            } else {
                [NSException raise:NSInternalInconsistencyException format:@"Children is not an array!"];
                return nil;
            }
        }
    }
    return self;
}

- (NVNode*)findRoot {
    NVNode *root = self.parent;
    while (root.parent) {
        root = root.parent;
    }
    return root;
}

- (void)addChild: (NVNode*)child {
    [_children addObject:child];
    child.parent = self;
    child.level = self.level + 1;
}

- (void)removeChild: (NVNode*)child {
    for (NVNode *item in child.children) {
        [child removeChild:item];
    }
    
    [_children removeObject:child];
}

- (void)collision:(NVNodeBlock)action {

}

@end