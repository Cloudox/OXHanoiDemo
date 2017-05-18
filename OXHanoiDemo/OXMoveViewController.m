//
//  OXMoveViewController.m
//  OXHanoiDemo 演示移动动画的界面
//
//  Created by Cloudox on 2017/5/8.
//  Copyright © 2017年 Cloudox. All rights reserved.
//

#import "OXMoveViewController.h"
#import "OXTowerView.h"

//设备的宽高
#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height
// block解决循环引用
#define WeakSelf   __typeof(&*self) __weak weakSelf = self;
#define StrongSelf __typeof(&*self) __strong strongSelf = weakSelf;

#pragma mark - Disk Model
// 自定义的盘子模型，在UIView基础上加上编号属性
@interface OXDiskModel : UIView
@property NSInteger index;
@end

@implementation OXDiskModel

@end


#pragma mark - OXMoveViewController
@interface OXMoveViewController ()

@property (nonatomic, strong) NSMutableArray *diskArray;// 盘子对象数组
@property NSInteger moveCount;// 移动次数
@property (nonatomic, strong) NSMutableArray *towerArray;// 塔对象数组

@end

@implementation OXMoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"演示动画";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.diskArray = [[NSMutableArray alloc] init];
    self.towerArray = [[NSMutableArray alloc] init];
    
    // 添加三座塔
    [self initThreeTower];
    
    // 初始放置盘子
    [self initWithDiskPut];
    
    // 确定按钮
    UIButton *beginBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH-100)/2, 80, 100, 30)];
    [beginBtn setTitle:@"开始" forState:UIControlStateNormal];
    [beginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    beginBtn.backgroundColor = [UIColor darkGrayColor];
    beginBtn.layer.cornerRadius = 4;
    beginBtn.layer.masksToBounds = YES;
    [beginBtn addTarget:self action:@selector(beginMove) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beginBtn];
}

// 三座塔
- (void)initThreeTower {
    // 添加三座塔
    NSInteger height = (SCREENHEIGHT - 150)/3 - 30;
    for (int i = 0; i < 3; i++) {
        OXTowerView *tower = [[OXTowerView alloc] initWithFrame:CGRectMake((SCREENWIDTH-250)/2, 130 + (height+30)*i, 250, height+5)];
        tower.diskNumber = 0;
        [self.view addSubview:tower];
        [self.towerArray addObject:tower];
        
        // 塔号
        UILabel *towerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, tower.frame.origin.y + height + 5, SCREENWIDTH-24, 15)];
        switch (i) {
            case 0:
                towerLabel.text = @"A";
                tower.towerId = @"A";
                tower.diskNumber = self.diskNumber;// 一开始盘子都在塔A上
                break;
                
            case 1:
                towerLabel.text = @"B";
                tower.towerId = @"B";
                break;
                
            case 2:
                towerLabel.text = @"C";
                tower.towerId = @"C";
                break;
                
            default:
                break;
        }
        towerLabel.textColor = [UIColor darkGrayColor];
        towerLabel.textAlignment = NSTextAlignmentCenter;
        towerLabel.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:towerLabel];
    }
}

// 初始放置盘子
- (void)initWithDiskPut {
    NSInteger towerHeight = (SCREENHEIGHT - 150)/3 - 40;
    NSInteger diskHeight = towerHeight / self.diskNumber;// 盘子高度
    
    // 依次放置盘子
    for (int i = 0; i < self.diskNumber; i++) {
        NSInteger diskWeight = 230 - 30*i;// 盘子宽度
        
        // 自定义的盘子模型类
        OXDiskModel *disk = [[OXDiskModel alloc] initWithFrame:CGRectMake((SCREENWIDTH-diskWeight)/2, 140 + diskHeight*(self.diskNumber-i-1), diskWeight, diskHeight)];
        disk.backgroundColor = [UIColor yellowColor];
        disk.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        disk.layer.borderWidth = 1;
        disk.index = self.diskNumber - i;
        [self.view addSubview:disk];
        [self.diskArray addObject:disk];
    }
}

// 开始移动
- (void)beginMove {
    self.moveCount = 0;
    
    WeakSelf
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{// 到分线程去处理算法
        StrongSelf
        if (strongSelf) {
            [strongSelf hanoiWithDisk:strongSelf.diskNumber towers:[strongSelf.towerArray objectAtIndex:0] :[strongSelf.towerArray objectAtIndex:1] :[strongSelf.towerArray objectAtIndex:2]];
        }
    });
    
//    NSLog(@">>移动了%ld次", self.moveCount);
    
    
}

// 移动算法
- (void)hanoiWithDisk:(NSInteger)diskNumber towers:(OXTowerView *)towerA :(OXTowerView *)towerB :(OXTowerView *)towerC {
    if (diskNumber == 1) {// 只有一个盘子则直接从A塔移动到C塔
        [self move:1 from:towerA to:towerC];
    } else {
        [self hanoiWithDisk:diskNumber-1 towers:towerA :towerC :towerB];// 递归把A塔上编号1~diskNumber-1的盘子移动到B塔，C塔辅助
        
        [self move:diskNumber from:towerA to:towerC];// 把A塔上编号为diskNumber的盘子移动到C塔
        
        [self hanoiWithDisk:diskNumber-1 towers:towerB :towerA :towerC];// 递归把B塔上编号1~diskNumber-1的盘子移动到C塔，A塔辅助
        
    }
}

// 移动过程
- (void)move:(NSInteger)diskIndex from:(OXTowerView *)fromTower to:(OXTowerView *)toTower {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);// 初始化信号量为0
    
    NSLog(@"第%ld次移动：把%ld号盘从塔%@移动到塔%@", ++self.moveCount, diskIndex, fromTower.towerId, toTower.towerId);
    
    for (OXDiskModel *disk in self.diskArray) {
        if (disk.index == diskIndex) {
            
            WeakSelf
            dispatch_async(dispatch_get_main_queue(), ^{// 切回主线程进行移动动画
                [UIView animateWithDuration:1.0 animations:^{
                    StrongSelf
                    if (strongSelf) {
                        // 改变盘子的位置
                        CGPoint diskCenter = disk.center;
                        NSInteger towerY = 10 + toTower.frame.origin.y;
                        NSInteger towerHeight = toTower.frame.size.height-15;
                        NSInteger diskHeight = towerHeight / strongSelf.diskNumber;// 每个盘子高度
                        NSInteger hasDiskHieght = diskHeight * toTower.diskNumber;// 已放置了的盘子高度
                        diskCenter.y = towerY + (towerHeight - hasDiskHieght) - diskHeight/2;
                        disk.center = diskCenter;
                    }
                    
                } completion:^(BOOL finished) {
                    if (finished) {// 动画完成
                        StrongSelf
                        if (strongSelf) {
                            // 改变fromTower的盘子数量
                            fromTower.diskNumber--;
                            
                            // 改变toTower的盘子数量
                            toTower.diskNumber++;
                            
                            dispatch_semaphore_signal(sema);// 增加信号量，结束等待
                        }
                    }
                }];
            });
            
            
            break;
        }
    }
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);// 信号量若没增加，则一直等待，直到动画完成
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
