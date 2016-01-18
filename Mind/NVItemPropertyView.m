//
//  NVItemPropertyView.m
//  Mind
//
//  Created by Влад Нагирняк on 30.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import "NVItemPropertyView.h"

@interface NVItemPropertyView() {
    __weak IBOutlet UIButton *_removeButton;
    __weak IBOutlet UIButton *_addButton;
    __weak IBOutlet UIButton *_shButton;
}
//@property (weak, nonatomic) IBOutlet UIView *moverPos;
@end

@implementation NVItemPropertyView

//@synthesize onAddTap = _onAddTap, onRemoveTap = _onRemoveTap;
- (IBAction)onAddTouch:(UIButton *)sender forEvent:(UIEvent *)event {
    self.onAddTap();
}

- (IBAction)onRemoveTouch:(UIButton *)sender forEvent:(UIEvent *)event {
    self.onRemoveTap();
}

- (IBAction)onShowHideTap:(UIButton *)sender forEvent:(UIEvent *)event {
    if (_isExpend)
        self.onHideTap();
    else self.onShowTap();
    
    self.isExpend = !_isExpend;
}

- (void)setIsExpend:(bool)isExpend {
    _isExpend = isExpend;
    
    if (_isExpend) {
        [_shButton setTitle:@"." forState:UIControlStateNormal];
    } else
        [_shButton setTitle:@"..." forState:UIControlStateNormal];
}

- (void)load {
    UIView *nibView = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    nibView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:nibView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[nibView]-0-|" options:0 metrics:nil views:@{@"nibView": nibView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[nibView]-0-|" options:0 metrics:nil views:@{@"nibView": nibView}]];
    nibView.layer.cornerRadius = 10;
    self.frame = CGRectMake(0, 0, 128, 42);
    _shButton.layer.cornerRadius = 19;
    _addButton.layer.cornerRadius = 19;
    _removeButton.layer.cornerRadius = 19;
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
