//
//  NVItemPropertyView.h
//  Mind
//
//  Created by Влад Нагирняк on 30.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface NVItemPropertyView : UIView

typedef void(^OnTapBlock)();

@property(copy) OnTapBlock onAddTap;
@property(copy) OnTapBlock onRemoveTap;

@end
