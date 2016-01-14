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

-(void)draw:(id)data;
-(void)addChild:(id)child;

@end

@class NVTreeDrawer;

@interface NVStrategyDraw : NSObject<NVStrategyDraw>

-(instancetype)initWithStart: (CGPoint)point /*withGrid:(NVGrid*)grid*/;
-(void)draw:(NVTreeDrawer*)data;
-(void)addChild:(NVTreeDrawer*)child;

@end
