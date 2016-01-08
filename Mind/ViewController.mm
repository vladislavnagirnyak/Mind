//
//  ViewController.m
//  Mind
//
//  Created by Влад Нагирняк on 23.12.15.
//  Copyright © 2015 Влад Нагирняк. All rights reserved.
//

#import "ViewController.h"
#import "NVNode.h"
#import "NVTreeDrawer.h"
#import "CGAffineTransformHelper.hpp"
#import "NVGrid.h"
#import "NVItemPropertyView.h"
#import <CoreGraphics/CoreGraphics.h>
#import "NVStrategyDraw.h"
#import "NVMath.c"
#import "NVTree.h"

typedef enum : NSUInteger {
    NVS_RENAME,
    NVS_MOVE_HIERARCHY,
    NVS_MOVE_NODE,
    NVS_PROPERTY,
} NVStateControllerEnum;

@interface ViewController () <UIGestureRecognizerDelegate> {
    UIScrollView *_rootView;
    NVNode *_root;
    NVTreeDrawer *_rootDrawer;
    CGFloat _deltaScale;
    CGFloat _deltaRotate;
    CGPoint _deltaMove;
    NVTreeDrawer *_selected;
    NVTreeGrid *_grid;
    NVItemPropertyView *_itemProp;
    UITextField *_textField;
    NVStateControllerEnum _state;
}

@end

@implementation ViewController

- (void)actionWith: (UIGestureRecognizer*)recognizer state:(NVStateControllerEnum)state isStart:(BOOL)start {
    CGPoint utsfLocation = [recognizer locationInView:_rootView];
    CGPoint location = CGPointApplyAffineTransform(utsfLocation, _rootView.layer.affineTransform);
    NVTreeDrawer *target = [self getTargetByPos:location];
    
    _itemProp.hidden = YES;
    
    switch (state) {
        case NVS_RENAME:
            if (start) {
                if (!_textField.hidden && _selected)
                   [self actionWith:recognizer state:NVS_RENAME isStart:NO];
                
                if (target) {
                    _textField.hidden = NO;
                    _textField.text = target.node.value;
                    target.label.hidden = YES;
                    _textField.center = target.position;
                    [_textField becomeFirstResponder];
                    [self.view bringSubviewToFront:_textField];
                    _selected = target;
                }
            } else {
                _textField.hidden = YES;
                _selected.label.string = _textField.text;
                _selected.label.hidden = NO;
                _selected.node.value = _textField.text;
                [_textField resignFirstResponder];
                _selected = nil;
            }
            break;
        case NVS_MOVE_HIERARCHY:
            break;
        case NVS_MOVE_NODE:
            if (start) {
                if (!_textField.hidden && _selected) {
                    [self actionWith:recognizer state:NVS_RENAME isStart:NO];
                }
                
                if ((_selected = target)) {
                    _deltaMove = VSub(_selected.position, location);
                } else {
                    CGSize s = _rootView.frame.size;
                    //_deltaMove = CGPointMake(_rootView.contentOffset.x - utsfLocation.x, _rootView.contentOffset.y - utsfLocation.y);
                }
            }
            else _selected = nil;
            
            break;
        case NVS_PROPERTY:
            if (!_textField.hidden && _selected) {
                [self actionWith:recognizer state:NVS_RENAME isStart:NO];
            }
            if (target) {
                _itemProp.hidden = NO;
                [_rootView bringSubviewToFront:_itemProp];
                _itemProp.center = target.position;
                
                __weak typeof(_itemProp) wProp = _itemProp;
                
                _itemProp.onAddTap = ^{
                    [target addChild];
                    wProp.hidden = YES;
                };
                
                _itemProp.onRemoveTap = ^{
                    [target remove];
                    wProp.hidden = YES;
                };
            }
            break;
        default:
            break;
    }
}

- (void)longPressed:(UILongPressGestureRecognizer*)recognizer {
    //[self actionWith:recognizer state:NVS_RENAME isStart:YES];
}

- (void)tapped:(UITapGestureRecognizer*)recognizer {
    [self actionWith:recognizer state:NVS_PROPERTY isStart:YES];
}

