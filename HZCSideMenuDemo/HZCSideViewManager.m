//
//  QFFSideMenuManager.m
//  firefly
//
//  Created by QITMAC000242 on 17/6/21.
//  Copyright © 2017年 qunar. All rights reserved.
//

#import "HZCSideViewManager.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface HZCSideViewManager ()

@property (nonatomic, strong) UIView *mainView;         //主内容视图
@property (nonatomic, strong) UIView *sideMenuView;     //侧边栏菜单
@property (nonatomic, strong) UIView *shadowView;       //阴影浮层
@property (nonatomic, strong) UIView *middleView;       //中间层视图
@property (nonatomic, assign) CGFloat mainViewOffset;   //主视图偏移
@property (nonatomic, assign) CGFloat sideViewOffSet;   //侧边栏偏移
@property (nonatomic, assign) BOOL isPrepareed;         //是否准备好

@end

@implementation HZCSideViewManager

+ (instancetype)manager {
    static HZCSideViewManager *sideMenuManager = nil;
    if(!sideMenuManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sideMenuManager = [[HZCSideViewManager alloc]init];
        });
    }
    return sideMenuManager;
}

#pragma mark -外部接口实现

- (void)addSideMenuView:(UIView *)sideMenuView toCurrentViewController:(UIViewController *)currentViewController {
    _mainViewOffset = CGRectGetWidth(sideMenuView.frame);
    _sideViewOffSet = (SCREEN_WIDTH * 0.5f);
    
    //侧边栏视图
    _sideMenuView = sideMenuView;
    
    CGRect sideMenuViewFrame = CGRectMake(0 - _sideViewOffSet, CGRectGetMinY(sideMenuView.frame), CGRectGetWidth(sideMenuView.frame), CGRectGetHeight(sideMenuView.frame));
    _sideMenuView.frame = sideMenuViewFrame;
    
    //主内容视图
    if(currentViewController.navigationController) {
        _mainView = currentViewController.navigationController.view;
    }
    else if(currentViewController.tabBarController) {
        _mainView = currentViewController.tabBarController.view;
    }
    else {
        _mainView = currentViewController.view;
    }
    
    //阴影浮层
    CGRect shadowViewFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _shadowView = [[UIView alloc]initWithFrame:shadowViewFrame];
    //点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedShadowView:)];
    [_shadowView addGestureRecognizer:tap];
    //拖拽手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panedShadowView:)];
    [_mainView addGestureRecognizer:pan];
    
    //中间层视图
    self.middleView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.isPrepareed = NO;
}

- (void)showSideMenuList {
    [self preProcess];
    [self sideViewToLeft:1];
}

- (void)hideSideMenuList {
    [self sideViewToRight:1];
}

- (void)removeSideMenuView {
    _sideMenuView = nil;
    _mainView = nil;
    _shadowView = nil;
}

#pragma mark --事件
- (void)clickedShadowView:(UITapGestureRecognizer *)sender {
    [self sideViewToRight:1];
}

