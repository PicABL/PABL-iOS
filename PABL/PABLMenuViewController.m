//
//  PABLMenuViewController.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 9..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLMenuViewController.h"

@interface PABLMenuViewController ()

@end

@implementation PABLMenuViewController

- (instancetype)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        [self.view setFrame:viewController.view.frame];
    }
    return self;
}

- (void)closeMenuViewController {
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (self.PABLDelegate && [self.delegate respondsToSelector:@selector(PABLMenuViewControllerDidTouchCloseButton)]) {
                [self.PABLDelegate PABLMenuViewControllerDidTouchCloseButton];
            }
        }];
    }];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view setAlpha:0.0f];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setAlpha:1.0f];
    }];
}


@end
