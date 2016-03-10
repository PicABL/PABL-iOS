//
//  PABLMenuView.h
//  PABL
//
//  Created by seung jin park on 2016. 2. 14..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PABLPhoto.h"

@protocol PABLMenuViewDelegate <NSObject>

- (void)didTouchedCloseButton;
- (PABLPhoto *)getPhotoWithIndex:(NSInteger)index;

@end

@interface PABLMenuView : UIView

@property (nonatomic, assign) id<PABLMenuViewDelegate> delegate;
@property (nonatomic, assign) NSInteger photoCount;

- (void)prepareToLoad;
- (void)addPhotoToTopOfView:(PABLPhoto *)photo withIndex:(NSInteger)index;

@end
