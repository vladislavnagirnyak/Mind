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

@interface NVTreeDrawer() {
    NVGrid *_grid;
}

@property (readonly) CAShapeLayer *path;
@property NVTreeDrawer *parent;

@end

@implementation NVTreeDrawer

@synthesize label = _label, path = _path;

- (NVTreeDrawer*)parent {
    if (_node.parent) {
        return _node.parent.drawer;
    }
    
    return nil;
}

- (void)setParent:(NVTreeDrawer *)parent {
    if (_node.parent) {
        _node.parent.drawer = parent;
    }
}

- (instancetype)initWithNode:(NVNode*)node onLayer:(CALayer*)layer withGrid:(NVGrid *) grid {
    self = [self init];
    if (self) {
        _node = node;
        _grid = grid;
        _node.drawer = self;
        
        self.label.string = _node.value;
        [super setPosition:UnnormalizedPos(node.position, layer.bounds)];
        
        if (_node.parent) {
            [layer addSublayer:self.path];
        }

        for (NVNode *subnode in _node.children) {
            [[NVTreeDrawer alloc] initWithNode:subnode onLayer:layer withGrid:grid];
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

/*- (void)intersectionTest: (NVTreeDrawer*)item action: (void (^)(NVTreeDrawer*drawer, NVQuadCurve curve))action {

    NVTreeDrawer *parent = self.parent;
    
    if (self != item && item != parent && parent) {
        NVCircle circle = C(item.position, item.radius);
        NVRay ray = R(self.parent.position, VSub(self.position, self.parent.position));
        NVQuadCurve curve;
        if (IntersectCircleRay(circle, ray, &curve)) {
            CGPoint delta = VMulN(VNormalize(ray.direction), circle.radius / 2);
            curve.start = VSub(curve.start, delta);
            curve.end = VAdd(curve.end, delta);
            delta = VMulN(VNormalize(VSub(curve.control, circle.center)), circle.radius / 2);
            //curve.control = VAdd(curve.control, delta);
            action(item, curve);
        }
    }
    
    for (NVNode *child in item.node.children) {
        [self intersectionTest:child.drawer action:action];
    }
}*/

- (void)setPosition:(CGPoint)position flags:(NSUInteger)flags {
    CGPoint delta = VSub(position, self.position);
    
    _node.position = NormalizedPos(position, self.superlayer.bounds);
    
    //BOOL result = [_grid moveObjectFromPoint:self.position toPoint:position isReplace:NO];
    [_grid removeObjectInPoint:self.position];
    [super setPosition:position];
    [_grid setObject:self inPoint:position];

    if (self.parent) {
        UIBezierPath *path = [UIBezierPath new];
        CGPoint parentPos = self.parent.position;
        CGPoint dir = VSub(self.position, parentPos);
        CGPoint normDir = VNormalize(dir);
        
        [path moveToPoint:VAdd(parentPos, VMulN(normDir, self.parent.radius))];

        NSArray *items = [_grid getObjectsInRangePoint:self.parent.position end:self.position];
        
        NVTreeDrawer *parent = self.parent;
        
        items = [items sortedArrayUsingComparator:^NSComparisonResult(NVTreeDrawer *obj1, NVTreeDrawer *obj2) {
            CGFloat len1 = VLength(VSub(obj1.position, parent.position));
            CGFloat len2 = VLength(VSub(obj2.position, parent.position));
            if (len1 < len2)
                return NSOrderedAscending;
            else if (len1 > len2) return NSOrderedDescending;
            
            return NSOrderedSame;
        }];
        
        //[items collision:^(NVTreeDrawer *first, NVTreeDrawer *second) {
        for (NVTreeDrawer *item in items) {
            if (self != item && item != parent && parent) {
                NVCircle circle = C(item.position, item.radius);
                NVRay ray = R(self.parent.position, VSub(self.position, self.parent.position));
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
        }
        
        /*[self intersectionTest:root action:^(NVTreeDrawer*item, NVQuadCurve curve){
            [path addLineToPoint:curve.start];
            [path moveToPoint:curve.start];
            [path addQuadCurveToPoint:curve.end controlPoint:curve.control];
            [path moveToPoint:curve.end];
        }];*/
        
        [path addLineToPoint:VAdd(self.position, VMulN(VNegate(normDir), self.radius))];
        
        self.path.path = path.CGPath;
    }
    
    if (flags & NVTD_CHILD_NOT_UPDATE)
        return;
        
    for (NVTNode *child in _node.children) {
        NVTreeDrawer *item = child.drawer;
        CGPoint newPoint = VAdd(item.position, delta);
        
        if (flags & NVTD_CHILD_NOT_UPDATE_POS)
            newPoint = item.position;
        
        [item setPosition:newPoint flags:flags];
    }
}

- (void)setStrategy:(id<NVStrategyDraw>)strategy {
    _strategy = strategy;
    for (NVTNode *item in _node.children) {
        item.drawer.strategy = strategy;
        /*if ([item isKindOfClass:[self class]]) {
            ((NVTreeDrawer*)item.drawer).strategy = strategy;
        }*/
    }
}

- (void)addChild {
    NVTNode *child = [[NVTNode alloc] initWithParent:_node];
    
    NVTreeDrawer *childDrawer = [[NVTreeDrawer alloc] initWithNode:child onLayer:self.superlayer withGrid:_grid];
    
    childDrawer.strategy = self.strategy;
    
    [self.strategy addChild:childDrawer];
}

- (void) setPosition:(CGPoint)position {
    [self setPosition:position flags:0];
}

- (void)removeFromSuperlayer {
    [_grid removeObject:self];
    [_path removeFromSuperlayer];
    [super removeFromSuperlayer];
    
    for (NVTNode *item in _node.children) {
        if (item.drawer) {
            [_grid removeObject:item.drawer];
            [item.drawer removeFromSuperlayer];
        }
    }
}

@end
