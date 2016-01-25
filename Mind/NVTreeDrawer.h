//
//  NVTreeDrawer.h
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NVNode.h"
#import "NVGrid.h"
#import "NVStrategyDraw.h"

typedef enum : NSUInteger {
    NVTDU_CHILD = 1,
    NVTDU_CHILD_POS = 1 << 1,
    NVTDU_INTERSECTION = 1 << 2,
    NVTDU_PATH = 1 << 3,
    NVTDU_NODE_POS = 1 << 4,
    NVTDU_ALL = NVTDU_CHILD | NVTDU_CHILD_POS | NVTDU_INTERSECTION | NVTDU_PATH | NVTDU_NODE_POS
} NVTreeDrawerUpdateFlags;

@interface NVTreeDrawer : CALayer

@property NVNode<NVTreeDrawer*> *node;
@property(readonly) CATextLayer *label;
@property CGFloat radius;
@property CGFloat padding;
@property BOOL isRollUp;

- (instancetype)initWithNode:(NVNode*)node onLayer:(CALayer*)layer /*withGrid:(NVGrid*)grid*/;
- (void)update: (size_t)flags;

@end
