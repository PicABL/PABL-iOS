//
//  PABLDetailScrollView.m
//  PABL
//
//  Created by seung jin park on 2016. 3. 5..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLDetailScrollView.h"
#import "PABLPhoto.h"

@interface PABLDetailScrollView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *photoScrollView;

@end

@implementation PABLDetailScrollView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.photoScrollView];
        UITapGestureRecognizer *tapGestuer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(detailViewTouched)];
        [tapGestuer setDelegate:self];
        [self.photoScrollView addGestureRecognizer:tapGestuer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.photoScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.photoScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * self.totalPage, CGRectGetHeight(self.frame))];
}

- (void)addPhotoWithIndex:(NSInteger)index {
    PABLPhoto *photo = self.photoArray[index];
    [photo getImageWithSize:self.frame.size WithCompletion:^(UIImage *image) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * index,
                                                                              0,
                                                                              CGRectGetWidth(self.frame),
                                                                              CGRectGetHeight(self.frame))];
        [imageView setImage:image];
        [imageView setTag:index];
        if (image.size.width > image.size.height) {
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
        } else {
            [imageView setContentMode:UIViewContentModeScaleToFill];
        }
        [self.photoScrollView addSubview:imageView];
    }];
}

- (void)prepareToShowImage {
    for (NSInteger num = 0; num < self.photoArray.count; num++) {
        [self addPhotoWithIndex:num];
        if (num == 2) {
            break;
        }
    }
}

#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.photoScrollView.contentOffset.x / self.photoScrollView.frame.size.width != self.currentPage) {
        self.currentPage = self.photoScrollView.contentOffset.x / self.photoScrollView.frame.size.width;
        NSInteger leftPage = self.currentPage - 2;
        NSInteger rightPage = self.currentPage + 2;
        if (leftPage < 0) leftPage = 0;
        if (rightPage > self.totalPage - 1) rightPage = self.totalPage - 1;
        
        NSInteger leftMinPage = rightPage;
        NSInteger rightMaxPage = leftPage;
        for (UIImageView *imageView in self.photoScrollView.subviews) {
            if (leftMinPage > imageView.tag) leftMinPage = imageView.tag;
            if (rightMaxPage < imageView.tag) rightMaxPage = imageView.tag;
            if (imageView.tag < leftPage) {
                [imageView removeFromSuperview];
            }
            if (imageView.tag > rightPage) {
                [imageView removeFromSuperview];
            }
        }
        if (leftMinPage != leftPage) {
            [self addPhotoWithIndex:leftPage];
        }
        if (rightMaxPage != rightPage) {
            [self addPhotoWithIndex:rightPage];
        }
    }
}

#pragma mark - touch action

- (void)detailViewTouched {
    [self.photoScrollView setContentOffset:CGPointMake(0, 0)];
    self.photoArray = nil;
    self.currentPage = 0;
    self.totalPage = 1;
    for (UIView *view in self.photoScrollView.subviews) {
        [view removeFromSuperview];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(PABLDetailScrollViewDidTouched)]) {
        [self.delegate PABLDetailScrollViewDidTouched];
    }
}

#pragma mark - setter

- (void)setTotalPage:(NSInteger)totalPage {
    _totalPage = totalPage;
    [self.photoScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * totalPage, CGRectGetHeight(self.frame))];
}

#pragma mark - generator

- (UIScrollView *)photoScrollView {
    if (_photoScrollView == nil) {
        _photoScrollView = [[UIScrollView alloc]init];
        [_photoScrollView setPagingEnabled:YES];
        [_photoScrollView setShowsHorizontalScrollIndicator:NO];
        [_photoScrollView setShowsVerticalScrollIndicator:NO];
        [_photoScrollView setDelegate:self];
    }
    return _photoScrollView;
}

@end
