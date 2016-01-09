//
//  NVTree.m
//  Mind
//
//  Created by Влад Нагирняк on 08.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#import "NVTree.h"

@implementation NVTree

- (instancetype)initWithRoot:(NVNode *)root {
    self = [super init];
    if (self) {
        _root = root;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self encodeWithCoder:aCoder withNode:_root ];
}

- (void)encodeWithCoder:(NSCoder*)aCoder withNode:(NVNode*)node {
    size_t x = 0;
    //size_t parentX = 0;
    
    NVNode *parent = node.parent;
    
    if (parent) {
        x = [parent.children indexOfObject:node];
        
        //if (parent.parent)
          //  parentX = [parent.parent.children indexOfObject:parent];
    }
    
    NSString *key = [NSString stringWithFormat:@"%zu-%zu", x, node.level];
    
    //[aCoder encodeObject:@{@"x" : @(parentX), @"y" : @(node.level - 1)} forKey:[key stringByAppendingString:@"-parent"]];
    [aCoder encodeObject:node.value forKey:[key stringByAppendingString:@"-value"]];
    [aCoder encodeObject:@(node.children.count) forKey:[key stringByAppendingString:@"-count"]];
    
    for (NVNode *item in node.children) {
        [self encodeWithCoder:aCoder withNode:item];
    }
}

- (NVNode*)createWithCoder:(NSCoder *)aDecoder withParent:(NVNode*)parent offset:(size_t)offset{
    NVNode *node = [[NVNode alloc] init];
    
    node.level = parent ? parent.level + 1 : 0;
    node.parent = parent;
    
    NSString *key = [NSString stringWithFormat:@"%zu-%zu", offset, node.level];

    node.value = [aDecoder decodeObjectForKey:[key stringByAppendingString: @"-value"]];
    size_t childrenCount = [[aDecoder decodeObjectForKey:[key stringByAppendingString: @"-count"]] unsignedLongLongValue];
    
    for (size_t i = 0; i < childrenCount; i++) {
        [node addChild:[self createWithCoder:aDecoder withParent:node offset:i]];
    }
    
    return node;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _root = [self createWithCoder:aDecoder withParent:nil offset:0];
    }
    return self;
}

@end
