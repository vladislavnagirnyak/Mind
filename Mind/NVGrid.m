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
@property(weak) id value;

@end

@implementation NVPair

@end

@interface NVGrid() {
    NSMutableArray<NVPair*> *_items;
}
@end

@implementation NVGrid

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
    }
    
    return self;
}

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

- (BOOL)moveObjectFromPoint: (CGPoint)from toPoint: (CGPoint)to isReplace:(BOOL)isReplace{
    return [self moveObjectFromCoord:[self getCoord:from] toCoord:[self getCoord:to] isReplace:isReplace];
}

- (BOOL)moveObjectFromCoord: (NVCoord)from toCoord: (NVCoord)to isReplace:(BOOL)isReplace{
    if (isEqual(from, to))
        return YES;
    
    NVPair *pair = [self getPair:from];
    
    if (pair) {
        NVPair *pairTarget = [self getPair:to];
        
        if (pairTarget && pair != pairTarget) {
            if (isReplace)
                [_items removeObject:pairTarget];
            else return NO;
        }
        
        pair.key = to;
        return YES;
    }
    
    return NO;
}

- (void)removeObjectInPoint: (CGPoint)point {
    [self removeObjectInCoord:[self getCoord:point]];
}

- (void)removeObjectInCoord: (NVCoord)coord {
    NVPair *pair = [self getPair:coord];
    
    if (pair)
        [_items removeObject:pair];
}

- (void)removeObject: (id)object {
    for (size_t i = 0; i < _items.count; i++) {
        if (_items[i].value == object) {
            [_items removeObjectAtIndex:i];
            i--;
        }
    }
}

- (void)clear {
    if (_items.count > 0)
        [_items removeAllObjects];
}

- (NSArray*)getObjectsInRangePoint: (CGPoint)start end:(CGPoint)end {
    return [self getObjectsInRangeCoord:[self getCoord:start] end:[self getCoord:end]];
}

- (NSArray*)getObjectsInRangeCoord: (NVCoord)start end:(NVCoord)end {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NVPair *pair in _items) {
        if (inRange(pair.key, start, end)) {
            [result addObject:pair.value];
        }
    }
    return result;
}

@end

