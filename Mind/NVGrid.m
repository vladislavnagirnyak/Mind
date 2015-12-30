//
//  NVGrid.m
//  Mind
//
//  Created by Влад Нагирняк on 29.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import "NVGrid.h"

@interface NVPair : NSObject

@property NVCoord key;
@property id value;

@end

@interface NVGrid() {
    NSMutableArray<NVPair*> *_items;
}
@end

@implementation NVGrid

- (NVCoord)getCoord: (CGPoint)point {
    CGFloat xSteps = point.x / self.cellSize.width;
    CGFloat ySteps = point.y / self.cellSize.height;
    
    return NVCoordMake(xSteps > (size_t)xSteps ? xSteps + 1 : xSteps,
                       ySteps > (size_t)ySteps ? ySteps + 1 : ySteps);
}

- (NVPair*)getPair: (NVCoord)coord {
    for (NVPair *item in _items)
        if (isEqual(item.key, coord))
            return item;
    
    return nil;
}

- (void)setCellSize:(CGSize)cellSize {
    _cellSize = cellSize;
}

- (id)getObjectInPoint: (CGPoint)point {
    return [self getObjectInCoord:[self getCoord:point]];
}

- (id)getObjectInCoord: (NVCoord)coord {
    NVPair *pair = [self getPair:coord];
    
    if (pair)
        return pair.value;
    
    return nil;
}

- (void)setObject: (id)object inPoint: (CGPoint)point {
    [self setObject:object inCoord:[self getCoord:point]];
}

- (void)setObject: (id)object inCoord: (NVCoord)coord {
    NVPair *pair = [self getPair:coord];
    
    if (!pair) {
        pair = [[NVPair alloc] init];
        pair.key = coord;
        [_items addObject:pair];
    }
    
    pair.value = object;
}

- (void)removeObjectInPoint: (CGPoint)point {
    [self removeObjectInCoord:[self getCoord:point]];
}

- (void)removeObjectInCoord: (NVCoord)coord {
    NVPair *pair = [self getPair:coord];
    
    [_items removeObject:pair];
}

@end

NVCoord NVCoordMake(size_t x, size_t y)
{
    NVCoord coord;
    coord.x = x;
    coord.y = y;
    return coord;
}

bool isEqual(NVCoord c1, NVCoord c2)
{
    return c1.x == c2.x && c1.y == c2.y;
}
