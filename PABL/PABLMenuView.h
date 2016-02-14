//
//  PABLMenuView.h
//  PABL
//
//  Created by seung jin park on 2016. 2. 14..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PABLMenuViewDelegate <NSObject>

- (void)didTouchedCloseButton;

@end

@interface PABLMenuView : UIView

@property (nonatomic, assign) id<PABLMenuViewDelegate> delegate;

@end
