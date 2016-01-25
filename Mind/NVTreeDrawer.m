//
//  NVTreeDrawer.m
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import "NVTreeDrawer.h"
#import "NVNode.h"
#import <UIKit/UIKit.h>
#import "NVMath.h"

typedef NVNode<NVTreeDrawer*> NVTNode;

static double sPadding = 20;
static double sRadius = 50;
static size_t sPathLineWidth = 2;

@interface NVTreeDrawer() {
    //NVGrid *_grid;
    CGPoint _lastUpdatePos;
    BOOL _isUpdated;
}

@property(readonly) CAShapeLayer *path;
@property(readonly, nonatomic) NVTreeDrawer *parent;

@end

@implementation NVTreeDrawer

@synthesize label = _label, path = _path;

- (NVTreeDrawer*)parent {
    if (_node.parent) {
        return _node.parent.delegate;
    }
    
    return nil;
}

- (instancetype)initWithNode:(NVNode*)node onLayer:(CALayer*)layer /*withGrid:(NVGrid *) grid*/ {
    self = [self init];
    if (self) {
        _node = node;
        //_grid = grid;
        _node.delegate = self;
        
        self.label.string = _node.value;
        
        [super setPosition: UnnormalizedPos(_node.position, [UIScreen mainScreen].bounds)];
        [self update:NVTDU_PATH | NVTDU_INTERSECTION];
        
        if (_node.parent) {
            [layer addSublayer:self.path];
        }

        for (NVNode *subnode in _node.children) {
            [[NVTreeDrawer alloc] initWithNode:subnode onLayer:layer /*withGrid:grid*/];
        }
        
        [layer addSublayer:self];
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, sRadius * 2, sRadius * 2);
        self.borderWidth = 1.0;
        self.borderColor = [UIColor blackColor].CGColor;
        self.cornerRadius = sRadius;
        self.bounds = self.frame;
        self.speed = 10.0;
        self.backgroundColor = [UIColor colorWithRed:0.3 + arc4random_uniform(255) / 255.0 green:0.3 + arc4random_uniform(255) / 255.0 blue:0.3 + arc4random_uniform(255) / 255.0 alpha:1.0].CGColor;
        _isUpdated = YES;
    }
    
    return self;
}


- (CATextLayer *)label {
    if (!_label) {
        _label = [CATextLayer layer];
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
        _path = [CAShapeLayer layer];
        _path.lineWidth = sPathLineWidth;
        _path.strokeColor = [UIColor blackColor].CGColor;
        _path.zPosition = -1.0;
        _path.fillColor = [UIColor colorWithWhite:1 alpha:0].CGColor;
    }
    
    return _path;
}

- (void)setRadius:(CGFloat)radius {
    sRadius = radius;
}

- (CGFloat)radius {
    return sRadius;
}

- (void)setPadding:(CGFloat)padding {
    sPadding = padding;
}

- (CGFloat)padding {
    return sPadding;
}