- (void)panedShadowView:(UIPanGestureRecognizer *)sender {
    [self preProcess];
    //起点 终点
    static CGFloat startPotionX;
    static CGFloat endPositonX;
    CGPoint touchPoint = [sender locationInView:[UIApplication sharedApplication].keyWindow];
    
    //手势开始
    if(sender.state == UIGestureRecognizerStateBegan) {
        startPotionX = touchPoint.x;
        endPositonX = touchPoint.x;
        
    }
    //手势变化
    else if(sender.state == UIGestureRecognizerStateChanged) {
        //主视图目标位置
        CGFloat targetPositionX = 0 + _mainViewOffset;
        //上一次位置
        CGFloat preEndPositionX = endPositonX;
        endPositonX = touchPoint.x;
        if(endPositonX > targetPositionX) {
            endPositonX = targetPositionX;
        }
        if(endPositonX < 0) {
            endPositonX = 0;
        }
        
        CGFloat currentMainViewOffset = endPositonX - preEndPositionX;
        
        CGFloat spaceXStart = 0;
        //右滑
        if(currentMainViewOffset > 0) {
            //1、算出右滑时，主视图离右边终点的距离
            CGFloat distanceOfMainViewToRightEnd = _mainViewOffset - endPositonX;
            
            //2、根据比例算出，侧边栏离右边终点（原点）的距离绝对值
            
            spaceXStart = 0 - distanceOfMainViewToRightEnd * (_sideViewOffSet / _mainViewOffset);
        }
        //左滑
        else {
            //1、算出左滑时，主视图离左边终点（原点）的距离
            CGFloat distanceOfMainViewToLeftEnd = endPositonX - 0;
            
            //2、根据比例算出，侧边栏距左边终点的距离
            CGFloat distanceOfSideViewToLeftEnd = distanceOfMainViewToLeftEnd * (_sideViewOffSet/_mainViewOffset);
            //3、根据左边终点位置和距离，算出当前位置
            spaceXStart = (0 - _sideViewOffSet) + distanceOfSideViewToLeftEnd;
        }
        
        _shadowView.alpha = 0.5 * (endPositonX/targetPositionX);
        _mainView.frame = CGRectMake(endPositonX, 0, CGRectGetWidth(_mainView.frame), CGRectGetHeight(_mainView.frame));

        _sideMenuView.frame = CGRectMake(spaceXStart, CGRectGetMinY(_sideMenuView.frame), CGRectGetWidth(_sideMenuView.frame), CGRectGetHeight(_sideMenuView.frame));
        
    }
    //手势结束
    else if(sender.state == UIGestureRecognizerStateEnded) {
        endPositonX = touchPoint.x;
        CGFloat midPointX =  _mainViewOffset / 2.f;
        CGFloat mainViewX = CGRectGetMinX(_mainView.frame);       //主视图当前的X值
        
        CGFloat currentMainViewOffset = fabs(endPositonX - startPotionX);
        CGFloat indx = (_mainViewOffset - currentMainViewOffset) / _mainViewOffset;
        
        //右滑（主视图偏移大于中点）
        if(mainViewX > midPointX) {
            [self sideViewToLeft:indx];
        }
        //左滑
        else {
            [self sideViewToRight:indx];
        }
    }
}

#pragma mark --相关内部方法
- (void)preProcess {
    if(!self.isPrepareed) {
        //添加阴影浮层
        _shadowView.backgroundColor = [UIColor grayColor];
        _shadowView.alpha = 0.01;
        [_mainView addSubview:_shadowView];
        
        //获取内容视图的父视图，插入中间层视图
        UIView *parentView = _mainView.superview;
        [parentView addSubview:self.middleView];
        
        //以中间层视图为父视图
        [self.middleView addSubview:_sideMenuView];
        [self.middleView addSubview:_mainView];
        self.isPrepareed = YES;
    }
    
}

- (void)finishProcess {
    [_shadowView removeFromSuperview];
    [_sideMenuView removeFromSuperview];
    [_mainView removeFromSuperview];
    
    //撤掉中间层，还原父视图
    UIView *parentView = self.middleView.superview;
    [parentView addSubview:_mainView];
    [self.middleView removeFromSuperview];
    self.isPrepareed = NO;
}

- (void)sideViewToLeft:(CGFloat)indx {
    [UIView animateWithDuration:0.3f*indx animations:^{
        //设置侧边栏便宜
        _sideMenuView.frame = CGRectMake(0, CGRectGetMinY(_sideMenuView.frame), CGRectGetWidth(_sideMenuView.frame), CGRectGetHeight(_sideMenuView.frame));
        
        //设置_mainView的偏移
        _mainView.frame = CGRectMake(_mainViewOffset, 0, CGRectGetWidth(_mainView.frame), CGRectGetHeight(_mainView.frame));
        
        //阴影浮层的透明度设置
        _shadowView.alpha = 0.5;
        _shadowView.backgroundColor = [UIColor grayColor];
    }];
}

- (void)sideViewToRight:(CGFloat)indx {
    [UIView animateWithDuration:0.3f*indx animations:^{
        //侧边栏偏移设置
        _sideMenuView.frame = CGRectMake(0 - _sideViewOffSet, CGRectGetMinY(_sideMenuView.frame), CGRectGetWidth(_sideMenuView.frame), CGRectGetHeight(_sideMenuView.frame));
        
        //主视图偏移设置
        _mainView.frame = CGRectMake(0, 0, CGRectGetWidth(_mainView.frame), CGRectGetHeight(_mainView.frame));
        
        //浮层背景色设置
        _shadowView.backgroundColor = [UIColor clearColor];
        _shadowView.opaque = YES;
        
    } completion:^(BOOL finished){
        if(finished) {
            [self finishProcess];
        }
    }];
}

@end
