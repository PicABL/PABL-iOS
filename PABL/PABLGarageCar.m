//
//  PABLGarageCar.m
//  PABL
//
//  Created by seung jin park on 2016. 3. 23..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "PABLGarageCar.h"
#import "PABLGarage.h"

#define PORSCHE @"http://localhost:9000"

#define BOXSTER @"/ping"

static PABLGarageCar *instance = nil;

@implementation PABLGarageCar

- (NSString *)mergeRequestURLWithBrand:(NSString *)brand withModel:(NSString *)model {
    return [NSString stringWithFormat:@"%@%@",brand,model];
}

+ (PABLGarageCar *)sharedInstance {
    if (instance == nil) {
        @synchronized(self) {
            if (instance == nil) {
                instance = [[PABLGarageCar alloc]init];
            }
        }
    }
    return instance;
}

- (void)sendPingTest {
    NSString *requestURL = [self mergeRequestURLWithBrand:PORSCHE withModel:BOXSTER];
    NSMutableDictionary *parameter = @{@"text":@"aaa"};
    [PABLGarage sendGet:requestURL parameters:nil success:^(id responseObject) {
        NSLog(@"success!");
    } failure:^(id responseObject, NSError *error) {
        NSLog(@"fail!");
    }];
}

@end