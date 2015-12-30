//
//  NVGrid.h
//  Mind
//
//  Created by Влад Нагирняк on 29.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef struct {
    size_t x;
    size_t y;
} NVCoord;

NVCoord NVCoordMake(size_t x, size_t y);
bool isEqual(NVCoord c1, NVCoord c2);

@interface NVGrid<ObjectType> : NSObject

@property(nonatomic) CGSize cellSize;

- (NVCoord)getCoord: (CGPoint)point;
- (ObjectType)getObjectInPoint: (CGPoint)point;
- (ObjectType)getObjectInCoord: (NVCoord)coord;
- (void)setObject: (ObjectType)object inPoint: (CGPoint)point;
- (void)setObject: (ObjectType)object inCoord: (NVCoord)coord;
- (BOOL)moveObjectFromPoint: (CGPoint)from toPoint: (CGPoint)to isReplace:(BOOL)isReplace;
- (BOOL)moveObjectFromCoord: (NVCoord)from toCoord: (NVCoord)to isReplace:(BOOL)isReplace;
- (void)removeObjectInPoint: (CGPoint)point;
- (void)removeObjectInCoord: (NVCoord)coord;
- (void)clear;

@end
