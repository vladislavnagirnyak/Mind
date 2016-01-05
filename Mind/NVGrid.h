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

@interface NVGrid<ObjectType> : NSObject

@property(nonatomic) CGSize cellSize;

- (NVCoord)getCoord: (CGPoint)point;
- (ObjectType)getObjectInPoint: (CGPoint)point;
- (ObjectType)getObjectInCoord: (NVCoord)coord;
- (NSArray<ObjectType>*)getObjectsInRangeCoord: (NVCoord)start end:(NVCoord)end;
- (void)setObject: (ObjectType)object inPoint: (CGPoint)point;
- (void)setObject: (ObjectType)object inCoord: (NVCoord)coord;
- (BOOL)moveObjectFromPoint: (CGPoint)from toPoint: (CGPoint)to isReplace:(BOOL)isReplace;
- (BOOL)moveObjectFromCoord: (NVCoord)from toCoord: (NVCoord)to isReplace:(BOOL)isReplace;
- (void)removeObjectInPoint: (CGPoint)point;
- (void)removeObjectInCoord: (NVCoord)coord;
- (void)clear;

@end
