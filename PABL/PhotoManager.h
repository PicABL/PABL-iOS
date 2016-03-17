//
//  PhotoManager.h
//  PABL
//
//  Created by seung jin park on 2016. 2. 16..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface PhotoManager : NSObject

+ (PhotoManager *)sharedInstance;
- (void)getAllPhotosFromAllAlbums;
- (void)reloadPhotoAsset;

@property (nonatomic, strong) NSMutableArray *photoArray;

@end
