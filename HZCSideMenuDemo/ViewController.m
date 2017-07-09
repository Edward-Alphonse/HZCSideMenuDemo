//
//  ViewController.m
//  DesignPattern
//
//  Created by QITMAC000242 on 17/6/12.
//  Copyright © 2017年 QITMAC000242. All rights reserved.
//

#define screenWidth             [UIScreen mainScreen].bounds.size.width
#define screenHeight            [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "HZCSideViewManager.h"
//#import "ChildViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect frame = CGRectMake(0, 0, screenWidth, 44);
    
    _navigationBar = [[UINavigationBar alloc]initWithFrame:frame];
    [self.view addSubview:_navigationBar];
    
    
    frame = CGRectMake(0, 44, screenWidth, screenHeight - 44);
    _tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:button];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth * 0.8f, screenHeight)];
    view.backgroundColor = [UIColor greenColor];
    [[HZCSideViewManager manager] addSideMenuView:view toCurrentViewController:self];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickButton:(id)sender
{
    [[HZCSideViewManager manager] showSideMenuList];
}


#pragma mark -UITableViewDelegate && UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        return cell;
    }
    return [[UITableViewCell alloc]init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

@end
