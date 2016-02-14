//
//  PABLMenuViewController.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 9..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLMenuViewController.h"

@interface PABLMenuViewController () <PABLMenuViewDelegate>

@property (nonatomic, strong) PABLMenuView *pablMenuView;

@end

@implementation PABLMenuViewController

- (instancetype)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        [self.view setFrame:viewController.view.frame];
        [self.view addSubview:self.pablMenuView];
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)closeMenuViewController {
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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pablMenuView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pablMenuView setAlpha:0.0f];
    [UIView animateWithDuration:0.3f animations:^{
        [self.pablMenuView setAlpha:1.0f];
    }];
}

#pragma mark - PABLMenuViewDelegate

- (void)didTouchedCloseButton {
    [self closeMenuViewController];
}

#pragma mark - generators

- (PABLMenuView *)pablMenuView {
    if (_pablMenuView == nil) {
        _pablMenuView = [[PABLMenuView alloc]init];
        [_pablMenuView setDelegate:self];
    }
    return _pablMenuView;
}


@end
