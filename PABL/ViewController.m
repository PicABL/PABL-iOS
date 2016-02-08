//
//  ViewController.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 6..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "ViewController.h"
#import "PABLMenuViewController.h"

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) PABLMenuViewController *menuView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mapView];
    [self.mapView setFrame:self.view.frame];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self presentViewController:self.menuView animated:YES completion:^{
            
        }];
    }
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
        _menuView = [[PABLMenuViewController alloc]initWithViewCOntroller:self];
    }
    return _menuView;
}

@end
