//
//  ViewController.m
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import "ViewController.h"
#import "NVTreeNode.h"
#import "NVTreeDrawer.h"

@interface ViewController () <UIGestureRecognizerDelegate> {
    NVTreeNode *_root;
    CGFloat _deltaScale;
    CGPoint _deltaMove;
    NVTreeDrawer *_selected;
}

@end

@implementation ViewController

CGAffineTransform makeTransform(CGFloat xScale, CGFloat yScale,
                                CGFloat theta, CGFloat tx, CGFloat ty)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform.a = xScale * cos(theta);
    transform.b = yScale * sin(theta);
    transform.c = xScale * -sin(theta);
    transform.d = yScale * cos(theta);
    transform.tx = tx;
    transform.ty = ty;
    
    return transform;
}

- (void)panned:(UIPanGestureRecognizer*)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CALayer *target = [self.view.layer hitTest:location];

        if ([target isKindOfClass:[NVTreeDrawer class]]) {
            _selected = (NVTreeDrawer*)target;
            _deltaMove = _selected.position;
        }
        else if ([target isKindOfClass:[CATextLayer class]]) {
            _selected = (NVTreeDrawer*)target.superlayer;
            _deltaMove = _selected.position;
        }
        else _deltaMove = CGPointMake(0, 0); // for translate
        
        _deltaMove = CGPointMake(_deltaMove.x - location.x, _deltaMove.y - location.y);
        NSLog(@"%@, %@", @"began", target);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        _selected = nil;
        NSLog(@"%@", @"end");
    }
    else {
        CGPoint point = CGPointMake(location.x + _deltaMove.x, location.y + _deltaMove.y);
    
        if (_selected) {
            _selected.position = point;
        }
        else {
            self.view.transform = CGAffineTransformTranslate(self.view.transform, point.x, point.y);
        }
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"gesturePanNotify" object:@{ @"state": [NSNumber numberWithInt: recognizer.state], @"value": [NSValue valueWithCGPoint:location]}];
}

- (void)pinched:(UIPinchGestureRecognizer*)recognizer {
    CGAffineTransform p = self.view.transform; //previus transformation
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _deltaScale = sqrt(p.a * p.a + p.c * p.c);//, sqrt(t.b * t.b + t.d * t.d));
    }
    
    CGFloat scale = recognizer.scale * _deltaScale;
    if (scale < 1.0)
        scale = 1.0;
    
    //self.view.transform = CGAffineTransformScale(self.view.transform, scale, scale);
    
    self.view.transform = makeTransform(scale, scale, 0, p.tx, p.ty);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    
    NSDictionary *treeDic = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Basic Tree" withExtension:@"plist"]];
    _root = [[NVTreeNode alloc] initWithDictionary:treeDic onCreateNode:nil];
    
    [[[NVTreeDrawer alloc] initWithNode:_root] drawTopToBottomInLayer:self.view.layer inPoint:CGPointMake(CGRectGetWidth(self.view.frame) / 2.0, 40.0)];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
