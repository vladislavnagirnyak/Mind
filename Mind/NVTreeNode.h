//
//  NVTreeNode.h
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NVTreeNode : NSObject

typedef void(^NodeBlock)(NVTreeNode*);

@property NSString *value;
@property(weak) NVTreeNode *parent;
@property NSMutableArray<NVTreeNode*> *children;
@property size_t level;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inRoot:(NVTreeNode*)root;

@end
