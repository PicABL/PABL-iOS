//
//  ViewController.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 6..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "ViewController.h"
#import "PABLMenuViewController.h"

#define MENU_BUTTON_SIZE 40.0f
#define MENU_BUTTON_PADDING 20.0f
#define TITLE_VIEW_HEIGHT 40.0f
#define ALERT_LABEL_WIDTH 200.0f
#define ALERT_LABEL_HEIGHT 10.0f

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, PABLMenuViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *welcomeView;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *menuSpreadButton;
@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) PABLMenuViewController *menuView;

@property (nonatomic, assign) BOOL isMine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isMine = YES;
    
    [self.view addSubview:self.mapView];
    [self.mapView addSubview:self.menuSpreadButton];
    [self.mapView addSubview:self.animationView];
    [self.mapView addSubview:self.titleView];
    [self.titleView addSubview:self.titleLabel];
    [self.view addSubview:self.welcomeView];
    
    CGRect welcomeViewFrame = self.view.frame;
    CGRect mapViewFrame = self.view.frame;
    CGRect titleViewFrame = CGRectMake(0, 0, CGRectGetWidth(mapViewFrame),TITLE_VIEW_HEIGHT);
    CGRect titleLabelFrame = CGRectMake(0,
                                        [[UIApplication sharedApplication] statusBarFrame].size.height,
                                        CGRectGetWidth(mapViewFrame),
                                        TITLE_VIEW_HEIGHT - [[UIApplication sharedApplication] statusBarFrame].size.height);
    CGRect menuSpreadButtonFrame = CGRectMake(CGRectGetMaxX(mapViewFrame) - MENU_BUTTON_SIZE - MENU_BUTTON_PADDING,
                                              CGRectGetMaxY(mapViewFrame) - MENU_BUTTON_SIZE - MENU_BUTTON_PADDING,
                                              MENU_BUTTON_SIZE,
                                              MENU_BUTTON_SIZE);
    
    [self.mapView setFrame:mapViewFrame];
    [self.menuSpreadButton setFrame:menuSpreadButtonFrame];
    [self.welcomeView setFrame:welcomeViewFrame];
    [self.titleView setFrame:titleViewFrame];
    [self.titleLabel setFrame:titleLabelFrame];
    
    [self.menuSpreadButton.layer setCornerRadius:MENU_BUTTON_SIZE/2];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(dismissWelcomeView) userInfo:nil repeats:NO];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(menuSpreadButtonTouched)];
    [self.menuSpreadButton addGestureRecognizer:tapGesture];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressTest:)];
    [self.menuSpreadButton addGestureRecognizer:longPressGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isMine) {
        [self setTitleNameWithString:@"Mine"];
    }
}

- (void)dismissWelcomeView {
    [UIView animateWithDuration:0.5f animations:^{
        [self.welcomeView setAlpha:0.0f];
    }];
}

- (void)setTitleNameWithString:(NSString *)titleName {
    [self.titleLabel setText:titleName];
}

#pragma mark - touch event

- (void)longPressTest:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint menuCenter = CGPointMake(CGRectGetWidth(self.mapView.frame)/2, CGRectGetHeight(self.mapView.frame)/2);
        [self.animationView setFrame:CGRectMake(menuCenter.x, menuCenter.y - 1, 0, 2)];
        [UIView animateWithDuration:0.3f animations:^{
            [self.menuSpreadButton setCenter:menuCenter];
        } completion:^(BOOL finished) {
            CGRect animationViewFrame = self.animationView.frame;
            animationViewFrame.origin.x = 0;
            animationViewFrame.size.width = self.mapView.frame.size.width;
            [UIView animateWithDuration:0.5f animations:^{
                [self.animationView setFrame:animationViewFrame];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f animations:^{
                    [self.animationView setFrame:self.mapView.frame];
                } completion:^(BOOL finished){
                    [self presentViewController:self.menuView animated:NO completion:^{
                    }];
                }];
            }];
        }];
    }
}

