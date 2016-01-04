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
#import "NVMath.h"

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
        _path.lineWidth = 1.0;
        _path.strokeColor = [UIColor blackColor].CGColor;
        //_path.backgroundColor = [UIColor whiteColor].CGColor;
        _path.fillColor = [UIColor colorWithWhite:1 alpha:0].CGColor;
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

- (NVTreeDrawer*)findRoot {
    NVTreeDrawer *root = self.parent;
    while (root.parent) {
        root = root.parent;
    }
    return root;
}

- (void)intersectionTest: (NVTreeDrawer*)item action: (void (^)(NVTreeDrawer*drawer, CGPoint first, CGPoint second))action {
    
    /*CGPoint dir = VSub(item.position, self.position);
    CGPoint normDir = VNormalize(dir);
    
    CGPoint pR = VRotate(VNegate(normDir), M_PI_2);
    pR = VMulN(pR, item.radius);
    pR = VSub(VAdd(item.position, pR), self.position);
    
    if (VAngle(dir, ray) < VAngle(dir, pR))
        if (VLength(pR) <= VLength(ray)) {
            NSLog(@"intersect");
            action();
        }*/
    
    if (self != item && item != self.parent) {
        NVCircle circle = C(item.position, item.radius);
        NVRay ray = R(self.position, VSub(self.parent.position, self.position));
        if (IntersectCircleRay(circle, ray)) {
            CGPoint dir = VSub(circle.center, ray.position);
            float beta = VAngle(ray.direction, dir);
            float dirLength = VLength(dir);
            CGFloat lengthAlpha = dirLength * sin(M_PI_2 - beta);
            CGPoint rayDir = VNormalize(ray.direction);
            CGPoint first = VAdd(ray.position, VMulN(rayDir, lengthAlpha + item.radius));
            CGPoint second = VAdd(ray.position, VMulN(rayDir, lengthAlpha - item.radius));
            action(item, first, second);
        }
    }
    
    for (NVTreeDrawer *child in item.children) {
        [self intersectionTest:child action:action];
    }
}

- (void)setPosition:(CGPoint)position flags:(NSUInteger)flags {
    CGPoint delta = VSub(position, self.position);
    
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
        CGPoint dir = VSub(self.position, parentPos);
        CGPoint normDir = VNormalize(dir);
        
        [path moveToPoint:VAdd(parentPos, VMulN(normDir, self.parent.radius))];
        
        NVTreeDrawer *root = [self findRoot];
        
        [self intersectionTest:root action:^(NVTreeDrawer*item, CGPoint first, CGPoint second){
            [path addLineToPoint:first];
            [path addQuadCurveToPoint:second controlPoint:VAdd(item.position, VMulN(VRotate(normDir, M_PI_2), item.radius * 3))];
            [path moveToPoint:second];
        }];
        
        [path addLineToPoint:VAdd(self.position, VMulN(VNegate(normDir), self.radius))];
        
        self.path.path = path.CGPath;
    }
    
    if (flags & NVTD_CHILD_NOT_UPDATE)
        return;
        
    for (NVTreeDrawer *item in self.children) {
        CGPoint newPoint = VAdd(item.position, delta);
        
        if (flags & NVTD_CHILD_NOT_UPDATE_POS)
            newPoint = item.position;
        
        [item setPosition:newPoint flags:flags];
    }
}

- (void)setStrategy:(id<NVStrategyDraw>)strategy {
    _strategy = strategy;
    for (NVTreeDrawer *item in self.children) {
        item.strategy = strategy;
    }
}

- (void)addChild {
    NVTreeNode *child = [[NVTreeNode alloc] init];
    [_node.children addObject:child];
    child.parent = _node;
    
    NVTreeDrawer *childDrawer = [[NVTreeDrawer alloc] initWithNode:child onLayer:self.superlayer withGrid:_grid];
    
    [self.children addObject:childDrawer];
    childDrawer.parent = self;
    childDrawer.strategy = self.strategy;
    
    [self.strategy addChild:childDrawer];
}

- (void)remove {
    for (NVTreeDrawer *item in self.children) {
        [item remove];
    }
    
    [self removeFromSuperlayer];
    [self.path removeFromSuperlayer];
    if (self.parent) {
        [self.parent.children removeObject:self];
    }
    
    if (_node.parent) {
        [_node.parent.children removeObject:_node];
    }
}

- (void) setPosition:(CGPoint)position {
    [self setPosition:position flags:0];
}

- (void)draw {
    if (self.strategy)
        [self.strategy draw:self];
}

- (void) dealloc {
}

@end
