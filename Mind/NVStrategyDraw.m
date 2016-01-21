//
//  NVStrategyDraw.m
//  Mind
//
//  Created by Влад Нагирняк on 01.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#import "NVStrategyDraw.h"
#import "NVTreeDrawer.h"

@interface NVStrategyDrawTopToBottom() {
    CGPoint _startPoint;
    //NVGrid *_grid;
}

@end

@implementation NVStrategyDrawTopToBottom

-(instancetype)initWithStart: (CGPoint)point /*withGrid:(NVGrid*)grid*/ {
    self = [super init];
    if (self) {
        _startPoint = point;
        //_grid = grid;
    }
    return self;
}

- (void)addChild:(NVTreeDrawer*)child {
    child.position = VAdd(child.node.parent.delegate.position, V(0, 50 * 2 + 20));
    child.node.value = [NSString stringWithFormat:@"%lu-%zu", [child.node.parent.children indexOfObject:child.node], child.node.level];
    child.label.string = child.node.value;
}

- (void)update:(NVTreeDrawer*)data {
    __block CGFloat yOffset = _startPoint.y;
    size_t radius = data.radius;
    size_t padding = data.padding;
    [data.node foreachLevel:^(NSArray<NVNode *> *items) {
        CGFloat xOffset = _startPoint.x - items.count * (radius * 2 + padding) / 2;
        
        for (NVNode *item in items) {
            NVTreeDrawer *drawer = item.delegate;

            CGPoint newPos = V(xOffset, yOffset);
            [drawer setPosition:newPos flags: NVTD_CHILD_NOT_UPDATE|NVTD_NOT_INTERSECTION|NVTD_NOT_UPDATE_PATH];
            xOffset += radius * 2 + padding;
        }
        
        yOffset += radius * 2 + padding;
    }];
}

@end

@interface NVStrategyDrawCircle() {
    
}

@end

@implementation NVStrategyDrawCircle

- (void)update:(NVTreeDrawer*)data {
    size_t radius = data.radius;
    size_t padding = data.padding;
    
    __block CGFloat margin = 0;
    
    [data.node foreachLevel:^(NSArray<NVNode *> *items) {
        CGFloat step = M_PI * 2 / items.count;
        
        CGFloat gamma = M_PI_2 - step / 2;
        CGFloat c = (radius + padding / 2) / sin(gamma);
        CGFloat newMargin = c / sin(step / 2) * sin(gamma);
        if (items.count == 1) {
            newMargin = 0;
        }
        
        CGFloat minMargin = margin + radius * 2 + padding + 1;
        
        margin = newMargin > minMargin ? newMargin : minMargin;
        
        if (items.firstObject.level == 0)
            margin = 0;
        
        for (size_t i = 0; i < items.count; i++) {
            NVTreeDrawer *item = items[i].delegate;
            CGPoint offset = V(sin(i * step) * margin, cos(i * step) * margin);
            [item setPosition:offset flags:NVTD_CHILD_NOT_UPDATE | NVTD_NOT_INTERSECTION | NVTD_NOT_UPDATE_PATH];
        }
    }];
}

- (void)addChild:(NVTreeDrawer*)child {
    
}

@end
