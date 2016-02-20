//
//  PABLThumbnailView.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 19..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLThumbnailView.h"

@implementation PABLThumbnailView


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

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

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedPABLThumbnailView:)]) {
        [self.delegate didTappedPABLThumbnailView:self];
    }
}
@end
