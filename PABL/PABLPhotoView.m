//
//  PABLPhotoView.m
//  PABL
//
//  Created by seung jin park on 2016. 3. 11..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLPhotoView.h"

@interface PABLPhotoView () <UIGestureRecognizerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PABLPhotoView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.imageView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTappedPhotoView)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)didTappedPhotoView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(PABLPhotoViewDidTouched:)]) {
        [self.delegate PABLPhotoViewDidTouched:self];
    }
    self.isMapViewOpened = self.isMapViewOpened ? NO : YES;
}

- (void)setPhoto:(UIImage *)photo {
    _photo = photo;
    [self.imageView setImage:_photo];
}

- (void)layoutSubviews {
    [self.imageView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    if (CGRectGetWidth(self.imageView.frame) > CGRectGetHeight(self.imageView.frame)) {
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    } else {
        [self.imageView setContentMode:UIViewContentModeScaleToFill];
    }
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]init];
        [_imageView.layer setBorderColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f].CGColor];
        [_imageView.layer setBorderWidth:0.5f];
        [_imageView setClipsToBounds:YES];
    }
    return _imageView;
}

@end
