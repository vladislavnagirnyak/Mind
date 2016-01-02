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

static double sNVTreeNodePadding = 20;
static double sNVTreeNodeRadius = 50;

@interface NVTreeDrawer() {
    NVTreeGrid *_grid;
}

@property (readonly) CAShapeLayer *path;

@end

@implementation NVTreeDrawer

@synthesize label = _label, path = _path;

- (instancetype)initWithNode:(NVTreeNode*)node onLayer:(CALayer*)onLayer withGrid:(NVTreeGrid *) grid {
    self = [self init];
    if (self) {
        _node = node;
        _grid = grid;
        _children = [NSMutableArray new];
        
        self.label.string = _node.value;
        
        if (_node.parent) {
            [onLayer addSublayer:self.path];
        }
        
        for (NVTreeNode *subnode in _node.children) {
            NVTreeDrawer *subDrawer = [[NVTreeDrawer alloc] initWithNode:subnode onLayer:onLayer withGrid:grid];
            subDrawer.parent = self;
            [_children addObject:subDrawer];
        }
        
        [onLayer addSublayer:self];
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
    }
    
    return self;
}


- (CATextLayer *)label {
    if (!_label) {
        _label = [CATextLayer new];
        _label.foregroundColor = [UIColor blackColor].CGColor;
        _label.frame = CGRectMake(0, self.frame.size.height / 2 - 10, 100, 20);
        _label.font = (__bridge CFTypeRef)@"ArialMT";
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
        _path.borderWidth = 2.0;
        _path.lineWidth = 5.0;
    }
    
    return _path;
}

- (void)setRadius:(CGFloat)radius {
    sNVTreeNodeRadius = radius;
}

- (CGFloat)radius {
    return sNVTreeNodeRadius;
}

- (void)setPadding:(CGFloat)padding {
    sNVTreeNodePadding = padding;
}

- (CGFloat)padding {
    return sNVTreeNodePadding;
}

- (void)setPosition:(CGPoint)position flags:(NSUInteger)flags {
    CGPoint delta = CGPointMake(position.x - self.position.x, position.y - self.position.y);
    
    NVCoord coord = [_grid getCoord:self.position];
    
    CGFloat angle = atan2(delta.x, delta.y);
    //NSLog(@"%.4f", angle);
    
    
    //BOOL result = [_grid moveObjectFromPoint:self.position toPoint:position isReplace:NO];
    //[_grid removeObjectInPoint:self.position];
    [super setPosition:position];
    //[_grid setObject:self inPoint:position];
    
    if (self.parent) {
        UIBezierPath *path = [UIBezierPath new];
        CGPoint parentPos = self.parent.position;
        CGPoint dir = CGPointMake(self.position.x - parentPos.x, self.position.y - parentPos.y);
        CGFloat invLength = sqrt(dir.x * dir.x + dir.y * dir.y);
        if (invLength) {
            invLength = 1.0 / invLength;
        }
        CGPoint newDir = CGPointMake(dir.x * invLength * sNVTreeNodeRadius, dir.y * invLength * sNVTreeNodeRadius);
        
        [path moveToPoint:CGPointMake(parentPos.x + newDir.x, parentPos.y + newDir.y)];
        [path addLineToPoint:CGPointMake(position.x - newDir.x - 1.0, position.y - newDir.y)];
        [path addLineToPoint:CGPointMake(position.x - newDir.x + 1.0, position.y - newDir.y)];
        [path closePath];
        
        self.path.path = path.CGPath;
    }
    
    if (flags & NVTD_CHILD_NOT_UPDATE)
        return;
        
    for (NVTreeDrawer *item in self.children) {
        CGPoint newPoint = CGPointMake(item.position.x + delta.x, item.position.y + delta.y);
        
        if (flags & NVTD_CHILD_NOT_UPDATE_POS)
            newPoint = item.position;
        
        [item setPosition:newPoint flags:flags];
    }
}

- (void)addChild {
    NVTreeNode *child = [[NVTreeNode alloc] init];
    [_node.children addObject:child];
    child.parent = _node;
    
    NVTreeDrawer *childDrawer = [[NVTreeDrawer alloc] initWithNode:child onLayer:self.superlayer withGrid:_grid];
    
    [self.children addObject:childDrawer];
    childDrawer.parent = self;
    
    CGPoint newPoint = CGPointMake(self.position.x, self.position.y + sNVTreeNodeRadius * 2 + sNVTreeNodePadding);
    [childDrawer setPosition:newPoint flags:0];
}

- (void)remove {
    for (NVTreeDrawer *item in self.children) {
        [item remove];
    }
    
    [self removeFromSuperlayer];
    [self.path removeFromSuperlayer];
    
    if (_node.parent) {
        [_node.parent.children removeObject:_node];
    }
}

- (void) setPosition:(CGPoint)position {
    [self setPosition:position flags:0];
}

- (void)draw:(id<NVStrategyDraw>)data {
    [data draw:self];
}

- (void) dealloc {
}

@end
