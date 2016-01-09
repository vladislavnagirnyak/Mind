//
//  NVGrid.h
//  Mind
//
//  Created by Влад Нагирняк on 29.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "NVMath.h"

@interface NVGrid : NSObject

@property(nonatomic) CGSize cellSize;

- (NVCoord)getCoord: (CGPoint)point;
- (id)getObjectInPoint: (CGPoint)point;
- (id)getObjectInCoord: (NVCoord)coord;
- (NSArray*)getObjectsInRangePoint: (CGPoint)start end:(CGPoint)end;
- (NSArray*)getObjectsInRangeCoord: (NVCoord)start end:(NVCoord)end;
- (void)setObject: (id)object inPoint: (CGPoint)point;
- (void)setObject: (id)object inCoord: (NVCoord)coord;
- (BOOL)moveObjectFromPoint: (CGPoint)from toPoint: (CGPoint)to isReplace:(BOOL)isReplace;
- (BOOL)moveObjectFromCoord: (NVCoord)from toCoord: (NVCoord)to isReplace:(BOOL)isReplace;
- (void)removeObjectInPoint: (CGPoint)point;
- (void)removeObjectInCoord: (NVCoord)coord;
- (void)removeObject: (id)object;
- (void)clear;

@end
