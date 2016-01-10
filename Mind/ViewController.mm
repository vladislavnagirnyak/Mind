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

@interface ViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate> {
    UIView *_rootView;
    NVTree *_tree;
    CGFloat _deltaScale;
    CGFloat _deltaRotate;
    CGPoint _deltaMove;
    NVTreeDrawer *_selected;
    NVGrid *_grid;
    NVItemPropertyView *_itemProp;
    UITextField *_textField;
    NVStateControllerEnum _state;
    id<NVStrategyDraw> _strategy;
    
    IBOutlet UITapGestureRecognizer *_tapRecognizer;
    IBOutlet UITapGestureRecognizer *_doubleTapRecognizer;
    IBOutlet UIPanGestureRecognizer *_panRecognizer;
}

@end

@implementation ViewController

- (IBAction)onSave:(UIBarButtonItem *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *mindMap = [NSKeyedArchiver archivedDataWithRootObject:_tree];
    [defaults setObject:mindMap forKey:@"MindMapTree"];
    [defaults synchronize];
}

- (IBAction)onLoad:(UIBarButtonItem *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *mindMap = [defaults objectForKey:@"MindMapTree"];
    if (!mindMap) {
        _tree = [[NVTree alloc] initWithRoot:[[NVNode alloc] init]];
    } else {
        [_tree.root.drawer removeFromSuperlayer];
        [_grid clear];
        
        _tree = [NSKeyedUnarchiver unarchiveObjectWithData:mindMap];
    }
    
    NVTreeDrawer *drawer = [[NVTreeDrawer alloc] initWithNode:_tree.root onLayer:_rootView.layer withGrid:_grid];
    
    drawer.strategy = _strategy;
    
    if (!mindMap) {
        [_strategy draw:drawer];
    }
}

- (IBAction)pinched:(UIPinchGestureRecognizer *)sender {
    CGAffineTransformHelper p = CGAffineTransformHelper(_rootView.layer.affineTransform); //previus transformation
    if (sender.state == UIGestureRecognizerStateBegan) {
        _deltaScale = p.getScale().x;
    }
    
    CGFloat scale = sender.scale * _deltaScale;
    if (scale < 1.0)
        scale = 1.0;
    
    p.setScale(V(scale, scale));
    _rootView.layer.affineTransform = p;
}

- (IBAction)panned:(UIPanGestureRecognizer *)sender {
    CGPoint utsfLocation = [sender locationInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self actionWith:sender state:NVS_MOVE_NODE isStart:YES];
    }
    else if (sender.state == UIGestureRecognizerStateEnded ||
             sender.state == UIGestureRecognizerStateCancelled) {
        [self actionWith:sender state:NVS_MOVE_NODE isStart:NO];
    }
    else if (_selected) {
        CGPoint location = CGPointApplyAffineTransform(utsfLocation, _rootView.transform);
        [_selected setPosition:VAdd(location, _deltaMove) flags:0];
    }
}

- (IBAction)longPressed:(UILongPressGestureRecognizer *)sender {
}

- (IBAction)tapped:(UITapGestureRecognizer *)sender {
    [self actionWith:sender state:NVS_PROPERTY isStart:YES];
}

- (IBAction)doubleTapped:(UITapGestureRecognizer *)sender {
    [self actionWith:sender state:NVS_RENAME isStart:YES];
}

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
                    [target removeFromSuperlayer];
                    [target.node remove];
                    
                    wProp.hidden = YES;
                };
            }
            break;
        default:
            break;
    }
}

- (NVTreeDrawer*)getTargetByPos: (CGPoint)position {
    position = VSub(position, _rootView.layer.bounds.origin);
    CALayer *target = [_rootView.layer hitTest:position];

    if ([target isKindOfClass:[NVTreeDrawer class]])
        return (NVTreeDrawer*)target;
    else if ([target isKindOfClass:[CATextLayer class]])
        return (NVTreeDrawer*)target.superlayer;
    
    return nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == _panRecognizer ||
        otherGestureRecognizer == _panRecognizer) {
        [self panned:_panRecognizer];
        
        if (_selected) {
            return NO;
        }
    }
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_tapRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];
    
    _rootView = self.view;
    
    UIScrollView *scrollView = (UIScrollView*)_rootView;
    scrollView.contentSize = CGSizeMake(1000, 1000);
    
    self.navigationItem.titleView = [[UISegmentedControl alloc] initWithItems:@[@"Top to bottom", @"Custom"]];
    
    _grid = [[NVGrid alloc] init];
    CGFloat cellSize = M_SQRT2 * 50;
    _grid.cellSize = CGSizeMake(cellSize, cellSize);
    
    _strategy = [[NVStrategyDraw alloc] initWithStart:V(CGRectGetWidth(_rootView.frame) / 2.0, 50.0) withGrid:_grid];
    
    [self onLoad:nil];
    
    NVTreeDrawer *rootDrawer = _tree.root.drawer;
    
    _itemProp = [[NVItemPropertyView alloc] initWithFrame:rootDrawer.frame];
    _itemProp.hidden = YES;
    [self.view addSubview:_itemProp];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.textAlignment = NSTextAlignmentCenter;
    NSString *fontName = (__bridge NSString *)rootDrawer.label.font;
    _textField.font = [UIFont fontWithName:fontName size:rootDrawer.label.fontSize];
    [self.view addSubview:_textField];
    _textField.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self onSave:nil];
    // Dispose of any resources that can be recreated.
}

@end
