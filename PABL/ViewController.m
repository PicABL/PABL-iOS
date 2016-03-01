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

#define MENU_BUTTON_SIZE 40.0f
#define MENU_BUTTON_PADDING 20.0f
#define TITLE_VIEW_HEIGHT 60.0f
#define ALERT_LABEL_WIDTH 200.0f
#define ALERT_LABEL_HEIGHT 10.0f
#define PILE_LENGTH 100.0f

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, PABLMenuViewControllerDelegate, PABLThumbnailViewDelegate>

@property (nonatomic, strong) UIView *welcomeView;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *menuSpreadButton;
@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) PABLMenuViewController *menuView;

@property (nonatomic, strong) UIView *dimmView;
@property (nonatomic, strong) UIImageView *detailView;

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
        leftCorner.x = self.mapView.region.center.latitude - self.mapView.region.span.latitudeDelta/2;
        leftCorner.y = self.mapView.region.center.longitude - self.mapView.region.span.longitudeDelta/2;
        [self refreshPhotoViewOnMapWithLeftCorner:leftCorner withSpan:self.mapView.region.span];
    }];
}

- (void)setTitleNameWithString:(NSString *)titleName {
    [self.titleLabel setText:titleName];
}

#pragma mark - Methods

- (CGFloat)viewWidthLengthToCoordinateLength:(CGFloat)length {
    return length/CGRectGetWidth(self.mapView.frame) * self.mapView.region.span.latitudeDelta;
}
- (CGFloat)viewHeightLengthToCoordinateLength:(CGFloat)length {
    return length/CGRectGetHeight(self.mapView.frame) * self.mapView.region.span.longitudeDelta;
}
- (CGFloat)coordinateWidthLengthToviewLength:(CGFloat)length{
    return length/self.mapView.region.span.latitudeDelta * CGRectGetWidth(self.mapView.frame);
}
- (CGFloat)coordinateHeightLengthToviewLength:(CGFloat)length{
    return length/self.mapView.region.span.longitudeDelta * CGRectGetHeight(self.mapView.frame);
}

