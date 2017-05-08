//
//  ViewController.m
//  OXHanoiDemo 输入层数N的界面
//
//  Created by Cloudox on 2017/5/8.
//  Copyright © 2017年 Cloudox. All rights reserved.
//

#import "ViewController.h"
#import "OXMoveViewController.h"

//设备的宽高
#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property NSInteger diskNumber;// 盘子数
@property (nonatomic, strong) UITextField *numberField;// 输入框
@property NSInteger moveCount;// 移动次数

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"输入层数";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 说明文字
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 150, SCREENWIDTH - 24, 20)];
    infoLabel.text = @"请输入汉诺塔层数";
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:infoLabel];
    
    
    // 输入框
    self.numberField = [[UITextField alloc] initWithFrame:CGRectMake(50, 200, SCREENWIDTH - 100, 30)];
    self.numberField.placeholder = @"层数";
    self.numberField.textAlignment = NSTextAlignmentCenter;
    self.numberField.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    self.numberField.layer.borderWidth = 1;
    self.numberField.layer.cornerRadius = 4;
    self.numberField.layer.masksToBounds = YES;
    [self.view addSubview:self.numberField];
    
    // 确定按钮
    UIButton *submitBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH-100)/2, 300, 100, 30)];
    [submitBtn setTitle:@"确定" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitBtn.backgroundColor = [UIColor darkGrayColor];
    submitBtn.layer.cornerRadius = 4;
    submitBtn.layer.masksToBounds = YES;
    [submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
}

// 确定提交
- (void)submit {
    if ([self.numberField.text isEqualToString:@""]) {
        NSLog(@"未输入内容");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未输入层数!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        self.diskNumber = [self.numberField.text integerValue];
        
        OXMoveViewController *moveVC = [[OXMoveViewController alloc] init];
        moveVC.diskNumber = self.diskNumber;
        [self.navigationController pushViewController:moveVC animated:YES];
        
        
        
//        self.moveCount = 0;
//        [self hanoiWithDisk:self.diskNumber towers:@"A" :@"B" :@"C"];
//        NSLog(@">>移动了%ld次", self.moveCount);
    }
}

// 移动算法
- (void)hanoiWithDisk:(NSInteger)diskNumber towers:(NSString *)towerA :(NSString *)towerB :(NSString *)towerC {
    if (diskNumber == 1) {// 只有一个盘子则直接从A塔移动到C塔
        [self move:1 from:towerA to:towerC];
    } else {
        [self hanoiWithDisk:diskNumber-1 towers:towerA :towerC :towerB];// 递归把A塔上编号1~diskNumber-1的盘子移动到B塔，C塔辅助
        [self move:diskNumber from:towerA to:towerC];// 把A塔上编号为diskNumber的盘子移动到C塔
        [self hanoiWithDisk:diskNumber-1 towers:towerB :towerA :towerC];// 递归把B塔上编号1~diskNumber-1的盘子移动到C塔，A塔辅助
    }
}

// 移动过程
- (void)move:(NSInteger)diskIndex from:(NSString *)fromTower to:(NSString *)toTower {
    NSLog(@"第%ld次移动：把%ld号盘从%@移动到%@", ++self.moveCount, diskIndex, fromTower, toTower);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
