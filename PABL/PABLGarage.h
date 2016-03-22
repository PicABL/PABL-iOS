//
//  PABLGarage.h
//  PABL
//
//  Created by seung jin park on 2016. 3. 21..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void (^NSURLSessionSuccessBlock)(id responseObject);
typedef void (^NSURLSessionFailBlock)(id responseObject, NSError *error);
typedef void (^NSURLSessionProgressBlock)(NSProgress *progress);

@interface PABLGarage : NSObject

@end
