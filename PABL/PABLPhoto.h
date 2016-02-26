//
//  PABLPhoto.h
//  PABL
//
//  Created by seung jin park on 2016. 2. 17..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PABLPhoto : NSObject

@property (nonatomic, assign) NSInteger pileParents;
@property (nonatomic, strong) PHAsset *photoData;
@property (nonatomic, assign) BOOL isAdded;

- (instancetype)initWithPHAsset:(PHAsset *)data;

- (void)getThumbnailImageWithCompletion:(void(^)(UIImage *image))completion;
- (void)getImageWithSize:(CGSize)imageSize WithCompletion:(void(^)(UIImage *image))completion;
@end
