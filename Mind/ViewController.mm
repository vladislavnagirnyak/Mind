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
    NVS_MOVE_NODE,
    NVS_PROPERTY,
} NVStateControllerEnum;

@interface ViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
    NVTree *_tree;
    CGPoint _deltaMove;
    //CGPoint _deltaOffset;
    NVTreeDrawer *_selected;
    //NVGrid *_grid;
    NVItemPropertyView *_itemProp;
    UITextField *_textField;
    NSMutableDictionary<NSString*, id<NVStrategyDraw>> *_strategies;
    NSString *_currentStrategy;
    
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
    
    
    [[NVTreeDrawer alloc] initWithNode:_tree.root onLayer:_rootView.layer /*withGrid:_grid*/];
}

- (IBAction)changeStrategyTap:(UIBarButtonItem *)sender {
    _currentStrategy = sender.title;
    [[_strategies objectForKey:_currentStrategy] update:_tree.root.delegate];
    [self updateSize];
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
    if (_scrollView.zoomScale != 1.0)
        return;
    
    __block CGPoint min = V(FLT_MAX, FLT_MAX);
    __block CGPoint max = V(FLT_MIN, FLT_MIN);
    
    [_tree.root foreach:^BOOL(NVNode *node) {
        NVTreeDrawer *item = node.delegate;
        CGPoint pos = item.position;
        CGFloat margin = item.radius;
        
        if (pos.x - margin < min.x) {
            min.x = pos.x - margin;
        }
            
        if (pos.y - margin < min.y) {
            min.y = pos.y - margin;
        }
        
        if (pos.x + margin > max.x) {
            max.x = pos.x + margin;
        }
        
        if (pos.y + margin > max.y) {
            max.y = pos.y + margin;
        }
        
        return YES;
    }];
    
    CGRect b = CGRectMake(min.x, min.y, max.x - min.x, max.y - min.y);
    CGRect pb = _rootView.bounds;
    _rootView.bounds = b;
    _scrollView.contentSize = b.size;
    _rootView.center = V(b.size.width / 2, b.size.height / 2);
    
    /*if (_selected) {
        CGPoint offset = _scrollView.contentOffset;
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        if (b.origin.x + b.size.width > pb.origin.x + pb.size.width) {
            offset.x = b.size.width - screenBounds.size.width;
        }
        
        if (b.origin.y + b.size.height > pb.origin.y + pb.size.height) {
            offset.y = b.size.height - screenBounds.size.height;
        }
        
        //_scrollView.contentOffset = offset;
        [_scrollView setContentOffset:offset animated:YES];
    }*/
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
        case NVS_MOVE_NODE:
            if (!_textField.hidden && _selected)
                [self actionWith:sender state:NVS_RENAME isStart:NO];
            
            if (start) {
                if ((_selected = target)) {
                    _deltaMove = VSub(_selected.position, location);
                    //_deltaOffset = VSub(_scrollView.contentOffset, _selected.position);
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
                    NVNode *child = [[NVNode alloc] initWithParent:target.node];
                    
                    NVTreeDrawer *childDrawer = [[NVTreeDrawer alloc] initWithNode:child onLayer:_rootView.layer /*withGrid:_grid*/];
                    
                    [_strategies[_currentStrategy] addChild:childDrawer];
                    
                    //wProp.hidden = YES;
                    [self updateSize];
                };
                
                _itemProp.onRemoveTap = ^{
                    [target removeFromSuperlayer];
                    [target.node remove];
                    [self updateSize];
                    
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
    
    _rootView = [[UIView alloc] init];
    _rootView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_rootView];
 
    [_tapRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];
    
    //_grid = [[NVGrid alloc] init];
    //CGFloat cellSize = M_SQRT2 * 50;
    //_grid.cellSize = CGSizeMake(cellSize, cellSize);
    
    _strategies = [[NSMutableDictionary alloc] init];
    [_strategies setObject:[[NVStrategyDrawTopToBottom alloc] initWithStart:V(CGRectGetWidth(_rootView.bounds) / 2.0, _rootView.frame.origin.y + 50) /*withGrid:_grid*/] forKey:@"Top to bottom"];
    
    [_strategies setObject:[[NVStrategyDrawCircle alloc] init] forKey: @"Circle"];
    _currentStrategy = _strategies.allKeys.firstObject;
    
    [self onLoad:nil];
    [self updateSize];
    
    NVTreeDrawer *rootDrawer = _tree.root.delegate;
    
    _itemProp = [[NVItemPropertyView alloc] initWithFrame:CGRectMake(0, 0, 128, 42)];
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
