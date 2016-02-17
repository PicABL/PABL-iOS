//
//  PhotoManager.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 16..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PhotoManager.h"
#import "PABLPhoto.h"

static PhotoManager *instance = nil;

@interface PhotoManager ()

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHImageRequestOptions *imageOptions;

@end

@implementation PhotoManager

+ (PhotoManager *)sharedInstance {
    if (instance == nil) {
        @synchronized(self) {
            if (instance == nil) {
                instance = [[PhotoManager alloc]init];
            }
        }
    }
    return instance;
}


- (void)getAllPhotosFromAllAlbums {
    NSMutableArray *albumArray = [NSMutableArray array];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
        [albumArray addObject:assetCollection];
    }];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    [topLevelUserCollections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
        [albumArray addObject:assetCollection];
    }];
    
    NSMutableArray *assetArray = [[NSMutableArray alloc]init];
    for (PHAssetCollection *album in albumArray) {
        @try {
            PHFetchOptions *option = [PHFetchOptions new];
            [option setPredicate:[NSPredicate predicateWithFormat:@"mediaType == %d or mediaType == %d", PHAssetMediaTypeImage, PHAssetMediaTypeVideo]];
            PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:album options:option];
            PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            for (PHAsset *photo in assetsFetchResults) {
                [assetArray addObject:photo];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (PHAsset *photo in assetArray) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.imageManager requestImageDataForAsset:photo
                                                    options:self.imageOptions
                                              resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                  if (imageData != nil && self.photoArray.count < 10) {
                                                      PABLPhoto *pablPhoto = [[PABLPhoto alloc]initWithData:imageData];
                                                      [self.photoArray addObject:pablPhoto];
                                                  }
                                              }];
            });
        }
    });
}

- (NSMutableArray *)photoArray {
    if (_photoArray == nil) {
        _photoArray = [[NSMutableArray alloc]init];
    }
    return _photoArray;
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
