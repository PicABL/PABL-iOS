//
//  PABLPhoto.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 17..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLPhoto.h"
#import "PABLThumbnailView.h"

@interface PABLPhoto ()

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHImageRequestOptions *imageOptions;

@end

@implementation PABLPhoto

- (instancetype)initWithPHAsset:(PHAsset *)data {
    if (self = [super init]) {
        self.photoData = data;
        self.isAdded = NO;
        self.pileParents = -1;
    }
    return self;
}

- (void)getThumbnailImageWithCompletion:(void(^)(UIImage *image))completion {
    self.imageOptions.version = PHImageRequestOptionsVersionCurrent;
    [self.imageManager requestImageForAsset:self.photoData
                                 targetSize:TUMBNAIL_SIZE
                                contentMode:PHImageContentModeAspectFit
                                    options:self.imageOptions
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  completion(result);
                              }];
}

- (void)getImageWithSize:(CGSize)imageSize WithCompletion:(void(^)(UIImage *image))completion{
    self.imageOptions.version = PHImageRequestOptionsVersionOriginal;
    [self.imageManager requestImageForAsset:self.photoData
                                 targetSize:imageSize
                                contentMode:PHImageContentModeAspectFit
                                    options:self.imageOptions
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  completion(result);
                              }];
}

- (PHCachingImageManager *)imageManager {
    if (_imageManager == nil) {
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (PHImageRequestOptions *)imageOptions {
    if (_imageOptions == nil) {
        _imageOptions = [[PHImageRequestOptions alloc] init];
        [_imageOptions setSynchronous:YES];
        [_imageOptions setVersion:PHImageRequestOptionsVersionCurrent];
        [_imageOptions setResizeMode:PHImageRequestOptionsResizeModeNone];
    }
    return _imageOptions;
}


@end
