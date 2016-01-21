//
//  NVTree.m
//  Mind
//
//  Created by Влад Нагирняк on 08.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#import "NVTree.h"
#import "NVMath.h"

#define KEY(n) [NSString stringWithFormat:@"%zu", n]
#define KEY_VALUE(s) [s stringByAppendingString: @"-val"]
#define KEY_POSITION(s) [s stringByAppendingString: @"-pos"]
#define KEY_COUNT(s) [s stringByAppendingString: @"-cnt"]

@implementation NVTree

- (instancetype)initWithRoot:(NVNode *)root {
    self = [super init];
    if (self) {
        _root = root;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    size_t offset = 0;
    [self encodeWithCoder:aCoder withNode:_root offset:&offset];
}

- (void)encodeWithCoder:(NSCoder*)aCoder withNode:(NVNode*)node offset:(size_t*)offset {
    NSString *key = KEY(*offset);
    (*offset)++;
    [aCoder encodeObject:node.value forKey:KEY_VALUE(key)];
    [aCoder encodeObject:[NSValue valueWithCGPoint:node.position] forKey:KEY_POSITION(key)];
    [aCoder encodeObject:@(node.children.count) forKey:KEY_COUNT(key)];
    
    /*[aCoder encodeObject:node.value];
    [aCoder encodeObject:[NSValue valueWithCGPoint:node.position]];
    [aCoder encodeObject:@(node.children.count)];*/
    
    for (NVNode *item in node.children) {
        [self encodeWithCoder:aCoder withNode:item offset:offset];
    }
}

- (NVNode*)createWithCoder:(NSCoder *)aDecoder withParent:(NVNode*)parent offset:(size_t*)offset {
    NVNode *node = [[NVNode alloc] initWithParent:parent];
    
    NSString *key = KEY(*offset);
    (*offset)++;
    node.value = [aDecoder decodeObjectForKey:KEY_VALUE(key)];
    node.position = [[aDecoder decodeObjectForKey:KEY_POSITION(key)] CGPointValue];
    size_t childrenCount = [[aDecoder decodeObjectForKey:KEY_COUNT(key)] unsignedLongLongValue];
    
    /*node.value = [aDecoder decodeObject];
    node.position = [[aDecoder decodeObject] CGPointValue];
    size_t childrenCount = [[aDecoder decodeObject] unsignedLongLongValue];*/
    
    for (size_t i = 0; i < childrenCount; i++) {
        [self createWithCoder:aDecoder withParent:node offset:offset];
    }
    
    return node;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        size_t offset = 0;
        _root = [self createWithCoder:aDecoder withParent:nil offset:&offset];
    }
    return self;
}

- (void)dealloc {
    [_root remove];
}

@end
