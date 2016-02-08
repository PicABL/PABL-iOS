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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.pablMenuView setFrame:self.view.frame];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (PABLMenuView *)pablMenuView {
    if (_pablMenuView == nil) {
        _pablMenuView = [[PABLMenuView alloc]init];
    }
    return _pablMenuView;
}

@end