- (void)menuSpreadButtonTouched {
    if (self.isMine == NO) {
        CGPoint menuCenter = CGPointMake(CGRectGetWidth(self.mapView.frame)/2, CGRectGetHeight(self.mapView.frame)/2);
        [self.animationView setFrame:CGRectMake(menuCenter.x, menuCenter.y - 1, 0, 2)];
        [UIView animateWithDuration:0.3f animations:^{
            [self.menuSpreadButton setCenter:menuCenter];
        } completion:^(BOOL finished) {
            CGRect animationViewFrame = self.animationView.frame;
            animationViewFrame.origin.x = 0;
            animationViewFrame.size.width = self.mapView.frame.size.width;
            [UIView animateWithDuration:0.5f animations:^{
                [self.animationView setFrame:animationViewFrame];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f animations:^{
                    [self.animationView setFrame:self.mapView.frame];
                } completion:^(BOOL finished){
                    [self presentViewController:self.menuView animated:NO completion:^{
                    }];
                }];
            }];
        }];
    } else {
        UILabel *alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.mapView.frame) - ALERT_LABEL_WIDTH,
                                                                       CGRectGetMinY(self.menuSpreadButton.frame) - ALERT_LABEL_HEIGHT,
                                                                       ALERT_LABEL_WIDTH,
                                                                       ALERT_LABEL_HEIGHT)];
        [alertLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:10.0f]];
        [alertLabel setTextColor:[UIColor blackColor]];
        [alertLabel setBackgroundColor:[UIColor clearColor]];
        [alertLabel setText:@"Your pictures are already added!"];
        [alertLabel setAlpha:0.0f];
        [self.mapView addSubview:alertLabel];
        CGRect alertLabelMoveFrame = alertLabel.frame;
        alertLabelMoveFrame.origin.y -= ALERT_LABEL_HEIGHT;
        [UIView animateWithDuration:0.5f animations:^{
            [alertLabel setAlpha:1.0f];
            [alertLabel setFrame:alertLabelMoveFrame];
        } completion:^(BOOL finished) {
            CGRect alertLabelMoveFrame = alertLabel.frame;
            alertLabelMoveFrame.origin.y -= ALERT_LABEL_HEIGHT;
            [UIView animateWithDuration:0.5f animations:^{
                [alertLabel setAlpha:0.0f];
                [alertLabel setFrame:alertLabelMoveFrame];
            } completion:^(BOOL finished) {
                [alertLabel removeFromSuperview];
            }];
        }];
    }
}


#pragma mark - PABLMenuViewControllerDelegate

- (void)PABLMenuViewControllerDidTouchCloseButton {
    CGPoint menuCenter = CGPointMake(CGRectGetWidth(self.mapView.frame)/2, CGRectGetHeight(self.mapView.frame)/2);
    CGRect animationViewFrame = self.animationView.frame;
    animationViewFrame.origin.y = menuCenter.y - 1;
    animationViewFrame.size.height = 2;
    [UIView animateWithDuration:0.3f animations:^{
        [self.animationView setFrame:animationViewFrame];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            [self.animationView setFrame:CGRectMake(menuCenter.x, menuCenter.y - 1, 0, 2)];
        } completion:^(BOOL finished) {
            CGRect menuSpreadButtonFrame = CGRectMake(CGRectGetMaxX(self.mapView.frame) - MENU_BUTTON_SIZE - MENU_BUTTON_PADDING,
                                                      CGRectGetMaxY(self.mapView.frame) - MENU_BUTTON_SIZE - MENU_BUTTON_PADDING,
                                                      MENU_BUTTON_SIZE,
                                                      MENU_BUTTON_SIZE);
            [UIView animateWithDuration:0.3f animations:^{
                [self.menuSpreadButton setFrame:menuSpreadButtonFrame];
            } completion:^(BOOL finished) {
            }];
        }];
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.menuView closeMenuViewController];
}


#pragma mark - Generators

- (UIView *)welcomeView {
    if (_welcomeView == nil) {
        _welcomeView = [[UIView alloc]init];
        [_welcomeView setBackgroundColor:HEXCOLOR(0x5CD1E5FF)];
    }
    return _welcomeView;
}

- (UIView *)titleView {
    if (_titleView == nil) {
        _titleView = [[UIView alloc]init];
        [_titleView setBackgroundColor:HEXCOLOR(0x000000FF)];
        [_titleView setAlpha:0.4f];
    }
    return _titleView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]init];
        [_titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0f]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setNumberOfLines:1];
    }
    return _titleLabel;
}

- (UIView *)menuSpreadButton {
    if (_menuSpreadButton == nil) {
        _menuSpreadButton = [[UIView alloc]init];
        [_menuSpreadButton.layer setBorderWidth:0.5f];
        [_menuSpreadButton.layer setBorderColor:[UIColor blackColor].CGColor];
        [_menuSpreadButton setBackgroundColor:HEXCOLOR(0x5CD1E5FF)];
    }
    return _menuSpreadButton;
}

- (MKMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc]init];
        [_mapView setDelegate:self];
    }
    return _mapView;
}

- (PABLMenuViewController *)menuView {
    if(_menuView == nil) {
        _menuView = [[PABLMenuViewController alloc]initWithViewController:self];
        [_menuView setDelegate:self];
        [_menuView setPABLDelegate:self];
        [_menuView setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    return _menuView;
}

- (UIView *)animationView {
    if (_animationView == nil) {
        _animationView = [[UIView alloc]init];
        [_animationView setBackgroundColor:HEXCOLOR(0x000000FF)];
    }
    return _animationView;
}

@end