- (void)updatePath {
    if (self.parent) {
        UIBezierPath *path = [UIBezierPath new];
        CGPoint parentPos = self.parent.position;
        CGPoint dir = VSub(self.position, parentPos);
        CGPoint normDir = VNormalize(dir);
        
        [path moveToPoint:VAdd(parentPos, VMulN(normDir, self.parent.radius))];
        
        //NSArray *items = [_grid getObjectsInRangePoint:self.parent.position end:self.position];
        
        NVTreeDrawer *parent = self.parent;
        
        NVNode *root = [_node findRoot];
        
        NVRay ray = NVRayMake(parent.position, VSub(self.position, parent.position));
        NVCircle circle = NVCircleMake(self.position, self.radius + sPathLineWidth);
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        [root foreach:^BOOL(NVTNode *node) {
            if (node != _node) {
                NVTNode *nodeParent = node.parent;
                if (nodeParent) {
                    NVRay nodeRay = NVRayMake(nodeParent.delegate.position, VSub(node.delegate.position, nodeParent.delegate.position));
                    
                    if (IntersectCircleRay(circle, nodeRay, nil)) {
                        [node.delegate updatePath];
                        return YES;
                    }
                }
                
                if (IntersectCircleRay(NVCircleMake(node.delegate.position, node.delegate.radius + sPathLineWidth), ray, nil))
                    [items addObject:node];
            }
            return YES;
        }];
        
        items = [items sortedArrayUsingComparator:^NSComparisonResult(NVTNode *obj1, NVTNode *obj2) {
            CGFloat len1 = VLength(VSub(obj1.delegate.position, parent.position));
            CGFloat len2 = VLength(VSub(obj2.delegate.position, parent.position));
            if (len1 < len2)
                return NSOrderedAscending;
            else if (len1 > len2)
                return NSOrderedDescending;
            
            return NSOrderedSame;
        }];
        
        for (NVNode *node in items) {
            NVTreeDrawer *item = node.delegate;
            
                NVCircle circleItem = NVCircleMake(item.position, item.radius + sPathLineWidth);
            
                NVQuadCurve curve;
                if (IntersectCircleRay(circleItem, ray, &curve)) {
                    CGPoint delta = VMulN(VNormalize(ray.direction), sPadding / 2);
                    curve.start = VSub(curve.start, delta);
                    curve.end = VAdd(curve.end, delta);
                    //delta = VMulN(VNormalize(VSub(curve.control, circle.center)), circle.radius / 2);
                    //curve.control = VAdd(curve.control, delta);
                    [path addLineToPoint:curve.start];
                    [path moveToPoint:curve.start];
                    [path addQuadCurveToPoint:curve.end controlPoint:curve.control];
                    [path moveToPoint:curve.end];
                }
            
        }
        
        CGPoint endPoint = VAdd(self.position, VMulN(VNegate(normDir), self.radius));
        [path addLineToPoint:endPoint];
        
        self.path.path = path.CGPath;
    }
}

- (void)intersectTest {
    NVCircle c = NVCircleMake(self.position, self.radius + sPadding / 2);
    
    NVNode *root = [_node findRoot];
    
    [root foreach:^BOOL(NVTNode *node) {
        if (node != _node) {
            NVTreeDrawer *item = node.delegate;
        
        NVCircle c1 = NVCircleMake(item.position, item.radius + sPadding / 2);
        
        if (IntersectCircleCircle(c, c1)) {
            CGPoint dir = VSub(c1.center, c.center);
            
            if ([_node onPath:item.node]) {
                self.position = VSub(c1.center, VMulN(VNormalize(dir), c.radius + c1.radius + 1));
                [self update:NVTDU_ALL];
            } else {
                CGFloat n = (c.radius + c1.radius - VLength(dir)) / 2;
                node.delegate.position = VAdd(c1.center, VMulN(VNormalize(dir), n + 1));
                [node.delegate update:NVTDU_ALL];
            }
        }
        }
        return YES;
    }];
}

- (void)update: (size_t)flags {
    if (flags & NVTDU_INTERSECTION)
        [self intersectTest];
    
    if (flags & NVTDU_NODE_POS)
        _node.position = NormalizedPos(self.position, [UIScreen mainScreen].bounds);
    
    if (flags & NVTDU_PATH)
        [self updatePath];
    
    if (flags & NVTDU_CHILD && !_isRollUp) {
        _isUpdated = YES;
        CGPoint deltaPos = VSub(self.position, _lastUpdatePos);
        for (NVTNode *child in _node.children) {
            if (flags & NVTDU_CHILD_POS) {
                child.delegate.position = VAdd(child.delegate.position, deltaPos);
                [child.delegate update:flags];
            } else {
                [child.delegate update: NVTDU_PATH];
            }
        }
    }
}

