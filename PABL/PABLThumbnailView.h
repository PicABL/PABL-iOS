//
//  PABLThumbnailView.h
//  PABL
//
//  Created by seung jin park on 2016. 2. 19..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "PABLPhoto.h"

@protocol PABLThumbnailViewDelegate <NSObject>

- (void)didTappedPABLThumbnailView:(MKAnnotationView *)pablThumbnailView;

@end

@interface PABLThumbnailView : MKAnnotationView

@property (nonatomic, assign) id<PABLThumbnailViewDelegate> delegate;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) PABLPhoto *photo;

@end
