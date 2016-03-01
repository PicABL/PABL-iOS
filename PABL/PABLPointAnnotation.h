//
//  PABLPointAnnotation.h
//  PABL
//
//  Created by seung jin park on 2016. 2. 20..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum ActionType{
    AnnotationActionTypeAppear,
    AnnotationActionTypeDisappear,
    AnnotationActionTypeTemp
} ActionType;

@interface PABLPointAnnotation : MKPointAnnotation

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger pileNum;
@property (nonatomic, assign) CLLocationCoordinate2D departure;
@property (nonatomic, assign) CLLocationCoordinate2D arrival;
@property (nonatomic, assign) ActionType actionType;

@end
