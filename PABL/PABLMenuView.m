//
//  PABLMenuView.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 14..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLMenuView.h"
#import "PABLChannelListView.h"
#import "Common.h"

#define DEFAULT_SIZE CGSizeMake(100, 100)
#define IMAGE_PADDING 3.0f
#define CHANNELLIST_WIDTH 220.0f

@interface PABLMenuView () <UIGestureRecognizerDelegate, UIScrollViewDelegate, PABLPhotoViewDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) PABLChannelListView *channelListView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation PABLMenuView

- (instancetype)init {
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.scrollView];
        [self addSubview:self.headerView];
        [self addSubview:self.channelListView];
        

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleChannelView)];
        [self.headerView addGestureRecognizer:tapGesture];
        UITapGestureRecognizer *closeTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchedCloseButton)];
        [closeTapGesture setNumberOfTapsRequired:2];
        [tapGesture requireGestureRecognizerToFail:closeTapGesture];
        [self.headerView addGestureRecognizer:closeTapGesture];
        
    }
    return self;
}

- (void)prepareToLoad {
    self.minHeight = 0;
    self.maxHeight = 0;
    self.currentPage = 0;
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    if (CGRectGetMinX(self.channelListView.frame) >= 0 && self.channelListView.frame.size.width > 0) {
        [self.channelListView setFrame:CGRectMake(-CHANNELLIST_WIDTH, 0, CHANNELLIST_WIDTH, CGRectGetHeight(self.frame))];
    }
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)layoutSubviews {
    [self.headerView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), TITLEVIEW_HEIGHT)];
    [self.scrollView setFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - TITLEVIEW_HEIGHT)];
    [self.channelListView setFrame:CGRectMake(-CHANNELLIST_WIDTH, 0, CHANNELLIST_WIDTH, CGRectGetHeight(self.frame))];
}

- (void)setMaxHeight:(CGFloat)maxHeight {
    _maxHeight = maxHeight;
    [self.scrollView setContentSize:CGSizeMake(self.frame.size.width, self.maxHeight)];
}

- (void)addPhotoToTopOfView:(PABLPhoto *)photo withIndex:(NSInteger)index {
    [photo getImageWithSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) WithCompletion:^(UIImage *image) {
        CGSize imageViewSize = CGSizeZero;
        imageViewSize.width = CGRectGetWidth(self.frame);
        imageViewSize.height = imageViewSize.width / image.size.width * image.size.height;
        PABLPhotoView *pablPhotoView = [[PABLPhotoView alloc]init];
        [pablPhotoView setFrame:CGRectMake(0,
                                           self.maxHeight,
                                           imageViewSize.width,
                                           imageViewSize.height)];
        [pablPhotoView setPhoto:image];
        [pablPhotoView setIndex:index];
        [pablPhotoView setDelegate:self];
        [self.scrollView addSubview:pablPhotoView];
        self.maxHeight += imageViewSize.height;
    }];
}

- (void)addPhotoToBottomOfView:(PABLPhoto *)photo withIndex:(NSInteger)index {
    [photo getImageWithSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) WithCompletion:^(UIImage *image) {
        CGSize imageViewSize = CGSizeZero;
        imageViewSize.width = CGRectGetWidth(self.frame);
        imageViewSize.height = imageViewSize.width / image.size.width * image.size.height;
        PABLPhotoView *pablPhotoView = [[PABLPhotoView alloc]init];
        [pablPhotoView setFrame:CGRectMake(0,
                                           self.minHeight - imageViewSize.height,
                                           imageViewSize.width,
                                           imageViewSize.height)];
        [pablPhotoView setPhoto:image];
        [pablPhotoView setIndex:index];
        [pablPhotoView setDelegate:self];
        [self.scrollView addSubview:pablPhotoView];
        self.minHeight -= imageViewSize.height;
    }];
}

