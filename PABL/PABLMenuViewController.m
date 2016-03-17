//
//  PABLMenuViewController.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 9..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLMenuViewController.h"
#import "Common.h"
#import "PhotoManager.h"

#define MAPVIEW_HEIGHT 320.0f

@interface PABLMenuViewController () <PABLMenuViewDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) PABLMenuView *pablMenuView;
@property (nonatomic, strong) UIView *dimmView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) PABLPhotoView *selectedPhotoView;

@end

@implementation PABLMenuViewController

- (instancetype)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        [self.view setFrame:viewController.view.frame];
        [self.view addSubview:self.pablMenuView];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.dimmView];
        [self.view addSubview:self.mapView];
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
    
    [self.dimmView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [self.dimmView setAlpha:0.0f];
    [self.dimmView setHidden:YES];
    
    [self.mapView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), MAPVIEW_HEIGHT)];
    
    UIView *mapPointView1 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.mapView.frame)/2 - 0.5, CGRectGetHeight(self.mapView.frame)/2 - 15, 1, 30)];
    UIView *mapPointView2 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.mapView.frame)/2 - 15, CGRectGetHeight(self.mapView.frame)/2 - 0.5, 30, 1)];
    [mapPointView1 setBackgroundColor:HEXCOLOR(0x00000088)];
    [mapPointView2 setBackgroundColor:HEXCOLOR(0x00000088)];
    [mapPointView1.layer setCornerRadius:1.0f];
    [mapPointView2.layer setCornerRadius:1.0f];
    [mapPointView1 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [mapPointView2 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.mapView addSubview:mapPointView1];
    [self.mapView addSubview:mapPointView2];
    [self.mapView setRegion:self.mapRegion];
    self.selectedPhotoView = nil;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Touch Action

- (void)didActionToCloseDimmView {
    [UIView animateWithDuration:0.3f animations:^{
        [self.dimmView setAlpha:0.0f];
        [self.mapView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), MAPVIEW_HEIGHT)];
    } completion:^(BOOL finished) {
        [self.dimmView setHidden:YES];
    }];
}

- (void)didSwipeUpDimmView {
    PABLPhoto *pablPhoto = (PABLPhoto *)self.photoArray[self.selectedPhotoView.index];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:pablPhoto.photoData];
        request.location =  [[CLLocation alloc]initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success == YES) {
            [self.photoArray removeObject:pablPhoto];
        }
    }];
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.mapView setFrame:CGRectMake(0, TITLEVIEW_HEIGHT + 10.0f, CGRectGetWidth(self.view.frame), MAPVIEW_HEIGHT)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15f animations:^{
            [self.dimmView setAlpha:0.0f];
            [self.mapView setFrame:CGRectMake(0, TITLEVIEW_HEIGHT + MAPVIEW_HEIGHT/2, CGRectGetWidth(self.view.frame), 2)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15f animations:^{
                [self.mapView setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 1, TITLEVIEW_HEIGHT + MAPVIEW_HEIGHT/2, 10, 2)];
            } completion:^(BOOL finished) {
                [self.dimmView setHidden:YES];
                [self.mapView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), MAPVIEW_HEIGHT)];
                [self.pablMenuView removePhotoWithIndex:self.selectedPhotoView.index];
                self.selectedPhotoView = nil;
            }];
        }];
    }];
}

#pragma mark - PABLMenuViewDelegate

- (void)didTouchedPhotoViewWithPhotoView:(PABLPhotoView *)photoView {
    [self.dimmView setHidden:NO];
    [UIView animateWithDuration:0.3f animations:^{
        [self.dimmView setAlpha:1.0f];
        [self.mapView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - MAPVIEW_HEIGHT, CGRectGetWidth(self.view.frame), MAPVIEW_HEIGHT)];
    }];
    self.selectedPhotoView = photoView;
}

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

- (UIView *)dimmView {
    if (_dimmView == nil) {
        _dimmView = [[UIView alloc]init];
        [_dimmView setBackgroundColor:HEXCOLOR(0x000000AA)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didActionToCloseDimmView)];
        UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didSwipeUpDimmView)];
        [swipeUpGesture setDirection:UISwipeGestureRecognizerDirectionUp];
        UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didActionToCloseDimmView)];
        [swipeDownGesture setDirection:UISwipeGestureRecognizerDirectionDown];
        [_dimmView addGestureRecognizer:tapGesture];
        [_dimmView addGestureRecognizer:swipeUpGesture];
        [_dimmView addGestureRecognizer:swipeDownGesture];
    }
    return _dimmView;
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
