//
//  PABLMenuViewController.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 9..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLMenuViewController.h"

@interface PABLMenuViewController () <PABLMenuViewDelegate, MKMapViewDelegate>

@property (nonatomic, strong) PABLMenuView *pablMenuView;
@property (nonatomic, strong) MKMapView *mapView;

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
    [self.pablMenuView prepareToLoad];
    self.pablMenuView.photoCount = self.photoArray.count;
    
    NSInteger num = 0;
    for (PABLPhoto *photo in self.photoArray) {
        [self.pablMenuView addPhotoToTopOfView:photo withIndex:num];
        num++;
        if (num > 10) break;
    }

    [self.pablMenuView setAlpha:0.0f];
    [UIView animateWithDuration:0.3f animations:^{
        [self.pablMenuView setAlpha:1.0f];
    }];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - PABLMenuViewDelegate

- (void)didTouchedCloseButton {
    [self closeMenuViewController];
}

- (PABLPhoto *)getPhotoWithIndex:(NSInteger)index {
    if (index < 0) return nil;
    if (index > self.photoArray.count - 1) return nil;
    return self.photoArray[index];
}

#pragma mark - generators

- (PABLMenuView *)pablMenuView {
    if (_pablMenuView == nil) {
        _pablMenuView = [[PABLMenuView alloc]init];
        [_pablMenuView setDelegate:self];
    }
    return _pablMenuView;
}

- (MKMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc]init];
        [_mapView setDelegate:self];
        [_mapView setRotateEnabled:NO];
    }
    return _mapView;
}

@end
