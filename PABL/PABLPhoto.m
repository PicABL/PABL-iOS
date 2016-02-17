//
//  PABLPhoto.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 17..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLPhoto.h"

@implementation PABLPhoto

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        self.imageData = data;
        self.image = [UIImage imageWithData:data];
        CGImageSourceRef source = CGImageSourceCreateWithData((CFMutableDataRef)self.imageData, NULL);
        self.metaData = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,NULL));
        CFRelease(source);
        self.isAdded = NO;
    }
    return self;
}

@end
