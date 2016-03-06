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
    //앨범을 더 많이 불러올 필요는 없다.
//    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
//    [topLevelUserCollections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
//        [albumArray addObject:assetCollection];
//    }];
    
    for (PHAssetCollection *album in albumArray) {
        @try {
            PHFetchOptions *option = [PHFetchOptions new];
            [option setPredicate:[NSPredicate predicateWithFormat:@"mediaType == %d or mediaType == %d", PHAssetMediaTypeImage, PHAssetMediaTypeVideo]];
            PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:album options:option];
            PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            for (PHAsset *photo in assetsFetchResults) {
                if (photo.mediaType == PHAssetMediaTypeImage) {
                    PABLPhoto *pablPhoto = [[PABLPhoto alloc]initWithPHAsset:photo];
                    [self.photoArray addObject:pablPhoto];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
    }
}

- (NSMutableArray *)photoArray {
    if (_photoArray == nil) {
        _photoArray = [[NSMutableArray alloc]init];
    }
    return _photoArray;
}
@end
