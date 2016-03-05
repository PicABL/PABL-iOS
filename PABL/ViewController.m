//
//  ViewController.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 6..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "ViewController.h"
#import "PABLMenuViewController.h"
#import "PABLPhoto.h"
#import "PABLPointAnnotation.h"
#import "PABLThumbnailView.h"
#import "PABLDetailScrollView.h"

#define MENU_BUTTON_SIZE 40.0f
#define MENU_BUTTON_PADDING 20.0f
#define TITLE_VIEW_HEIGHT 60.0f
#define ALERT_LABEL_WIDTH 200.0f
#define ALERT_LABEL_HEIGHT 10.0f
#define PILE_LENGTH 70.0f
#define DETAILVIEW_TOPPADDING 60.0f

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, PABLMenuViewControllerDelegate, PABLThumbnailViewDelegate, PABLDetailScrollViewDelegate>

@property (nonatomic, strong) UIView *welcomeView;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *menuSpreadButton;
@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) PABLMenuViewController *menuView;

@property (nonatomic, strong) UIView *dimmView;
@property (nonatomic, strong) PABLDetailScrollView *pablDetailScrollView;

@property (nonatomic, assign) BOOL isMine;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isMine = YES;
    
    [self.view addSubview:self.mapView];
    [self.mapView addSubview:self.menuSpreadButton];
    [self.mapView addSubview:self.titleView];
    [self.mapView addSubview:self.animationView];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dismissWelcomeView {
    [UIView animateWithDuration:0.5f animations:^{
        [self.welcomeView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.welcomeView setHidden:YES];
        CGPoint leftCorner = CGPointZero;
        leftCorner.x = self.mapView.region.center.longitude - self.mapView.region.span.longitudeDelta/2;
        leftCorner.y = self.mapView.region.center.latitude - self.mapView.region.span.latitudeDelta/2;
        [self refreshPhotoViewOnMapWithLeftCorner:leftCorner withSpan:self.mapView.region.span];
    }];
}

- (void)setTitleNameWithString:(NSString *)titleName {
    [self.titleLabel setText:titleName];
}

#pragma mark - Methods

- (CGFloat)viewWidthLengthToCoordinateLength:(CGFloat)length {
    return length/CGRectGetWidth(self.mapView.frame) * self.mapView.region.span.longitudeDelta;
}
- (CGFloat)viewHeightLengthToCoordinateLength:(CGFloat)length {
    return length/CGRectGetHeight(self.mapView.frame) * self.mapView.region.span.latitudeDelta;
}
- (CGFloat)coordinateWidthLengthToviewLength:(CGFloat)length{
    return length/self.mapView.region.span.longitudeDelta * CGRectGetWidth(self.mapView.frame);
}
- (CGFloat)coordinateHeightLengthToviewLength:(CGFloat)length{
    return length/self.mapView.region.span.latitudeDelta * CGRectGetHeight(self.mapView.frame);
}

