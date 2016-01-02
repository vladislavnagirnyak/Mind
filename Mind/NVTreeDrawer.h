//
//  NVTreeDrawer.h
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NVTreeNode.h"
#import "NVGrid.h"
#import "NVStrategyDraw.h"

typedef enum : NSUInteger {
    NVTD_CHILD_NOT_UPDATE_POS = 1,
    NVTD_CHILD_NOT_UPDATE = 1 << 1,
} NVTDFLAGS;

@class NVTreeDrawer;

typedef NVGrid<NVTreeDrawer*> NVTreeGrid;

@interface NVTreeDrawer : CALayer

@property NSMutableArray *children;
@property(weak) NVTreeDrawer *parent;
@property NVTreeNode *node;
@property (readonly) CATextLayer *label;
@property CGFloat radius;
@property CGFloat padding;

- (instancetype)initWithNode:(NVTreeNode*)node onLayer:(CALayer*)onLayer withGrid:(NVTreeGrid*)grid;
- (void)setPosition:(CGPoint)location flags:(NSUInteger)flags;

- (void)addChild;
- (void)remove;

- (void)draw:(id<NVStrategyDraw>)data;

@end
