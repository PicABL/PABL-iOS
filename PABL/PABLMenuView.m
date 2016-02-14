//
//  PABLMenuView.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 14..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLMenuView.h"

@interface PABLMenuView () <UIGestureRecognizerDelegate>

@end

@implementation PABLMenuView

- (instancetype)init {
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchedCloseButton)];
        [tapGesture setNumberOfTapsRequired:2];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)touchedCloseButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchedCloseButton)] == YES) {
        [self.delegate didTouchedCloseButton];
    }
}

@end
