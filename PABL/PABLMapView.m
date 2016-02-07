//
//  PABLMapView.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 7..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLMapView.h"

@implementation PABLMapView

- (instancetype)init {
    
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setBackgroundColor:[UIColor blueColor]];
}

@end
