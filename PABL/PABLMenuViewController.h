//
//  PABLMenuViewController.h
//  PABL
//
//  Created by seung jin park on 2016. 2. 9..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PABLMenuView.h"
#import "PABLPhotoView.h"

@protocol PABLMenuViewControllerDelegate <NSObject>

- (void)PABLMenuViewControllerDidTouchCloseButton;

@end

@interface PABLMenuViewController : UIViewController

@property (nonatomic, strong) id<PABLMenuViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *photoArray;

- (instancetype)initWithViewController:(UIViewController *)viewController;
- (void)closeMenuViewController;

@end
