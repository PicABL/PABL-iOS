//
//  PABLMenuViewController.h
//  PABL
//
//  Created by seung jin park on 2016. 2. 9..
//  Copyright © 2016년 Pekaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PABLMenuViewControllerDelegate <NSObject>

- (void)PABLMenuViewControllerDidTouchCloseButton;

@end

@interface PABLMenuViewController : UIImagePickerController

@property (nonatomic, strong) id<PABLMenuViewControllerDelegate> PABLDelegate;

- (instancetype)initWithViewController:(UIViewController *)viewController;
- (void)closeMenuViewController;

@end