- (void)refreshPhotoViewOnMapWithLeftCorner:(CGPoint)leftCorner withSpan:(MKCoordinateSpan)span {
    if (self.welcomeView.hidden == NO) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat latitudePaddingSize = [self viewWidthLengthToCoordinateLength:TUMBNAIL_SIZE.width]/2;
        CGFloat longitudePaddingSize = [self viewHeightLengthToCoordinateLength:TUMBNAIL_SIZE.height]/2;
        
        for (PABLPointAnnotation *pablPointAnnotation in self.mapView.annotations) {
            PABLPhoto *photo = [PhotoManager sharedInstance].photoArray[pablPointAnnotation.index];
            CGFloat longitude = pablPointAnnotation.coordinate.longitude;
            CGFloat latitude = pablPointAnnotation.coordinate.latitude;
            pablPointAnnotation.pileNum = 1;
            if (leftCorner.x + longitudePaddingSize > longitude || leftCorner.y + latitudePaddingSize > latitude ||
                leftCorner.x + span.longitudeDelta - longitudePaddingSize < longitude || leftCorner.y + span.latitudeDelta - latitudePaddingSize < latitude) {
                //지도 밖으로 튀어나가서 없애는 작업
                [self.mapView removeAnnotation:pablPointAnnotation];
                photo.isAdded = NO;
            } else {
                CGFloat minLength = CGFLOAT_MAX;
                PABLPointAnnotation *pileParentsAnnotation = nil;
                for (PABLPointAnnotation *remainPointAnnotation in self.mapView.annotations) {
                    if (pablPointAnnotation.index == remainPointAnnotation.index) {
                        break;
                    }
                    PABLPhoto *remainPhoto = [PhotoManager sharedInstance].photoArray[remainPointAnnotation.index];
                    if (remainPhoto.isAdded == YES) {
                        CGFloat addedLongitude = remainPointAnnotation.coordinate.longitude;
                        CGFloat addedLatitude = remainPointAnnotation.coordinate.latitude;
                        CGFloat length = [self coordinateWidthLengthToviewLength:fabs(addedLongitude - longitude)] * [self coordinateWidthLengthToviewLength:fabs(addedLongitude - longitude)]
                        + [self coordinateHeightLengthToviewLength:fabs(addedLatitude - latitude)] * [self coordinateHeightLengthToviewLength:fabs(addedLatitude - latitude)];
                        if (length < (PILE_LENGTH) * (PILE_LENGTH) + (PILE_LENGTH) * (PILE_LENGTH) && minLength > length) {
                            //한 위치에서 다른위치로 합쳐지는 작업
                            minLength = length;
                            pileParentsAnnotation = remainPointAnnotation;
                        }
                    }
                }
                if (pileParentsAnnotation != nil) {
                    pablPointAnnotation.actionType = AnnotationActionTypeDisappear;
                    pablPointAnnotation.departure = pablPointAnnotation.coordinate;
                    pablPointAnnotation.arrival = pileParentsAnnotation.coordinate;
                    [UIView animateWithDuration:0.2f animations:^{
                        pablPointAnnotation.coordinate = pileParentsAnnotation.coordinate;
                    } completion:^(BOOL finished) {
                        [self.mapView removeAnnotation:pablPointAnnotation];
                    }];
                    photo.isAdded = NO;
                }
            }
        }
        
        
        
        NSInteger num = 0;
        for (PABLPhoto *photo in [PhotoManager sharedInstance].photoArray) {
            if (photo.isAdded == NO) {
                CGFloat longitude = photo.photoData.location.coordinate.longitude;
                CGFloat latitude = photo.photoData.location.coordinate.latitude;
                if (latitude == 0 && longitude == 0) {
                    num++;
                    continue;
                }
                BOOL canAdd = YES;
                CGFloat minLength = CGFLOAT_MAX;
                PABLPointAnnotation *pileParentsAnnotation = nil;
                
                for (PABLPointAnnotation *addedAnnotation in self.mapView.annotations) {
                    if (addedAnnotation.actionType == AnnotationActionTypeTemp) {
                        continue;
                    }
                    CGFloat addedLongitude = addedAnnotation.arrival.longitude;
                    CGFloat addedLatitude = addedAnnotation.arrival.latitude;
                    CGFloat length = [self coordinateWidthLengthToviewLength:fabs(addedLongitude - longitude)] * [self coordinateWidthLengthToviewLength:fabs(addedLongitude - longitude)]
                    + [self coordinateHeightLengthToviewLength:fabs(addedLatitude - latitude)] * [self coordinateHeightLengthToviewLength:fabs(addedLatitude - latitude)];
                    if (length < (PILE_LENGTH) * (PILE_LENGTH) + (PILE_LENGTH) * (PILE_LENGTH) && minLength > length) {
                        //사진이 이미 지도에 그려진 사진에 쌓이는 작업
                        minLength = length;
                        pileParentsAnnotation = addedAnnotation;
                    }
                }
                if (pileParentsAnnotation != nil) {
                    //사진이 쌓여진곳에서 쌓여진곳으로 이동하는 작업
                    if (photo.pileParents != -1) {
                        PABLPhoto *pastParents = (PABLPhoto *)[PhotoManager sharedInstance].photoArray[photo.pileParents];
                        BOOL addTemp = YES;
                        for (PABLPointAnnotation *addedAnnotation in self.mapView.annotations) {
                            if ((fabs(addedAnnotation.departure.latitude - pastParents.photoData.location.coordinate.latitude) < 0.00001  &&
                                fabs(addedAnnotation.departure.longitude - pastParents.photoData.location.coordinate.longitude) < 0.00001 &&
                                fabs(addedAnnotation.arrival.latitude - pileParentsAnnotation.coordinate.latitude) < 0.00001 &&
                                fabs(addedAnnotation.arrival.longitude - pileParentsAnnotation.coordinate.longitude) < 0.00001) ||
                                (fabs(pileParentsAnnotation.coordinate.latitude - pastParents.photoData.location.coordinate.latitude) < 0.00001 &&
                                 fabs(pileParentsAnnotation.coordinate.longitude - pastParents.photoData.location.coordinate.longitude) < 0.00001)) {
                                addTemp = NO;
                            }
                        }
                        if (addTemp == YES) {
                            PABLPointAnnotation *annotation = [[PABLPointAnnotation alloc]init];
                            annotation.actionType = AnnotationActionTypeTemp;
                            annotation.index = num;
                            annotation.pileNum = 1;
                            annotation.departure = pastParents.photoData.location.coordinate;
                            annotation.arrival = pileParentsAnnotation.coordinate;
                            [annotation setCoordinate:annotation.departure];
                            [self.mapView addAnnotation:annotation];
                        }
                    }
                    pileParentsAnnotation.pileNum++;
                    photo.isAdded = NO;
                    photo.pileParents = pileParentsAnnotation.index;
                    canAdd = NO;
                    num++;
                    continue;
                }
                
                if (canAdd == YES &&
                    leftCorner.x + longitudePaddingSize < longitude && leftCorner.y  + latitudePaddingSize < latitude &&
                    leftCorner.x + span.longitudeDelta - longitudePaddingSize > longitude && leftCorner.y + span.latitudeDelta - latitudePaddingSize > latitude) {
                    //사진이 지도에 들어가는 작업
                    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                    PABLPointAnnotation *annotation = [[PABLPointAnnotation alloc]init];
                    annotation.actionType = AnnotationActionTypeAppear;
                    if (photo.pileParents != -1) {
                        PABLPhoto * parentsPhoto = [PhotoManager sharedInstance].photoArray[photo.pileParents];
                        annotation.departure = parentsPhoto.photoData.location.coordinate;
                        annotation.arrival = coordinate;
                        [annotation setCoordinate:annotation.departure];
                    } else {
                        annotation.departure = coordinate;
                        annotation.arrival = coordinate;
                        [annotation setCoordinate:coordinate];
                    }
                    annotation.index = num;
                    annotation.pileNum = 1;
                    [self.mapView addAnnotation:annotation];
                    photo.isAdded = YES;
                }
                photo.pileParents = -1;
            }
            num++;
        }
        for (PABLPointAnnotation *annotation in self.mapView.annotations) {
            PABLThumbnailView *thumbnailView = (PABLThumbnailView *)[self.mapView viewForAnnotation:annotation];
            if (thumbnailView) {
                thumbnailView.pileNum = annotation.pileNum;
            }
        }
    });
}

