//
//  PABLDetailScrollView.h
//  PABL
//
//  Created by seung jin park on 2016. 3. 5..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PABLDetailScrollViewDelegate <NSObject>

- (void)PABLDetailScrollViewDidTouched;

@end

@interface PABLDetailScrollView : UIView

@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSArray *photoArray;

@property (nonatomic, assign) id<PABLDetailScrollViewDelegate> delegate;

- (void)prepareToShowImage;

@end
