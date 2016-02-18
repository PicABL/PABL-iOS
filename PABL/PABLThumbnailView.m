//
//  PABLThumbnailView.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 19..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLThumbnailView.h"

@implementation PABLThumbnailView

- (void)setPhoto:(PABLPhoto *)photo {
    _photo = photo;
    [self setAlpha:0.0f];
    [photo getThumbnailImageWithCompletion:^(UIImage *image) {
        self.image = image;
        [UIView animateWithDuration:0.5f animations:^{
            [self setAlpha:1.0f];
        }];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedPABLThumbnailView:)]) {
        [self.delegate didTappedPABLThumbnailView:self];
    }
}

@end
