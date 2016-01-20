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
    NVTree *_tree;
    CGPoint _deltaMove;
    CGPoint _deltaOffset;
    NVTreeDrawer *_selected;
    //NVGrid *_grid;
    NVItemPropertyView *_itemProp;
    UITextField *_textField;
    //NVStateControllerEnum _state;
    NSMutableArray<id<NVStrategyDraw>> *_strategies;
    
    UIView *_rootView;
    IBOutlet UIScrollView *_scrollView;
    
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
        [_tree.root.delegate removeFromSuperlayer];
        //[_grid clear];
        
        _tree = [NSKeyedUnarchiver unarchiveObjectWithData:mindMap];
    }
    
    
    NVTreeDrawer *drawer = [[NVTreeDrawer alloc] initWithNode:_tree.root onLayer:_rootView.layer /*withGrid:_grid*/];
    
    drawer.strategy = _strategies.firstObject;
    
    if (!mindMap) {
        [_strategies.firstObject update:drawer];
    }
}

- (IBAction)panned:(UIPanGestureRecognizer *)sender {
    CGPoint location = [self locationFrom:sender];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self actionWith:sender state:NVS_MOVE_NODE isStart:YES];
    }
    else if (sender.state == UIGestureRecognizerStateEnded ||
             sender.state == UIGestureRecognizerStateCancelled) {
        [self actionWith:sender state:NVS_MOVE_NODE isStart:NO];
    }
    else if (_selected) {
        _selected.position = VAdd(location, _deltaMove);
        //[_selected setPosition:VAdd(location, _deltaMove) flags:0];
        [self updateSize];
    }
}

- (void)updateSize {
    CGRect r = [NVTreeDrawer bounds];
    _rootView.bounds = r;
    _scrollView.contentSize = r.size;
    _rootView.center = V(r.size.width / 2, r.size.height / 2);
    
    if (_selected);
        //_scrollView.contentOffset = VAdd(_selected.position, _deltaOffset);
}

- (IBAction)longPressed:(UILongPressGestureRecognizer *)sender {
}

- (IBAction)tapped:(UITapGestureRecognizer *)sender {
    [self actionWith:sender state:NVS_PROPERTY isStart:YES];
}

- (IBAction)doubleTapped:(UITapGestureRecognizer *)sender {
    [self actionWith:sender state:NVS_RENAME isStart:YES];
}

- (CGPoint)locationFrom:(UIGestureRecognizer*)sender {
    CGPoint point = [sender locationInView:_scrollView];
    if (_scrollView.zoomScale != 1.0) {
        point = VDivN(point, _scrollView.zoomScale);
    }
    return point;
}

- (void)actionWith: (UIGestureRecognizer*)sender state:(NVStateControllerEnum)state isStart:(BOOL)start {
    if (sender.view == _itemProp)
        return;
    
    CGPoint location = [self locationFrom: sender];
    NVTreeDrawer *target = [self getTarget: sender];
    
    _itemProp.hidden = YES;
    
    switch (state) {
        case NVS_RENAME:
            if (start) {
                if (target) {
                    _textField.text = target.node.value;
                    _textField.center = target.position;
                    [_rootView bringSubviewToFront:_textField];
                    _textField.hidden = NO;
                    target.label.hidden = YES;
                    [_textField becomeFirstResponder];
                    _selected = target;
                }
            } else {
                _selected.label.string = _textField.text;
                _selected.label.hidden = NO;
                _textField.hidden = YES;
                _selected.node.value = _textField.text;
                [_textField resignFirstResponder];
                _selected = nil;
            }
            break;
        case NVS_MOVE_HIERARCHY:
            break;
        case NVS_MOVE_NODE:
            if (!_textField.hidden && _selected)
                [self actionWith:sender state:NVS_RENAME isStart:NO];
            
            if (start) {
                if ((_selected = target)) {
                    _deltaMove = VSub(_selected.position, location);
                    _deltaOffset = VSub(_scrollView.contentOffset, _selected.position);
                }
            }
            else _selected = nil;
            
            break;
        case NVS_PROPERTY:
            if (!_textField.hidden && _selected)
                [self actionWith:sender state:NVS_RENAME isStart:NO];
            
            if (target) {
                _itemProp.hidden = NO;
                [_rootView bringSubviewToFront:_itemProp];
                _itemProp.center = target.position;
                _itemProp.isExpend = !target.isRollUp;
                
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
                
                _itemProp.onHideTap = ^{
                    target.isRollUp = YES;
                };
                _itemProp.onShowTap = ^{
                    target.isRollUp = NO;
                };
            }
            break;
        default:
            break;
    }
}

- (NVTreeDrawer*)getTarget: (UIGestureRecognizer*)sender {
    CALayer *target = [_rootView.layer hitTest:[sender locationInView:self.view]];

    if ([target isKindOfClass:[NVTreeDrawer class]])
        return (NVTreeDrawer*)target;
    else if ([target isKindOfClass:[CATextLayer class]])
        return (NVTreeDrawer*)target.superlayer;
    
    return nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (gestureRecognizer == _panRecognizer &&
        [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (_panRecognizer.state == UIGestureRecognizerStateBegan) {
            if ([self getTarget: _panRecognizer])
                return NO;
        }
        
        if (!_selected) {
            return YES;
        }
    }
    
    return NO;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _rootView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat scale = scrollView.zoomScale;
    CGSize size = _rootView.bounds.size;
    scrollView.contentSize = CGSizeMake(size.width * scale, size.height * scale);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
    _rootView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_rootView];
 
    [_tapRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];
    
    self.navigationItem.titleView = [[UISegmentedControl alloc] initWithItems:@[@"Top to bottom", @"Custom"]];
    
    //_grid = [[NVGrid alloc] init];
    //CGFloat cellSize = M_SQRT2 * 50;
    //_grid.cellSize = CGSizeMake(cellSize, cellSize);
    
    _strategies = [[NSMutableArray alloc] init];
    [_strategies addObject: [[NVStrategyDraw alloc] initWithStart:V(CGRectGetWidth(_rootView.bounds) / 2.0, _rootView.frame.origin.y + 50) /*withGrid:_grid*/]];
    
    [self onLoad:nil];
    [self updateSize];
    
    NVTreeDrawer *rootDrawer = _tree.root.delegate;
    
    _itemProp = [[NVItemPropertyView alloc] initWithFrame:rootDrawer.frame];
    _itemProp.hidden = YES;
    [_rootView addSubview:_itemProp];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.textAlignment = NSTextAlignmentCenter;
    NSString *fontName = (__bridge NSString *)rootDrawer.label.font;
    _textField.font = [UIFont fontWithName:fontName size:rootDrawer.label.fontSize];
    _textField.hidden = YES;
    [_rootView addSubview:_textField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self onSave:nil];
    // Dispose of any resources that can be recreated.
}

@end
