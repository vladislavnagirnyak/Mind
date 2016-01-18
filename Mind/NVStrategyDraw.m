//
//  NVStrategyDraw.m
//  Mind
//
//  Created by Влад Нагирняк on 01.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#import "NVStrategyDraw.h"
#import "NVTreeDrawer.h"

@interface NVStrategyDraw() {
    CGPoint _startPoint;
    //NVGrid *_grid;
    //NSMutableArray *_levelMap;
}

@end

@implementation NVStrategyDraw

-(instancetype)initWithStart: (CGPoint)point /*withGrid:(NVGrid*)grid*/ {
    self = [super init];
    if (self) {
        _startPoint = point;
        //_grid = grid;
        //_levelMap = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addChild:(NVNode *)child {
    child.position = VAdd(child.parent.position, V(0, 50 * 2 + 20));
}

- (void)update:(NVTreeDrawer*)data {
    __block CGFloat yOffset = _startPoint.y;
    size_t radius = 50;
    size_t padding = 20;
    [data.node foreachLevel:^(NSArray<NVNode *> *items) {
        CGFloat xOffset = _startPoint.x - items.count * (radius * 2 + padding) / 2;
        
        for (NVNode *item in items) {
            NVTreeDrawer *drawer = item.delegate;
            /*CGFloat xPOffset = xOffset;
             if (item.parent) {
             size_t currentIndex = [item.parent.children indexOfObject:item];
             size_t childrenCount = item.parent.children.count;
             NVTreeDrawer *parentDrawer = item.parent.drawer;
             xPOffset = parentDrawer.position.x - childrenCount * (radius * 2 + padding) / 2;
             xPOffset += currentIndex * (radius * 2 + padding);
             }
             
             xOffset = xPOffset > xOffset ? xPOffset : xOffset;*/
            
            CGPoint newPos = V(xOffset, yOffset);
            [drawer setPosition:newPos flags: NVTD_CHILD_NOT_UPDATE];
            xOffset += radius * 2 + padding;
        }
        
        yOffset += radius * 2 + padding;
    }];
    
    /*[self buildLevelMap:data withStart:data.node.level];
    
    size_t radius = data.radius;
    size_t padding = data.padding;
    
    NSMutableArray *xOffsets = [[NSMutableArray alloc] init];
    for (NSNumber *item in _levelMap) {
        [xOffsets addObject:[NSNumber numberWithInt:-item.unsignedIntegerValue * (radius * 2 + padding) / 2 + radius + padding / 2 ]];
    }
    
    [self drawTopToBottom:data inPoint:_startPoint offsets: xOffsets];*/
}

/*- (void)buildLevelMap: (NVTreeDrawer*)drawer withStart:(size_t)startLevel {
    size_t level = drawer.node.level - startLevel;
    
    if (startLevel - level == 0) {
        [_levelMap removeAllObjects];
    }
    
    if (_levelMap.count > level) {
        NSNumber *count = [_levelMap objectAtIndex:level];
        count = [NSNumber numberWithUnsignedInteger: count.unsignedIntegerValue + 1];
        [_levelMap replaceObjectAtIndex:level withObject:count];
    } else {
        [_levelMap addObject:@1];
    }
    
    for (NVNode *item in drawer.node.children) {
        [self buildLevelMap:item.drawer withStart:startLevel];
    }
}*/

/*- (void)drawTopToBottom:(NVTreeDrawer*)data inPoint:(CGPoint)inPoint offsets:(NSMutableArray*)offsets {
    
    size_t radius = data.radius;
    size_t padding = data.padding;
    
    int xOffsetNode = ((NSNumber*)[offsets objectAtIndex:data.node.level]).intValue;
    
    [data setPosition:CGPointMake(xOffsetNode + inPoint.x, inPoint.y) flags:NVTD_CHILD_NOT_UPDATE];
    [_grid setObject:data inPoint:data.position];
    
    [offsets replaceObjectAtIndex:data.node.level withObject:[NSNumber numberWithInt:xOffsetNode + radius * 2 + padding]];
    
    if (data.node.children.count > 0) {
        CGFloat xOffset = ((NSNumber*)[offsets objectAtIndex:data.node.level + 1]).intValue;

        for (NVNode *item in data.node.children) {
            NVTreeDrawer *subDrawer = item.drawer;
            CGPoint newPoint = CGPointMake(inPoint.x, inPoint.y + radius * 2 + padding);
            [self drawTopToBottom:subDrawer inPoint:newPoint offsets:offsets];
            xOffset += radius * 2 + padding;
        }
    }
}*/

@end