- (void)refreshPhotoViewOnMapWithLeftCorner:(CGPoint)leftCorner withSpan:(MKCoordinateSpan)span {
    if (self.welcomeView.hidden == NO) {
        return;
    }
    
    //그림을 완전히 새로 짜야함
    //먼저 화면에 그려질, 그려진 사진들을 구분해내고
    //사진에 숫자를 쌓아올린다.
    //
    //애니메이션을 어떻게 넣을지가 관건
    //사라지는 애니메이션
    //- PABLPointAnnotation 에 사라지는 마킹을하고
    //- 어디로 사라지는지 index 값을 넣어놓고
    //- 썸네일을 그릴 때 에니메이션으로 해당 index 뷰로 옮기면서 얿어짐
    //- 없어지고 난 다음 해당 PABLPointAnnotation 을 mapView에서 제거
    //- 숫자가 자연스럽게 합쳐지는지 확인 필요
    //뭉태기에서 분리되는 애니메이션
    //- PABLPointAnnotation 에 분리되는 마킹을 하고
    //- 어디로부터 분리되는지 index 값을 넣어놓고
    //- 썸네일을 그릴 때 애니메이션으로 해당 index 뷰에서 부터 옮기면서 생김
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat latitudePaddingSize = [self viewWidthLengthToCoordinateLength:TUMBNAIL_SIZE.width]/2;
        CGFloat longitudePaddingSize = [self viewHeightLengthToCoordinateLength:TUMBNAIL_SIZE.height]/2;
        
        for (PABLPointAnnotation *pablPointAnnotation in self.mapView.annotations) {
            PABLPhoto *photo = [PhotoManager sharedInstance].photoArray[pablPointAnnotation.index];
            CGFloat latitude = pablPointAnnotation.coordinate.latitude;
            CGFloat longitude = pablPointAnnotation.coordinate.longitude;
            pablPointAnnotation.pileNum = 1;
            if (leftCorner.x + latitudePaddingSize > latitude || leftCorner.y + longitudePaddingSize > longitude ||
                leftCorner.x + span.latitudeDelta - latitudePaddingSize < latitude || leftCorner.y + span.longitudeDelta - longitudePaddingSize < longitude) {
                //지도 밖으로 튀어나가서 없애는 작업
                [self.mapView removeAnnotation:pablPointAnnotation];
                photo.isAdded = NO;
            } else {
                for (PABLPointAnnotation *remainPointAnnotation in self.mapView.annotations) {
                    if (pablPointAnnotation.index == remainPointAnnotation.index) {
                        break;
                    }
                    PABLPhoto *remainPhoto = [PhotoManager sharedInstance].photoArray[remainPointAnnotation.index];
                    if (remainPhoto.isAdded == YES) {
                        CGFloat addedLatitude = remainPointAnnotation.coordinate.latitude;
                        CGFloat addedLongitude = remainPointAnnotation.coordinate.longitude;
                        if ([self coordinateWidthLengthToviewLength:fabs(addedLatitude - latitude)] * [self coordinateWidthLengthToviewLength:fabs(addedLatitude - latitude)]
                            + [self coordinateHeightLengthToviewLength:fabs(addedLongitude - longitude)] * [self coordinateHeightLengthToviewLength:fabs(addedLongitude - longitude)]
                            < (PILE_LENGTH) * (PILE_LENGTH) + (PILE_LENGTH) * (PILE_LENGTH)) {
                            //한 위치에서 다른위치로 합쳐지는 작업
                            pablPointAnnotation.actionType = AnnotationActionTypeDisappear;
                            pablPointAnnotation.departure = pablPointAnnotation.coordinate;
                            pablPointAnnotation.arrival = remainPointAnnotation.coordinate;
                            [UIView animateWithDuration:0.2f animations:^{
                                pablPointAnnotation.coordinate = remainPointAnnotation.coordinate;
                            } completion:^(BOOL finished) {
                                [self.mapView removeAnnotation:pablPointAnnotation];
                            }];
                            remainPhoto.isAdded = NO;
                        }
                    }
                }
            }
        }
        
        
        
        NSInteger num = 0;
        for (PABLPhoto *photo in [PhotoManager sharedInstance].photoArray) {
            if (photo.isAdded == NO) {
                CGFloat latitude = photo.photoData.location.coordinate.latitude;
                CGFloat longitude = photo.photoData.location.coordinate.longitude;
                if (latitude == 0 && longitude == 0) {
                    num++;
                    continue;
                }
                BOOL canAdd = YES;
                CGFloat minLength = CGFLOAT_MAX;
                PABLPointAnnotation *pileParentsAnnotation = nil;
                
                for (PABLPointAnnotation *addedAnnotation in self.mapView.annotations) {
                    CGFloat addedLatitude = addedAnnotation.arrival.latitude;
                    CGFloat addedLongitude = addedAnnotation.arrival.longitude;
                    CGFloat length = [self coordinateWidthLengthToviewLength:fabs(addedLatitude - latitude)] * [self coordinateWidthLengthToviewLength:fabs(addedLatitude - latitude)]
                    + [self coordinateHeightLengthToviewLength:fabs(addedLongitude - longitude)] * [self coordinateHeightLengthToviewLength:fabs(addedLongitude - longitude)];
                    if (length < (PILE_LENGTH) * (PILE_LENGTH) + (PILE_LENGTH) * (PILE_LENGTH)) {
                        //사진이 이미 지도에 그려진 사진에 쌓이는 작업
                        if (minLength > length) {
                            minLength = length;
                            pileParentsAnnotation = addedAnnotation;
                        }
                    }
                }
                if (pileParentsAnnotation != nil) {
                    pileParentsAnnotation.pileNum++;
                    photo.isAdded = NO;
                    photo.pileParents = pileParentsAnnotation.index;
                    canAdd = NO;
                    num++;
                    continue;
                }
                
                if (canAdd == YES &&
                    leftCorner.x + latitudePaddingSize <= latitude && leftCorner.y  + longitudePaddingSize <= longitude &&
                    leftCorner.x + span.latitudeDelta - latitudePaddingSize >= latitude && leftCorner.y + span.longitudeDelta - longitudePaddingSize >= longitude) {
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

#pragma mark - PABLThumbnailViewDelegate
- (void)didTappedDetailView {
    [UIView animateWithDuration:0.3f animations:^{
        [self.dimmView setAlpha:0.0f];
        [self.detailView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.dimmView removeFromSuperview];
        [self.detailView removeFromSuperview];
    }];
}

- (void)didTappedPABLThumbnailViewWithManyPiles:(MKAnnotationView *)pablThumbnailView {
}

- (void)didTappedPABLThumbnailView:(MKAnnotationView *)pablThumbnailView {
    [self.dimmView setFrame:self.mapView.frame];
    [self.dimmView setAlpha:0.0f];
    [self.mapView addSubview:self.dimmView];
    
    [self.detailView setFrame:CGRectMake(40, 40, CGRectGetWidth(self.mapView.frame) - 80, CGRectGetHeight(self.mapView.frame) - 80)];
    [self.detailView setAlpha:0.0f];
    [self.mapView addSubview:self.detailView];
    PABLThumbnailView *thumbnailView = (PABLThumbnailView *)pablThumbnailView;
    [thumbnailView.photo getImageWithSize:self.detailView.frame.size WithCompletion:^(UIImage *image) {
        self.detailView.image = image;
        CGSize imageSize = image.size;
        if (imageSize.width >= self.mapView.frame.size.width) {
            imageSize.width = self.mapView.frame.size.width - 100;
        }
        if (imageSize.height >= self.mapView.frame.size.height) {
            imageSize.height = self.mapView.frame.size.height - 100;
        }
        [self.detailView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        self.detailView.center = self.mapView.center;
    }];
    [UIView animateWithDuration:0.3f animations:^{
        [self.dimmView setAlpha:0.85f];
        [self.detailView setAlpha:1.0f];
    }];
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
    [annotationView setAnnotation:annotation];
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
        if (pointAnnotation.actionType == AnnotationActionTypeAppear &&
            pointAnnotation.departure.latitude != pointAnnotation.arrival.latitude &&
            pointAnnotation.departure.longitude != pointAnnotation.arrival.longitude) {
            [UIView animateWithDuration:0.2f animations:^{
                [pointAnnotation setCoordinate:pointAnnotation.arrival];
            }];
        }
    }
}

#pragma mark - Map Action
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CGPoint leftCorner = CGPointZero;
    leftCorner.x = mapView.region.center.latitude - mapView.region.span.latitudeDelta/2;
    leftCorner.y = mapView.region.center.longitude - mapView.region.span.longitudeDelta/2;
    
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

- (UIImageView *)detailView {
    if (_detailView == nil) {
        _detailView = [[UIImageView alloc]init];
        [_detailView setBackgroundColor:[UIColor blackColor]];
        [_detailView setContentMode:UIViewContentModeScaleAspectFit];
        [_detailView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTappedDetailView)];
        [_detailView addGestureRecognizer:tapGesture];
    }
    return _detailView;
}
@end
