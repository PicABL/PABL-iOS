//
//  Common.m
//  PABL
//
//  Created by seung jin park on 2016. 2. 9..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import "Common.h"

@implementation Common

+ (NSString*)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (BOOL)systemVersionIsGreaterThanOrEqualTo_5_0 {
    static int i = -1;
    if ( i == -1 ) { i = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ? 1 : 0; }
    return i > 0 ? YES : NO;
}

+ (BOOL)systemVersionIsGreaterThanOrEqualTo_6_0 {
    static int i = -1;
    if ( i == -1 ) { i = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ? 1 : 0; }
    return i > 0 ? YES : NO;
}

+ (BOOL)systemVersionIsGreaterThanOrEqualTo_7_0 {
    static int i = -1;
    if ( i == -1 ) { i = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 1 : 0; }
    return i > 0 ? YES : NO;
}

+ (BOOL)systemVersionIsGreaterThanOrEqualTo_8_0 {
    static int i = -1;
    if ( i == -1 ) { i = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ? 1 : 0; }
    return i > 0 ? YES : NO;
}

+ (BOOL)systemVersionIsGreaterThanOrEqualTo_9_0 {
    static int i = -1;
    if ( i == -1 ) { i = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") ? 1 : 0; }
    return i > 0 ? YES : NO;
}

@end
