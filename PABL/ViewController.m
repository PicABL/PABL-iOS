//
//  ViewController.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 6..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "ViewController.h"
#import "PABLMapView.h"

@interface ViewController ()

@property (nonatomic, strong) PABLMapView *pablMapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = self.pablMapView;
}

- (PABLMapView *)pablMapView {
    if (_pablMapView == nil) {
        _pablMapView = [[PABLMapView alloc]init];
    }
    return _pablMapView;
}


@end
