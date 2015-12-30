//
//  NVTreeDrawer.m
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import "NVTreeDrawer.h"
#import "NVTreeNode.h"
#import <UIKit/UIKit.h>
#import "CGAffineTransformHelper.hpp"

static double sNVTreeNodePadding = 20;
static double sNVTreeNodeRadius = 50;

@interface NVTreeDrawer() {
    NVTreeNode *_node;
    NSMutableArray *_children;
    NVTreeDrawer *_parent;
}

@property (readonly) CATextLayer *label;
@property (readonly) CAShapeLayer *path;

@end

@implementation NVTreeDrawer

@synthesize label = _label, path = _path;

- (instancetype)initWithNode:(NVTreeNode*)node {
    self = [self init];
    if (self) {
        _node = node;
        _children = [NSMutableArray new];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, sNVTreeNodeRadius * 2, sNVTreeNodeRadius * 2);
        self.borderWidth = 1.0;
        self.borderColor = [UIColor blackColor].CGColor;
        self.cornerRadius = sNVTreeNodeRadius;
        self.speed = 10.0;
        self.backgroundColor = [UIColor colorWithRed:0.3 + arc4random_uniform(255) / 255.0 green:0.3 + arc4random_uniform(255) / 255.0 blue:0.3 + arc4random_uniform(255) / 255.0 alpha:1.0].CGColor;
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMoved:) name:@"gesturePanNotify" object:nil];
    }
    
    return self;
}

/*- (void)onMoved:(UIPanGestureRecognizer*)recognizer inView:(UIView*)view {
    CGPoint location = [recognizer locationInView:view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _deltaPan = CGPointMake(self.position.x - location.x, self.position.y - location.y);
    }
        
    self.position = CGPointMake(location.x + _deltaPan.x, location.y + _deltaPan.y);
}

- (void) onMoved:(NSNotification*)notify {
    NSDictionary *obj = notify.object;
    CGPoint location = ((NSValue*)[obj objectForKey:@"value"]).CGPointValue;
    if (CGRectContainsPoint(self.frame, location)) {
        UIGestureRecognizerState panState = ((NSNumber*)[obj objectForKey:@"state"]).intValue;
        if (panState == UIGestureRecognizerStateBegan) {
            _deltaPan = CGPointMake(self.position.x - location.x, self.position.y - location.y);
        }
        
        self.position = CGPointMake(location.x + _deltaPan.x, location.y + _deltaPan.y);
    }
}*/

- (CATextLayer *)label {
    if (!_label) {
        _label = [CATextLayer new];
        _label.foregroundColor = [UIColor blackColor].CGColor;
        _label.frame = CGRectMake(0, self.frame.size.height / 2 - 10, 100, 20);
        _label.font = (__bridge CFTypeRef)@"AmericanTypewriter-CondensedLight";
        _label.fontSize = 18;
        _label.alignmentMode = kCAAlignmentCenter;
        [self addSublayer:_label];
    }
    
    return _label;
}

- (CAShapeLayer *)path {
    if (!_path) {
        _path = [CAShapeLayer new];
        _path.fillColor = [UIColor blackColor].CGColor;
    }
    
    return _path;
}

- (void) setPosition:(CGPoint)position {
    CGPoint delta = CGPointMake(position.x - self.position.x, position.y - self.position.y);
    [super setPosition:position];
    _node.position = position;
    if (_node.parent) {
        UIBezierPath *path = [UIBezierPath new];
        CGPoint parentPos = _node.parent.position;
        [path moveToPoint:CGPointMake(parentPos.x, parentPos.y + sNVTreeNodeRadius)];
        [path addLineToPoint:CGPointMake(position.x - 1.0, position.y)];
        [path addLineToPoint:CGPointMake(position.x + 1.0, position.y)];
        [path closePath];
        
        self.path.path = path.CGPath;
    }
    
    for (NVTreeDrawer *item in _children) {
        item.position = CGPointMake(item.position.x + delta.x, item.position.y + delta.y);
    }
}

- (void)drawTopToBottomInLayer:(CALayer*)layer inPoint:(CGPoint)inPoint {
    self.position = inPoint;
    self.label.string = _node.value;
    
    NSUInteger childrenCount = _node.children.count;
    CGFloat xOffset = 0.0;
    if (childrenCount > 0) {
        xOffset = - (childrenCount * (sNVTreeNodeRadius + sNVTreeNodePadding) / 2.0);
    }
    
    if (_node.parent) {
        [layer addSublayer:self.path];
    }
    
    for (NVTreeNode *subnode in _node.children) {
        CGPoint newPoint = CGPointMake(inPoint.x + xOffset, inPoint.y + sNVTreeNodeRadius * 2 + sNVTreeNodePadding);

        NVTreeDrawer *subDrawer = [[NVTreeDrawer alloc] initWithNode:subnode];
        [_children addObject:subDrawer];
        [subDrawer drawTopToBottomInLayer:layer inPoint:newPoint];
        
        xOffset += sNVTreeNodeRadius * 2 + sNVTreeNodePadding;
    }
    
    [layer addSublayer:self];
}

- (void) dealloc {
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
