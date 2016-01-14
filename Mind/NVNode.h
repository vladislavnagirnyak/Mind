//
//  NVTreeNode.h
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*@protocol NVNode;
@class NVNode;

@protocol NVNode //<NSObject>

@property(weak) id<NVNode> parent;
@property NSArray<id<NVNode>> *children;
@property size_t level;
@property(weak) id drawer;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withParent:(id<NVNode>)parent;

@end

@interface NVNode<__covariant ObjectType:NVNode*> : NSObject<NVNode>
@end*/

@protocol NVNodeDelegate <NSObject>

- (void)setPosition:(CGPoint)position;
- (CGPoint)position;

@end

@interface NVNode<__covariant DelegateType:id<NVNodeDelegate>> : NSObject

@property(weak) NVNode* parent;
@property NSArray<NVNode*> *children;
@property size_t level;
@property(weak) DelegateType delegate;

@property NSString *value;
@property CGPoint position;

- (instancetype)initWithParent:(NVNode*)parent;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary withParent:(NVNode*)parent;

- (NVNode*)findRoot;
- (void)addChild: (NVNode*)child;
- (void)remove;
- (BOOL)foreach: (BOOL(^)(NVNode *node))action;
- (void)foreachLevel: (void(^)(NSArray<NVNode*> *items))action;
- (BOOL)onPath: (NVNode*)node;

@end
