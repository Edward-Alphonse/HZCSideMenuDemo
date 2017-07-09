//
//  QFFSideMenuManager.h
//  firefly
//
//  Created by QITMAC000242 on 17/6/21.
//  Copyright © 2017年 qunar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HZCSideViewManager : NSObject

NS_ASSUME_NONNULL_BEGIN
+ (instancetype)manager;

- (void)addSideMenuView:(UIView *)sideMenuView toCurrentViewController:(UIViewController *)currentViewController;
- (void)showSideMenuList;
- (void)hideSideMenuList;

- (void)removeSideMenuView;

NS_ASSUME_NONNULL_END
@end
