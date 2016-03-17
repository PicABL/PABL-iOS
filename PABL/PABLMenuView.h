//
//  PABLMenuView.h
//  PABL
//
//  Created by seung jin park on 2016. 2. 14..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PABLPhotoView.h"
#import "PABLPhoto.h"

#define TITLEVIEW_HEIGHT 60.0f

@protocol PABLMenuViewDelegate <NSObject>

- (void)didTouchedCloseButton;
- (PABLPhoto *)getPhotoWithIndex:(NSInteger)index;
- (void)didTouchedPhotoViewWithPhotoView:(PABLPhotoView *)photoView;

@end

@interface PABLMenuView : UIView

@property (nonatomic, assign) id<PABLMenuViewDelegate> delegate;
@property (nonatomic, assign) NSInteger photoCount;

- (void)prepareToLoad;
- (void)addPhotoToTopOfView:(PABLPhoto *)photo withIndex:(NSInteger)index;
- (void)addPhotoToBottomOfView:(PABLPhoto *)photo withIndex:(NSInteger)index;
- (void)removePhotoWithIndex:(NSInteger)index;

@end
