//
//  NVStrategyDraw.h
//  Mind
//
//  Created by Влад Нагирняк on 01.01.16.
//  Copyright © 2016 Влад Нагирняк. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "NVGrid.h"

@protocol NVStrategyDraw <NSObject>

- (void)update:(id)data;
- (void)addChild:(id)child;

@end

@interface NVStrategyDraw : NSObject<NVStrategyDraw>

- (instancetype)initWithStart: (CGPoint)point /*withGrid:(NVGrid*)grid*/;
- (void)update:(id)data;
- (void)addChild:(id)child;

@end
