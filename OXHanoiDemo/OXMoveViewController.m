//
//  OXMoveViewController.m
//  OXHanoiDemo 演示移动动画的界面
//
//  Created by Cloudox on 2017/5/8.
//  Copyright © 2017年 Cloudox. All rights reserved.
//

#import "OXMoveViewController.h"

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
@property (nonatomic, strong) NSMutableArray *towerCountArray;// 塔包含的盘子的数量
@property (nonatomic, strong) NSMutableArray *towerYArray;// 塔高度的Y值

@end

@implementation OXMoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"演示动画";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.diskArray = [[NSMutableArray alloc] init];
    self.towerCountArray = [[NSMutableArray alloc] init];
    self.towerYArray = [[NSMutableArray alloc] init];
    
    [self.towerCountArray addObjectsFromArray:[NSArray arrayWithObjects:[NSNumber numberWithInteger:self.diskNumber], @0, @0, nil]];
    
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

// 三根杆子
- (void)initThreeTower {
    // 添加三座塔
    NSInteger height = (SCREENHEIGHT - 150)/3 - 30;
    for (int i = 0; i < 3; i++) {
        // 竖线
        UIView *verticalView = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH-5)/2, 130 + (height+30)*i, 5, height)];
        verticalView.backgroundColor = [UIColor darkGrayColor];
        [self.view addSubview:verticalView];
        
        [self.towerYArray addObject:@(130 + (height+30)*i)];
        
        // 横线
        UIView *horizontalView = [[UIView alloc] initWithFrame:CGRectMake((SCREENWIDTH-250)/2, verticalView.frame.origin.y + height, 250, 5)];
        horizontalView.backgroundColor = [UIColor darkGrayColor];
        [self.view addSubview:horizontalView];
        
        // 塔号
        UILabel *towerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, horizontalView.frame.origin.y+5, SCREENWIDTH-24, 15)];
        switch (i) {
            case 0:
                towerLabel.text = @"A";
                break;
                
            case 1:
                towerLabel.text = @"B";
                break;
                
            case 2:
                towerLabel.text = @"C";
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
    [self hanoiWithDisk:self.diskNumber towers:@"A" :@"B" :@"C"];
    NSLog(@">>移动了%ld次", self.moveCount);
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
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);// 初始化信号量为0
    NSLog(@"第%ld次移动：把%ld号盘从%@移动到%@", ++self.moveCount, diskIndex, fromTower, toTower);
    
    for (OXDiskModel *disk in self.diskArray) {
        if (disk.index == diskIndex) {
            
            WeakSelf
            [UIView animateWithDuration:0.5 animations:^{
                StrongSelf
                if (strongSelf) {
                    // 改变盘子的位置
                    CGPoint diskCenter = disk.center;
                    NSInteger towerY = 10;
                    NSInteger hasDiskHieght = 0;// 已放置了的盘子高度
                    NSInteger towerHeight = (SCREENHEIGHT - 150)/3 - 40;
                    NSInteger diskHeight = towerHeight / strongSelf.diskNumber;// 每个盘子高度
                    if ([toTower isEqualToString:@"A"]) {
                        towerY += [[strongSelf.towerYArray objectAtIndex:0] integerValue];
                        hasDiskHieght = diskHeight * [[strongSelf.towerCountArray objectAtIndex:0] integerValue];
                    } else if ([toTower isEqualToString:@"B"]) {
                        towerY += [[strongSelf.towerYArray objectAtIndex:1] integerValue];
                        hasDiskHieght = diskHeight * [[strongSelf.towerCountArray objectAtIndex:1] integerValue];
                    } else if ([toTower isEqualToString:@"C"]) {
                        towerY += [[strongSelf.towerYArray objectAtIndex:2] integerValue];
                        hasDiskHieght = diskHeight * [[strongSelf.towerCountArray objectAtIndex:2] integerValue];
                    }
                    
                    diskCenter.y = towerY + (towerHeight - hasDiskHieght) - diskHeight/2;
                    disk.center = diskCenter;
                }
                dispatch_semaphore_signal(sema);// 增加信号量
            }];
            
            break;
        }
    }
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);// 信号量若没增加，则一直等待
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
