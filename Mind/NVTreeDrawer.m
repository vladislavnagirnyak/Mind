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
#import "NSArray+Collision.h"

typedef NVNode<NVTreeDrawer*> NVTNode;

static double sNVTreeNodePadding = 20;
static double sNVTreeNodeRadius = 50;
static CGPoint sMinPos;
static CGPoint sMaxPos;

@interface NVTreeDrawer() {
    //NVGrid *_grid;
}

@property (readonly) CAShapeLayer *path;
@property NVTreeDrawer *parent;

@end

@implementation NVTreeDrawer

@synthesize label = _label, path = _path;

+ (CGPoint)minPoint {
    return sMinPos;
}

+ (CGPoint)maxPoint {
    return sMaxPos;
}

- (NVTreeDrawer*)parent {
    if (_node.parent) {
        return _node.parent.delegate;
    }
    
    return nil;
}

- (void)setParent:(NVTreeDrawer *)parent {
    if (_node.parent) {
        _node.parent.delegate = parent;
    }
}

- (instancetype)initWithNode:(NVNode*)node onLayer:(CALayer*)layer /*withGrid:(NVGrid *) grid*/ {
    self = [self init];
    if (self) {
        _node = node;
        //_grid = grid;
        _node.delegate = self;
        
        self.label.string = _node.value;
        
        CGPoint pos = UnnormalizedPos(node.position, layer.bounds);
        
        [self setPosition:pos flags:NVTD_CHILD_NOT_UPDATE];
        
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
        _path.zPosition = 1.0;
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

+ (void)updateMinMax:(CGPoint)pos withRadius:(CGFloat)radius {
    sMinPos.x = pos.x < sMinPos.x ? pos.x - radius : sMinPos.x;
    sMinPos.y = pos.y < sMinPos.y ? pos.y - radius : sMinPos.y;
    
    sMaxPos.x = pos.x > sMaxPos.x ? pos.x + radius : sMaxPos.x;
    sMaxPos.y = pos.y > sMaxPos.y ? pos.y + radius : sMaxPos.y;
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
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        [root foreach:^BOOL(NVTNode *node) {
            if (node != _node) {
                NVTNode *nodeParent = node.parent;
                if (nodeParent) {
                    NVRay nodeRay = NVRayMake(nodeParent.delegate.position, VSub(node.delegate.position, nodeParent.delegate.position));
                    
                    if (IntersectCircleRay(NVCircleMake(self.position, self.radius), nodeRay, nil)) {
                        [node.delegate updatePath];
                        return YES;
                    }
                }
                
                if (IntersectCircleRay(NVCircleMake(node.delegate.position, node.delegate.radius), ray, nil))
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
        
        //[items collision:^(NVTreeDrawer *first, NVTreeDrawer *second) {
        for (NVNode *node in items) {
            NVTreeDrawer *item = node.delegate;
            
                NVCircle circle = C(item.position, item.radius);
            
                NVQuadCurve curve;
                if (IntersectCircleRay(circle, ray, &curve)) {
                    CGPoint delta = VMulN(VNormalize(ray.direction), circle.radius / 4);
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
        
        [path addLineToPoint:VAdd(self.position, VMulN(VNegate(normDir), self.radius))];
        
        self.path.path = path.CGPath;
    }
}

- (void)intersectTest:(CGPoint)delta {
    __block CGPoint position = self.position;

    NVCircle c = NVCircleMake(position, self.radius);
    
    NVNode *root = [_node findRoot];
    
    [root foreach:^BOOL(NVNode *node) {
        if (node != _node) {
            NVTreeDrawer *item = node.delegate;
        
        NVCircle c1 = NVCircleMake(item.position, item.radius);
        
        if (IntersectCircleCircle(c, c1)) {
            CGPoint dir = VSub(c1.center, c.center);
            CGFloat n = (c.radius + c1.radius - VLength(dir)) / 2;
            
            if ([_node onPath:item.node]) {
                [self setPosition: VSub(c1.center, VMulN(VNormalize(dir), c.radius + c1.radius + 1))];
            } else {
                [item setPosition: VAdd(c1.center, VMulN(VNormalize(dir), n + 1))];
            }
        }
        }
        
        return YES;
    }];
}

- (void)setPosition:(CGPoint)position flags:(NSUInteger)flags {
    CGPoint delta = VSub(position, self.position);
    
    _node.position = NormalizedPos(position, self.superlayer.bounds);
    
    [NVTreeDrawer updateMinMax:position withRadius:self.radius];
    
    //[_grid removeObjectInPoint:self.position];
    [super setPosition:position];
    //[_grid setObject:self inPoint:position];
    
    [self intersectTest: delta];
    
    [self updatePath];
    
    if (flags & NVTD_CHILD_NOT_UPDATE)
        return;
        
    for (NVNode *child in _node.children) {
        NVTreeDrawer *item = child.delegate;
        
        if (flags & NVTD_CHILD_NOT_UPDATE_POS) {
            [item updatePath];
        } else {
            [item setPosition:VAdd(item.position, delta) flags:flags];
        }
    }
}

- (void)setStrategy:(id<NVStrategyDraw>)strategy {
    _strategy = strategy;
    for (NVTNode *item in _node.children) {
        item.delegate.strategy = strategy;
    }
}

- (void)addChild {
    NVNode *child = [[NVNode alloc] initWithParent:_node];
    
    NVTreeDrawer *childDrawer = [[NVTreeDrawer alloc] initWithNode:child onLayer:self.superlayer /*withGrid:_grid*/];
    
    childDrawer.strategy = self.strategy;
    
    [self.strategy addChild:childDrawer];
}

- (void) setPosition:(CGPoint)position {
    [self setPosition:position flags:0];
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

@end
