//
//  PABLThumbnailView.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 19..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLThumbnailView.h"
#import "PABLPointAnnotation.h"

#define NUMBADGE_SIZE CGSizeMake(14, 14)
#define NUMBADGE_PADDING 3.0f

@interface PABLThumbnailView ()

@property (nonatomic, strong) UIView *badgeView;
@property (nonatomic, strong) UILabel *numBadge;

@end

@implementation PABLThumbnailView


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        [self.layer setCornerRadius:4.0f];
        [self setBackgroundColor:[UIColor blackColor]];
        [self addSubview:self.badgeView];
        [self.badgeView addSubview:self.numBadge];
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

- (void)setPileNum:(NSInteger)pileNum {
    _pileNum = pileNum;
    [self.numBadge setText:[NSString stringWithFormat:@"%ld",self.pileNum]];
    CGRect textSize = [self.numBadge.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,NUMBADGE_SIZE.height)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:self.numBadge.font}
                                                       context:nil];
    CGRect badgeViewFrame = CGRectMake(TUMBNAIL_SIZE.width - NUMBADGE_SIZE.width/2, -NUMBADGE_SIZE.height/2, textSize.size.width + NUMBADGE_PADDING*2, NUMBADGE_SIZE.height);
    if (badgeViewFrame.size.width < NUMBADGE_SIZE.width) {
        badgeViewFrame.size.width = NUMBADGE_SIZE.width;
    }
    [self.badgeView setFrame:badgeViewFrame];
    CGRect badgeLabelFrame = CGRectMake(0, 0, textSize.size.width, textSize.size.height);
    [self.numBadge setFrame:badgeLabelFrame];
    self.numBadge.center = CGPointMake(badgeViewFrame.size.width/2, badgeViewFrame.size.height/2);
    if (self.pileNum < 2) {
        [self.badgeView setHidden:YES];
    } else {
        [self.badgeView setHidden:NO];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedPABLThumbnailView:)]) {
        [self.delegate didTappedPABLThumbnailView:self];
    }
}

- (UIView *)badgeView {
    if (_badgeView == nil) {
        _badgeView = [[UIView alloc]init];
        [_badgeView setBackgroundColor:[UIColor redColor]];
        [_badgeView.layer setCornerRadius:NUMBADGE_SIZE.width/2];
    }
    return _badgeView;
}

- (UILabel *)numBadge {
    if (_numBadge == nil) {
        _numBadge = [[UILabel alloc]init];
        [_numBadge setBackgroundColor:[UIColor clearColor]];
        [_numBadge setTextColor:[UIColor whiteColor]];
        [_numBadge setFont:[UIFont fontWithName:@"Helvetica" size:10.0f]];
    }
    return _numBadge;
}
@end
