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
    NVTD_CHILD_NOT_UPDATE_POS = 1,
    NVTD_CHILD_NOT_UPDATE = 1 << 1,
    NVTD_NOT_INTERSECTION = 1 << 2,
    NVTD_NOT_UPDATE_PATH = 1 << 3
} NVTDFLAGS;

@interface NVTreeDrawer : CALayer

@property NVNode<NVTreeDrawer*> *node;
@property(readonly) CATextLayer *label;
@property CGFloat radius;
@property CGFloat padding;
@property(nonatomic) id<NVStrategyDraw> strategy;
@property BOOL isRollUp;

- (instancetype)initWithNode:(NVNode*)node onLayer:(CALayer*)layer /*withGrid:(NVGrid*)grid*/;
- (void)setPosition:(CGPoint)location flags:(NSUInteger)flags;
- (void)addChild;

@end
