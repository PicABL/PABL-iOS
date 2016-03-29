//
//  PABLChannelListView.m
//  PABL
//
//  Created by seung jin park on 2016. 3. 23..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLChannelListView.h"
#import "PABLGarageCar.h"
#import "Common.h"

@interface PABLChannelListView () <UIGestureRecognizerDelegate>

@end

@implementation PABLChannelListView

- (instancetype)init {
    if (self = [super init]) {
        [self setBackgroundColor:HEXCOLOR(0x000000CC)];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didChannelListTouched)];
        [tapGesture setDelegate:self];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)didChannelListTouched {
    [[PABLGarageCar sharedInstance] sendPingTest];
}

@end
