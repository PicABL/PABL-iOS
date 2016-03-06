//
//  PABLMenuView.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 14..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLMenuView.h"

#define DEFAULT_SIZE CGSizeMake(100, 100)
#define IMAGE_PADDING 3.0f

@interface PABLMenuView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGPoint pictureLeftCorner;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) NSInteger viewCount;

@end

@implementation PABLMenuView

- (instancetype)init {
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.scrollView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchedCloseButton)];
        [tapGesture setNumberOfTapsRequired:2];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)prepareToLoad {
    self.pictureLeftCorner = CGPointMake(IMAGE_PADDING , IMAGE_PADDING + 40);
    self.maxHeight = IMAGE_PADDING + 40;
    self.viewCount = 0;
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)layoutSubviews {
    [self.scrollView setFrame:self.frame];
    [self.scrollView setContentSize:CGSizeMake(self.frame.size.width, self.maxHeight)];
}

- (void)addPhotoToTopOfView:(PABLPhoto *)photo {
    //view 재사용하게 바꿔야함
    //딜리게이트로
    [photo getImageWithSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) WithCompletion:^(UIImage *image) {
        if (image.size.width > image.size.height) {
            CGSize imageViewSize = CGSizeZero;
            imageViewSize.width = CGRectGetWidth(self.frame) - IMAGE_PADDING * 2 - DEFAULT_SIZE.width;
            imageViewSize.height = imageViewSize.width / image.size.width * image.size.height;
            if (self.pictureLeftCorner.x + imageViewSize.width > CGRectGetWidth(self.frame) || self.pictureLeftCorner.y < self.maxHeight) {
                self.pictureLeftCorner = CGPointMake(IMAGE_PADDING, self.maxHeight);
            }
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.pictureLeftCorner.x + (self.viewCount % 2 == 0 ? 0 : DEFAULT_SIZE.width),
                                                                                  self.pictureLeftCorner.y,
                                                                                  imageViewSize.width,
                                                                                  imageViewSize.height)];
            [imageView setImage:image];
            [imageView.layer setBorderColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f].CGColor];
            [imageView.layer setBorderWidth:0.5f];
            [imageView.layer setCornerRadius:2.0f];
            [imageView setClipsToBounds:YES];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            [self.scrollView addSubview:imageView];
            self.maxHeight = self.pictureLeftCorner.y + imageViewSize.height + IMAGE_PADDING;
            self.pictureLeftCorner = CGPointMake(IMAGE_PADDING, self.maxHeight);
        } else {
            CGSize imageViewSize = CGSizeZero;
            imageViewSize.width = (CGRectGetWidth(self.frame) - IMAGE_PADDING * 3) / 2;
            imageViewSize.height = imageViewSize.width / image.size.width * image.size.height;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.pictureLeftCorner.x,
                                                                                  self.pictureLeftCorner.y,
                                                                                  imageViewSize.width,
                                                                                  imageViewSize.height)];
            [imageView setImage:image];
            [imageView.layer setBorderColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f].CGColor];
            [imageView.layer setBorderWidth:0.5f];
            [imageView.layer setCornerRadius:2.0f];
            [imageView setClipsToBounds:YES];
            [imageView setContentMode:UIViewContentModeScaleToFill];
            [self.scrollView addSubview:imageView];
            self.maxHeight = self.pictureLeftCorner.y + imageViewSize.height + IMAGE_PADDING;
            if (CGRectGetMaxX(imageView.frame) + IMAGE_PADDING >= CGRectGetWidth(self.frame)) {
                self.pictureLeftCorner = CGPointMake(IMAGE_PADDING, self.maxHeight - (imageViewSize.height / 9 * 2));
            } else {
                self.pictureLeftCorner = CGPointMake(CGRectGetMaxX(imageView.frame) + IMAGE_PADDING
                                                     , self.pictureLeftCorner.y + imageViewSize.height / 3);
            }
        }
        [self.scrollView setContentSize:CGSizeMake(self.frame.size.width, self.maxHeight)];
        self.viewCount++;
    }];
}

#pragma mark - touch action

- (void)touchedCloseButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchedCloseButton)] == YES) {
        [self.delegate didTouchedCloseButton];
    }
}

#pragma mark - generator

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]init];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setBackgroundColor:[UIColor whiteColor]];
    }
    return _scrollView;
}

@end
