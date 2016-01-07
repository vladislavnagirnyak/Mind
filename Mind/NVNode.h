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

@interface NVNode<__covariant DrawerType:CALayer*> : NSObject

typedef void(^NVNodeBlock)(NVNode<DrawerType> *first, NVNode<DrawerType> *second);

@property(weak) NVNode<DrawerType>* parent;
@property NSArray<NVNode<DrawerType>*> *children;
@property size_t level;
@property(weak) DrawerType drawer;

@property NSString *value;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withParent:(NVNode<DrawerType>*)parent;

- (NVNode<DrawerType>*)findRoot;
- (void)addChild: (NVNode<DrawerType>*)child;
- (void)removeChild: (NVNode<DrawerType>*)child;
- (void)collision: (NVNodeBlock)action;

@end
