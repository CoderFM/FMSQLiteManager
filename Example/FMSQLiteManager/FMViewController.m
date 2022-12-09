//
//  FMViewController.m
//  FMSQLiteManager
//
//  Created by zhoufaming251@163.com on 11/23/2022.
//  Copyright (c) 2022 zhoufaming251@163.com. All rights reserved.
//

#import "FMViewController.h"
#import "FMSQLiteManager.h"
#import "AccountModel.h"

#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject]

@interface FMViewController ()

@property(nonatomic, strong)FMSQLiteManager *sqliteManager;
@property(nonatomic, strong)AccountModel *model;

@end

@implementation FMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sqliteManager = [FMSQLiteManager managerWithDBPath:[DB_PATH stringByAppendingPathComponent:@"test.db"]];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"测试" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button sizeToFit];
    button.center = self.view.center;
    [button addTarget:self action:@selector(customMethod) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"%@", button.allTargets);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)customMethod{
    NSLog(@"customMethod");
    long long userID = (long long)[NSDate date].timeIntervalSince1970;
    AccountModel *model = [[AccountModel alloc] init];
    model.addDate = [NSDate date];
    model.userID = userID;
    model.customID = @"";
    model.avatar = @"";
    model.nickname = [NSString stringWithFormat:@"nickname %lld", userID];
    model.updateDate = [NSDate date];
    [self.sqliteManager saveObject:model];
    self.model = model;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.model.updateDate = [NSDate date];
    self.model.nickname = @"zfm";
    self.model.avatar = @"url";
    [self.sqliteManager updateObject:self.model columns:@[@"updateDate", @"nickname", @"avatar"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
