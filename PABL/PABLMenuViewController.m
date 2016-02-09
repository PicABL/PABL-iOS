//
//  PABLMenuViewController.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 9..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLMenuViewController.h"
#import "PABLMenuView.h"

@interface PABLMenuViewController ()

@property (nonatomic, strong) PABLMenuView *pablMenuView;

@end

@implementation PABLMenuViewController

- (instancetype)initWithViewCOntroller:(UIViewController *)viewController {
    if (self = [super init]) {
        [self.view setFrame:viewController.view.frame];
        [self.view addSubview:self.pablMenuView];
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.pablMenuView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(PABLMenuViewControllerDidTouchCloseButton)]) {
                    [self.delegate PABLMenuViewControllerDidTouchCloseButton];
                }
            }];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.pablMenuView setFrame:self.view.frame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pablMenuView setAlpha:0.0f];
    [UIView animateWithDuration:0.3f animations:^{
        [self.pablMenuView setAlpha:1.0f];
    }];
}

- (PABLMenuView *)pablMenuView {
    if (_pablMenuView == nil) {
        _pablMenuView = [[PABLMenuView alloc]init];
    }
    return _pablMenuView;
}

@end