#pragma mark - PABLDetailScrollViewDelegate

- (void)PABLDetailScrollViewDidTouched {
    [UIView animateWithDuration:0.3f animations:^{
        [self.dimmView setAlpha:0.0f];
        [self.pablDetailScrollView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        for (UIView *view in self.dimmView.subviews) {
            [view removeFromSuperview];
        }
        [self.pablDetailScrollView removeFromSuperview];
        [self.dimmView removeFromSuperview];
    }];
}

#pragma mark - PABLThumbnailViewDelegate

- (void)didTappedPABLThumbnailView:(MKAnnotationView *)pablThumbnailView {
    PABLThumbnailView *thumbnailView = (PABLThumbnailView *)pablThumbnailView;
    
    [self.dimmView setFrame:self.mapView.frame];
    [self.dimmView setAlpha:0.0f];
    [self.mapView addSubview:self.dimmView];
    
    [self.pablDetailScrollView setFrame:CGRectMake(0, DETAILVIEW_TOPPADDING, CGRectGetWidth(self.mapView.frame), CGRectGetHeight(self.mapView.frame) - DETAILVIEW_TOPPADDING*2)];
    [self.pablDetailScrollView setAlpha:0.0f];
    NSMutableArray *photoArray = [[NSMutableArray alloc]init];
    [photoArray addObject:[PhotoManager sharedInstance].photoArray[thumbnailView.index]];
    for (PABLPhoto *photo in [PhotoManager sharedInstance].photoArray) {
        if (photo.pileParents == thumbnailView.index) {
            [photoArray addObject:photo];
        }
    }
    self.pablDetailScrollView.photoArray = photoArray;
    self.pablDetailScrollView.currentPage = 0;
    self.pablDetailScrollView.totalPage = thumbnailView.pileNum;
    self.pablDetailScrollView.delegate = self;
    [self.pablDetailScrollView prepareToShowImage];
    [self.mapView addSubview:self.pablDetailScrollView];
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.dimmView setAlpha:0.85f];
        [self.pablDetailScrollView setAlpha:1.0f];
    }];
    
    
    //debug code
    UILabel *debugLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    [debugLabel setText:[NSString stringWithFormat:@"%ld",thumbnailView.index]];
    [debugLabel setTextColor:[UIColor whiteColor]];
    [self.dimmView addSubview:debugLabel];
}

