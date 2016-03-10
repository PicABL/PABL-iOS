//
//  PABLPhotoView.h
//  PABL
//
//  Created by seung jin park on 2016. 3. 11..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PABLPhotoViewDelegate <NSObject>

- (void)PABLPhotoViewDidTouched:(NSInteger)index;

@end

@interface PABLPhotoView : UIView

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, assign) id<PABLPhotoViewDelegate> delegate;

@end
