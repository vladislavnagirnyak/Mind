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
#import "CGAffineTransformHelper.hpp"
#import "NVGrid.h"
#import "NVItemPropertyView.h"

typedef enum : NSUInteger {
    NVS_RENAME,
    NVS_MOVE_HIERARCHY,
    NVS_MOVE_NODE,
    NVS_PROPERTY,
} NVStateControllerEnum;

@interface ViewController () <UIGestureRecognizerDelegate> {
    NVTreeNode *_root;
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
    CGPoint location = [recognizer locationInView:self.view];
    NVTreeDrawer *target = [self getTargetByPos:location];
    
    _itemProp.hidden = YES;
    
    switch (state) {
        case NVS_RENAME:
            if (start) {
                if (recognizer.state == UIGestureRecognizerStateBegan) {
                    if (!_textField.hidden && _selected)
                        [self actionWith:recognizer state:NVS_RENAME isStart:NO];
                    
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
                
                if ((_selected = target))
                    _deltaMove = _selected.position;
                else _deltaMove = CGPointMake(0, 0); // for translate
                
                _deltaMove = CGPointMake(_deltaMove.x - location.x, _deltaMove.y - location.y);
            }
            else _selected = nil;
            
            break;
        case NVS_PROPERTY:
            if (target) {
                _itemProp.hidden = NO;
                [self.view bringSubviewToFront:_itemProp];
                _itemProp.center = target.position;
                
                _itemProp.onAddTap = ^{
                    [target addChild];
                };
                
                __weak typeof(_itemProp) wProp = _itemProp;
                
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
    [self actionWith:recognizer state:NVS_RENAME isStart:YES];
}

- (void)tapped:(UITapGestureRecognizer*)recognizer {
    [self actionWith:recognizer state:NVS_RENAME isStart:NO];
}

- (NVTreeDrawer*)getTargetByPos: (CGPoint)position {
    CALayer *target = [self.view.layer hitTest:position];
    
    if ([target isKindOfClass:[NVTreeDrawer class]])
        return (NVTreeDrawer*)target;
    else if ([target isKindOfClass:[CATextLayer class]])
        return (NVTreeDrawer*)target.superlayer;
    
    return nil;
}

- (void)doubleTapped:(UITapGestureRecognizer*)recognizer {
    [self actionWith:recognizer state:NVS_PROPERTY isStart:0];
}

- (void)panned:(UIPanGestureRecognizer*)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    //location = CGPointApplyAffineTransform(location, self.view.transform);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self actionWith:recognizer state:NVS_MOVE_NODE isStart:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        [self actionWith:recognizer state:NVS_MOVE_NODE isStart:NO];
    }
    else {
        CGPoint point = CGPointMake(location.x + _deltaMove.x, location.y + _deltaMove.y);
    
        if (_selected) {
            [_selected setPosition:point flags:0];
        }
        else {
            CGRect frame = self.view.frame;
            
            self.view.transform = CGAffineTransformTranslate(self.view.transform, point.x, point.y);
        }
    }
}

- (void)pinched:(UIPinchGestureRecognizer*)recognizer {
    CGAffineTransformHelper p = CGAffineTransformHelper(self.view.transform); //previus transformation
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _deltaScale = p.getScale().x;
    }
    
    CGFloat scale = recognizer.scale * _deltaScale;
    if (scale < 1.0)
        scale = 1.0;
    
    p.setScale(CGPointMake(scale, scale));
    self.view.transform = p;
}

- (void)rotated:(UIRotationGestureRecognizer*)recognizer {
    CGAffineTransformHelper p = CGAffineTransformHelper(self.view.transform);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _deltaRotate = p.getRotation();
    }
    
    p.setRotation(recognizer.rotation + _deltaRotate);
    self.view.transform = p;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotated:)];
    rotation.delegate = self;
    [self.view addGestureRecognizer:rotation];
    
    NSDictionary *treeDic = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Basic Tree" withExtension:@"plist"]];
    _root = [[NVTreeNode alloc] initWithDictionary:treeDic];
    
    _grid = [[NVTreeGrid alloc] init];
    _grid.cellSize = CGSizeMake(100, 100);
    
    _rootDrawer = [[NVTreeDrawer alloc] initWithNode:_root onLayer:self.view.layer withGrid:_grid];
    
    [_rootDrawer drawTopToBottom:CGPointMake(CGRectGetWidth(self.view.frame) / 2.0, 50.0)];
    
    _itemProp = [[NVItemPropertyView alloc] initWithFrame:_rootDrawer.frame];
    _itemProp.hidden = YES;
    [self.view addSubview:_itemProp];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.textAlignment = NSTextAlignmentCenter;
    _textField.font = [_textField.font fontWithSize:_rootDrawer.label.fontSize];
    [self.view addSubview:_textField];
    _textField.hidden = YES;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
