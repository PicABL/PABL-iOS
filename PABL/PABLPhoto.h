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

@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDictionary *metaData;
@property (nonatomic, assign) BOOL isAdded;

- (instancetype)initWithData:(NSData *)data;

@end