- (void)removePhotoWithIndex:(NSInteger)index {
    NSInteger maxIndex = 0;
    CGFloat viewHeight = 0.0f;
    for (PABLPhotoView *view in self.scrollView.subviews) {
        if (view.index > index) {
            view.index -= 1;
        } else if (view.index == index) {
            view.index = -1;
            viewHeight = view.frame.size.height;
        }
        if (view.index == index + 1) {
        }
        if (maxIndex < view.index) {
            maxIndex = view.index;
        }
    }
    for (PABLPhotoView *view in self.scrollView.subviews) {
        if (view.index == -1) {
            [view removeFromSuperview];
        }
        if (view.index >= index) {
            CGRect viewFrame = view.frame;
            viewFrame.origin.y -= viewHeight;
            [UIView animateWithDuration:0.3f animations:^{
                [view setFrame:viewFrame];
            }];
        }
    }
    self.maxHeight -= viewHeight;
    if (maxIndex + 1 < self.photoCount) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(getPhotoWithIndex:)] == YES) {
            PABLPhoto *photo = [self.delegate getPhotoWithIndex:maxIndex + 1];
            if (photo != nil) {
                [self addPhotoToTopOfView:photo withIndex:maxIndex + 1];
            }
        }
    }
}

#pragma mark - PABLPhotoViewDelegate

- (void)PABLPhotoViewDidTouched:(UIView *)view {
    if (CGRectGetMinX(self.channelListView.frame) == 0) {
        [self toggleChannelView];
    }
    [self.scrollView setContentOffset:CGPointMake(0, view.frame.origin.y) animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchedPhotoViewWithPhotoView:)] == YES) {
        [self.delegate didTouchedPhotoViewWithPhotoView:(PABLPhotoView *)view];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.maxHeight == 0 ) {
        return;
    }
    if (CGRectGetMinX(self.channelListView.frame) == 0) {
        [self toggleChannelView];
    }
    NSInteger minIndex = NSIntegerMax;
    NSInteger maxIndex = NSIntegerMin;
    for (PABLPhotoView *view in self.scrollView.subviews) {
        if (view.index > maxIndex) {
            maxIndex = view.index;
        }
        if (view.index < minIndex) {
            minIndex = view.index;
        }
    }
    if (self.scrollView.contentOffset.y + CGRectGetHeight(self.scrollView.frame) > self.minHeight + (self.maxHeight - self.minHeight) * 0.7f && maxIndex < self.photoCount) {
        for (PABLPhotoView *view in self.scrollView.subviews) {
            if (view.index == minIndex) {
                [view removeFromSuperview];
            }
            if (view.index == minIndex + 1) {
                self.minHeight = CGRectGetMinY(view.frame);
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(getPhotoWithIndex:)] == YES) {
            PABLPhoto *photo = [self.delegate getPhotoWithIndex:maxIndex+1];
            if (photo != nil) {
                [self addPhotoToTopOfView:photo withIndex:maxIndex+1];
            }
        }
    } else if (self.scrollView.contentOffset.y < self.minHeight + (self.maxHeight - self.minHeight) * 0.3f && minIndex > 0) {
        for (PABLPhotoView *view in self.scrollView.subviews) {
            if (view.index == maxIndex) {
                [view removeFromSuperview];
            }
            if (view.index == maxIndex - 1) {
                self.maxHeight = CGRectGetMaxY(view.frame);
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(getPhotoWithIndex:)] == YES) {
            PABLPhoto *photo = [self.delegate getPhotoWithIndex:minIndex-1];
            if (photo != nil) {
                [self addPhotoToBottomOfView:photo withIndex:minIndex-1];
            }
        }
    }
}

#pragma mark - touch action

- (void)touchedCloseButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchedCloseButton)] == YES) {
        [self.delegate didTouchedCloseButton];
    }
}

- (void) toggleChannelView {
    CGRect channelListViewFrame = self.channelListView.frame;
    if (CGRectGetMinX(self.channelListView.frame) < 0) {
        channelListViewFrame.origin.x = 0;
    } else {
        channelListViewFrame.origin.x = -CHANNELLIST_WIDTH;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.channelListView setFrame:channelListViewFrame];
    }];
}

#pragma mark - generator

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc]init];
        [_headerView setBackgroundColor:HEXCOLOR(0x5CD1E5FF)];
    }
    return _headerView;
}

- (PABLChannelListView *)channelListView {
    if (_channelListView == nil) {
        _channelListView = [[PABLChannelListView alloc]init];
    }
    return _channelListView;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]init];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setBackgroundColor:[UIColor whiteColor]];
        [_scrollView setDelegate:self];
    }
    return _scrollView;
}

@end
