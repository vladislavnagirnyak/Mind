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
    /*size_t offset = node.parent ? [node.parent.children indexOfObject:node] : 0;
    
    NSString *key = [NSString stringWithFormat:@"%zu-%zu", offset, node.level];
    
    [aCoder encodeObject:node.value forKey:[key stringByAppendingString:@"-value"]];
    [aCoder encodeCGPoint:node.position forKey:[key stringByAppendingString:@"-position"]];
    [aCoder encodeObject:@(node.children.count) forKey:[key stringByAppendingString:@"-count"]];*/
    
    [aCoder encodeObject:node.value];
    [aCoder encodeObject:[NSValue valueWithCGPoint:node.position]];
    [aCoder encodeObject:@(node.children.count)];
    
    for (NVNode *item in node.children) {
        [self encodeWithCoder:aCoder withNode:item];
    }
}

- (NVNode*)createWithCoder:(NSCoder *)aDecoder withParent:(NVNode*)parent offset:(size_t)offset{
    NVNode *node = [[NVNode alloc] initWithParent:parent];
    
    /*NSString *key = [NSString stringWithFormat:@"%zu-%zu", offset, node.level];

    node.value = [aDecoder decodeObjectForKey:[key stringByAppendingString: @"-value"]];
    node.position = [[aDecoder decodeObjectForKey:[key stringByAppendingString: @"-position"]]CGPointValue];
    size_t childrenCount = [[aDecoder decodeObjectForKey:[key stringByAppendingString: @"-count"]] unsignedLongLongValue];*/
    
    node.value = [aDecoder decodeObject];
    node.position = [[aDecoder decodeObject] CGPointValue];
    size_t childrenCount = [[aDecoder decodeObject] unsignedLongLongValue];
    
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

- (void)dealloc {
    for (NVNode *child in _root.children) {
        [_root removeChild:child];
    }
}

@end