- (void) setPosition:(CGPoint)position {
    if (_isUpdated)
        _lastUpdatePos = self.position;
    
    [super setPosition:position];
    
    _isUpdated = NO;
    
    //[self update: NVTDU_ALL];
}

- (void)removeFromSuperlayer {
    //[_grid removeObject:self];
    [_path removeFromSuperlayer];
    [super removeFromSuperlayer];
    
    for (NVTNode *item in _node.children) {
        if (item.delegate) {
            [item.delegate removeFromSuperlayer];
        }
    }
}

- (void)setIsRollUp:(BOOL)isRollUp {
    if (_isRollUp == isRollUp)
        return;
    
    _isRollUp = isRollUp;
    
    if (_isRollUp) {
        for (NVTNode *child in _node.children)
            [child.delegate rollUp];
    } else {
        CGPoint delta = VSub(self.position, _lastUpdatePos);
        for (NVTNode *child in _node.children)
            [child.delegate expand:delta];
    }
}

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag {
    /*if ([anim.keyPath isEqual: @"position"]) {
        if (self.parent.isRollUp) {
            self.hidden = YES;
            _path.hidden = YES;
            [super setPosition:self.parent.position];
        } else {
            self.hidden = NO;
            _path.hidden = NO;
            [super setPosition:UnnormalizedPos(_node.position, self.superlayer.bounds)];
        }
    }*/
}

- (void)rollUp {
    _path.hidden = YES;
    self.opacity = 0.0;
    CGPoint pos = self.position;
    
    if (self.parent.isRollUp) {
        CABasicAnimation *animPos = [CABasicAnimation animationWithKeyPath:@"position"];
        animPos.fromValue = [NSValue valueWithCGPoint: pos];
        animPos.toValue = [NSValue valueWithCGPoint: self.parent.position];
        animPos.duration = 2.0;
        animPos.beginTime = 0.0;
        animPos.removedOnCompletion = YES;
        animPos.delegate = self;
        animPos.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self addAnimation:animPos forKey:@"animPos"];
        
        CABasicAnimation *animOpac = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animOpac.fromValue = @(1.0);
        animOpac.toValue = @(0.0);
        animOpac.duration = 1.1;
        animOpac.beginTime = 0.0;
        animOpac.removedOnCompletion = YES;
        //[self addAnimation:animOpac forKey:@"animOpac"];
        //[_path addAnimation:animOpac forKey:@"animOpac"];
        [self addAnimation:animOpac forKey:@"animOpac"];
    }
    
    for (NVTNode *child in _node.children) {
        [child.delegate rollUp];
    }
    
    /*
     CAAnimationGroup *group = [CAAnimationGroup animation];
     [group setDuration:10.0];
     [group setAnimations:@[posAnimation, borderWidthAnimation]];*/
}

- (void)expand:(CGPoint)delta {
    if (self.parent.isRollUp) {
        [super setPosition:self.parent.position];
    } else {
        
        CGPoint pos = UnnormalizedPos(_node.position, [UIScreen mainScreen].bounds);
        
        [super setPosition:pos];
        
        CABasicAnimation *animPos = [CABasicAnimation animationWithKeyPath:@"position"];
        animPos.fromValue = [NSValue valueWithCGPoint: self.parent.position];
        animPos.toValue = [NSValue valueWithCGPoint: pos];
        animPos.duration = 2.0;
        animPos.beginTime = 0.0;
        animPos.removedOnCompletion = YES;
        animPos.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [self addAnimation:animPos forKey:@"animPos"];
        
        _path.hidden = NO;
        self.opacity = 1.0;
        
        CABasicAnimation *animOpac = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animOpac.fromValue = @(0.0);
        animOpac.toValue = @(1.0);
        animOpac.duration = 2.0;
        animOpac.beginTime = 0.0;
        animOpac.removedOnCompletion = YES;
        [self addAnimation:animOpac forKey:@"animOpac"];
    }
    
    for (NVTNode *child in _node.children)
        [child.delegate expand:delta];
}

@end