- (NVTreeDrawer*)getTargetByPos: (CGPoint)position {
    CALayer *target = [_rootView.layer hitTest:position];
    
    if ([target isKindOfClass:[NVTreeDrawer class]])
        return (NVTreeDrawer*)target;
    else if ([target isKindOfClass:[CATextLayer class]])
        return (NVTreeDrawer*)target.superlayer;
    
    return nil;
}

- (void)doubleTapped:(UITapGestureRecognizer*)recognizer {
    [self actionWith:recognizer state:NVS_RENAME isStart:YES];
}

- (void)panned:(UIPanGestureRecognizer*)recognizer {
    CGPoint utsfLocation = [recognizer locationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self actionWith:recognizer state:NVS_MOVE_NODE isStart:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        [self actionWith:recognizer state:NVS_MOVE_NODE isStart:NO];
    }
    else {
        if (_selected) {
            CGPoint location = CGPointApplyAffineTransform(utsfLocation, self.view.transform);
            [_selected setPosition:VAdd(location, _deltaMove) flags:0];
        }
        else {
            //if (CGRectContainsRect(_rootView.frame, _rootView.bounds)) {
            CGSize s = _rootView.frame.size;
            CGPoint point = CGPointMake(utsfLocation.x - s.width/2 + _deltaMove.x, utsfLocation.y - s.height/2 + _deltaMove.y);
            
            //_rootView.contentOffset = point;
            
            //_rootView.transform = CGAffineTransformTranslate(_rootView.transform, point.x, point.y);
            //} else {
                //self.view.frame = self.view.bounds;
            //}
        }
    }
}

- (void)pinched:(UIPinchGestureRecognizer*)recognizer {
    CGAffineTransformHelper p = CGAffineTransformHelper(_rootView.layer.affineTransform); //previus transformation
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _deltaScale = p.getScale().x;
    }
    
    CGFloat scale = recognizer.scale * _deltaScale;
    if (scale < 1.0)
        scale = 1.0;
    
    p.setScale(V(scale, scale));
    _rootView.layer.affineTransform = p;
}

- (void)rotated:(UIRotationGestureRecognizer*)recognizer {
    CGAffineTransformHelper p = CGAffineTransformHelper(_rootView.layer.affineTransform);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _deltaRotate = p.getRotation();
    }
    
    p.setRotation(recognizer.rotation + _deltaRotate);
    //_rootView.layer.affineTransform = p;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _rootView = (UIScrollView*)self.view;
    _rootView.contentSize = CGSizeMake(1000, 1000);
    _rootView.scrollEnabled = YES;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 1.0;
    [self.view addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];
    
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotated:)];
    rotation.delegate = self;
    [self.view addGestureRecognizer:rotation];
    
    NSDictionary *treeDic = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Basic Tree" withExtension:@"plist"]];

    _root = [[NVNode alloc] initWithDictionary:treeDic withParent:nil];

    _grid = [[NVTreeGrid alloc] init];
    CGFloat cellSize = M_SQRT2 * 50;
    _grid.cellSize = CGSizeMake(cellSize, cellSize);
    
    _rootDrawer = [[NVTreeDrawer alloc] initWithNode:_root onLayer:self.view.layer withGrid:_grid];
    
    NVStrategyDraw *strategy = [[NVStrategyDraw alloc] initWithStart:V(CGRectGetWidth(self.view.frame) / 2.0, 50.0) withGrid:_grid];
    
    _rootDrawer.strategy = strategy;
    [_rootDrawer draw];
    
    _itemProp = [[NVItemPropertyView alloc] initWithFrame:_rootDrawer.frame];
    _itemProp.hidden = YES;
    [self.view addSubview:_itemProp];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.textAlignment = NSTextAlignmentCenter;
    NSString *fontName = (__bridge NSString *)_rootDrawer.label.font;
    _textField.font = [UIFont fontWithName:fontName size:_rootDrawer.label.fontSize];
    [self.view addSubview:_textField];
    _textField.hidden = YES;
    
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NVTree *tree;
    NSData *mindMap = [defaults objectForKey:@"MindMapTree"];
    if (!mindMap) {
        tree = [[NVTree alloc] init];
        tree.root = _root;
        mindMap = [NSKeyedArchiver archivedDataWithRootObject:tree];
        [defaults setObject:mindMap forKey:@"MindMapTree"];
        [defaults synchronize];
    } else {
        tree = [NSKeyedUnarchiver unarchiveObjectWithData:mindMap];
    }
    
    _root = tree.root;*/
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
