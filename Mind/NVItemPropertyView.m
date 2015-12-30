//
//  NVItemPropertyView.m
//  Mind
//
//  Created by Влад Нагирняк on 30.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import "NVItemPropertyView.h"

@interface NVItemPropertyView() {
}
//@property (weak, nonatomic) IBOutlet UIView *moverPos;
@end

@implementation NVItemPropertyView

//@synthesize onAddTap = _onAddTap, onRemoveTap = _onRemoveTap;

- (IBAction)valueChanged:(UIStepper *)sender {
    if (sender.value == 1)
        self.onAddTap();
    else self.onRemoveTap();
    
    sender.value = 0;
}

- (void)load {
    UIView *nibView = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    nibView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:nibView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[nibView]-0-|" options:0 metrics:nil views:@{@"nibView": nibView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[nibView]-0-|" options:0 metrics:nil views:@{@"nibView": nibView}]];
    nibView.layer.cornerRadius = 10;
    self.frame = CGRectMake(0, 0, 110, 40);
    //self.moverPos.layer.cornerRadius = 20;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self load];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self load];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
