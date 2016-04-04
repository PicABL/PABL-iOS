//
//  PABLGarage.m
//  PABL
//
//  Created by seung jin park on 2016. 3. 21..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLGarage.h"
#import "Common.h"

#define kRequestTimeout 90

NSString *DataSessionIdentifier = @"PABL_data_session";

@implementation PABLGarage

+ (AFURLSessionManager *)dataSessionManager
{
    static AFURLSessionManager *dataSessionManager = nil;
    if (dataSessionManager == nil) {
        @synchronized(self) {
            if (dataSessionManager == nil) {
                NSURLSessionConfiguration *configuration = nil;
                if ([Common systemVersionIsGreaterThanOrEqualTo_8_0]) {
                    configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:DataSessionIdentifier];
                } else {
                    configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                }
                
                configuration.HTTPMaximumConnectionsPerHost = 4;
                dataSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                AFHTTPResponseSerializer  *response = [AFHTTPResponseSerializer serializer];
//                NSMutableSet *acceptableContentTypes = [[NSMutableSet alloc]initWithSet:response.acceptableContentTypes];
//                [acceptableContentTypes addObject:@"text/plain"];
//                [response setAcceptableContentTypes:acceptableContentTypes];
                dataSessionManager.responseSerializer = response;
                
            }
        }
    }
    return dataSessionManager;
}

+ (NSInteger)sendGet:(NSString*)url parameters:(id)parameters success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailBlock)failure {
    return [self send:url method:@"GET" parameters:parameters success:success failure:failure];
}

+ (NSInteger)sendPost:(NSString*)url parameters:(NSDictionary*)parameters success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailBlock)failure {
    return [self send:url method:@"POST" parameters:parameters success:success failure:failure];
}

+ (NSInteger)send:(NSString*)url method:(NSString*)method parameters:(NSDictionary*)parameters success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailBlock)failure {
    return [self send:url method:method parameters:parameters retry:0 success:success failure:failure];
}

+ (NSInteger)send:(NSString*)url method:(NSString*)method parameters:(NSDictionary*)parameters retry:(int)retry success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailBlock)failure {
    NSLog(@"request url : %@",url);
    
    NSError *error;
    NSMutableDictionary *editableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:url parameters:editableParameters error:&error];
    [request setValue:@"" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"" forHTTPHeaderField:@"Accept-Language"];
    [request setTimeoutInterval:kRequestTimeout];
    AFURLSessionManager *sessionManager = [self dataSessionManager];
    NSURLSessionDataTask *dataTask = [sessionManager dataTaskWithRequest:request
                                                          uploadProgress:^(NSProgress *uploadProgress) {
                                                          } downloadProgress:^(NSProgress *downloadProgress) {
                                                          } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                              if (error) {
                                                                  if (failure) {
                                                                      failure(responseObject, error);
                                                                  }
                                                              } else {
                                                                  if (success) {
                                                                      NSString *string = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                                                                      NSLog(@"response string : %@",string);
                                                                      success(responseObject);
                                                                  }
                                                              }
                                                          }];
    [dataTask resume];
    
    
//    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
//    if ([method isEqualToString:@"GET"]) {
//        [sessionManager GET:url parameters:editableParameters progress:^(NSProgress * _Nonnull downloadProgress) {
//            
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            if (success) {
//                success(responseObject);
//            }
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            if (failure) {
//                failure(nil, error);
//            }
//        }];
//    } else if ([method isEqualToString:@"POST"]) {
//        [sessionManager POST:url parameters:editableParameters progress:^(NSProgress * _Nonnull uploadProgress) {
//            
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            if (success) {
//                success(responseObject);
//            }
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            if (failure) {
//                failure(nil, error);
//            }
//        }];
//    }
    return 0;
}


@end
