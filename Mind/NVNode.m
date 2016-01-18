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

- (instancetype)initWithParent:(NVNode*)parent {
    self = [self init];
    if (self) {
        if (parent) {
            [parent addChild:self];
        }
    }
    
    return self;
}

- (void)setLevel:(size_t)level {
    _level = level;
    
    for (NVNode *child in self.children) {
        child.level = level + 1;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withParent:(NVNode*)parent {
    self = [self initWithParent:parent];
    if (self) {
        _value = dictionary[@"body"];
        NSArray *children = dictionary[@"children"];
        
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
    
    if (root) {
        while (root.parent)
            root = root.parent;

        return root;
    }
    
    return self;
}

- (void)addChild: (NVNode*)child {
    [_children addObject:child];
    child.parent = self;
    child.level = self.level + 1;
}

- (void)removeChild: (NVNode*)child {
    [_children removeObject:child];
}

- (void)remove {    
    while (_children.count != 0) {
        [_children.lastObject remove];
    }
    
    if (_parent) {
        [_parent removeChild:self];
    }
    
    _value = nil;
}

- (BOOL)foreach:(BOOL (^)(NVNode *))action {
    BOOL result = action(self);
    
    if (result)
        for (NVNode *child in self.children) {
            result = [child foreach:action];
            if (!result) {
                break;
            }
        }
    
    return result;
}

- (void)foreachLevel: (void(^)(NSArray<NVNode*> *items))action {
    NSMutableArray *queue = [[NSMutableArray alloc] init];
    [queue addObject:self];
    size_t currentLevel = self.level;
    size_t currentIndex = 0;
    while (queue.count) {
        NVNode *node = queue[currentIndex];
        
        if (queue.count - currentIndex == 1 &&
            node.children.count == 0) {
            currentIndex++;
            currentLevel++;
        }
        
        if (node.level != currentLevel) {
            NSRange range = NSMakeRange(0, currentIndex);
            action([queue subarrayWithRange:range]);
            [queue removeObjectsInRange: range];
            currentLevel++;
            currentIndex = 0;
            continue;
        }
        
        currentIndex++;
        [queue addObjectsFromArray:node.children];
    }
}

- (BOOL)onPath:(NVNode *)node {
    NVNode *root = self;
    
    while (root) {
        if (root == node)
            return YES;
        root = root.parent;
    }
    
    return NO;
}

@end