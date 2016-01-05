//
//  NVTreeNode.h
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NVNode;
@class NVNode;

@protocol NVNode //<NSObject>

@property(weak) id<NVNode> parent;
@property NSArray<id<NVNode>> *children;
@property size_t level;
@property(weak) id drawer;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withParent:(id<NVNode>)parent;

@end

@interface NVNode<__covariant ObjectType:NVNode*> : NSObject<NVNode>
@end

@interface NVTreeNode : NSObject

typedef void(^NodeBlock)(NVTreeNode*);

@property NSString *value;
@property(weak) NVTreeNode *parent;
@property NSMutableArray<NVTreeNode*> *children;
@property size_t level;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inRoot:(NVTreeNode*)root;

@end