#pragma mark - MapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
    PABLThumbnailView *annotationView = (PABLThumbnailView *)[map dequeueReusableAnnotationViewWithIdentifier:@"PABLAnnotation"];
    PABLPointAnnotation *pointAnnotation = (PABLPointAnnotation *)annotation;
    if (annotationView == nil) {
        annotationView = [[PABLThumbnailView alloc] initWithAnnotation:annotation reuseIdentifier:@"PABLAnnotation"];
    }
    [annotationView setDelegate:self];
    [annotationView setPhoto:(PABLPhoto *)[PhotoManager sharedInstance].photoArray[pointAnnotation.index]];
    [annotationView setPileNum:pointAnnotation.pileNum];
    [annotationView setIndex:pointAnnotation.index];
    [annotationView setAnnotation:pointAnnotation];
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:YES];
    
    CGRect viewFrame = annotationView.frame;
    viewFrame.size.width = TUMBNAIL_SIZE.width;
    viewFrame.size.height = TUMBNAIL_SIZE.height;
    [annotationView setFrame:viewFrame];
    [annotationView setContentMode:UIViewContentModeScaleAspectFit];
    [annotationView setCanShowCallout:NO];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    for (PABLThumbnailView *view in views) {
        PABLPointAnnotation *pointAnnotation = (PABLPointAnnotation *)view.annotation;
        if (pointAnnotation.departure.latitude != pointAnnotation.arrival.latitude &&
            pointAnnotation.departure.longitude != pointAnnotation.arrival.longitude) {
            if (pointAnnotation.actionType == AnnotationActionTypeAppear) {
                [UIView animateWithDuration:0.3f animations:^{
                    [pointAnnotation setCoordinate:pointAnnotation.arrival];
                }];
            } else if (pointAnnotation.actionType == AnnotationActionTypeTemp) {
                [UIView animateWithDuration:0.3f animations:^{
                    [pointAnnotation setCoordinate:pointAnnotation.arrival];
                } completion:^(BOOL finished) {
                    [self.mapView removeAnnotation:pointAnnotation];
                }];
            }
        }
    }
}

#pragma mark - Map Action
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CGPoint leftCorner = CGPointZero;
    leftCorner.x = mapView.region.center.longitude - mapView.region.span.longitudeDelta/2;
    leftCorner.y = mapView.region.center.latitude - mapView.region.span.latitudeDelta/2;
    
    [self refreshPhotoViewOnMapWithLeftCorner:leftCorner withSpan:mapView.region.span];
}

- (void)updateMapZoomLocation:(CLLocation *)newLocation withSpan:(MKCoordinateSpan)span {
    MKCoordinateRegion region;
    region.center.latitude = newLocation.coordinate.latitude;
    region.center.longitude = newLocation.coordinate.longitude;
    region.span.latitudeDelta = span.latitudeDelta;
    region.span.longitudeDelta = span.longitudeDelta;
    [self.mapView setRegion:region animated:YES];
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
        [UIView animateWithDuration:1.0f animations:^{
            [alertLabel setAlpha:1.0f];
            [alertLabel setFrame:alertLabelMoveFrame];
        } completion:^(BOOL finished) {
            CGRect alertLabelMoveFrame = alertLabel.frame;
            alertLabelMoveFrame.origin.y -= ALERT_LABEL_HEIGHT;
            [UIView animateWithDuration:1.0f animations:^{
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
        [_mapView setRotateEnabled:NO];
    }
    return _mapView;
}

- (PABLMenuViewController *)menuView {
    if(_menuView == nil) {
        _menuView = [[PABLMenuViewController alloc]initWithViewController:self];
        [_menuView setDelegate:self];
    }
    return _menuView;
}

- (UIView *)animationView {
    if (_animationView == nil) {
        _animationView = [[UIView alloc]init];
        [_animationView setBackgroundColor:HEXCOLOR(0xFFFFFFFF)];
    }
    return _animationView;
}

- (UIView *)dimmView {
    if (_dimmView == nil) {
        _dimmView = [[UIView alloc]init];
        [_dimmView setBackgroundColor:[UIColor blackColor]];
    }
    return _dimmView;
}
- (PABLDetailScrollView *)pablDetailScrollView {
    if (_pablDetailScrollView == nil) {
        _pablDetailScrollView = [[PABLDetailScrollView alloc]init];
    }
    return _pablDetailScrollView;
}

@end
