//
//  OXTowerView.m
//  OXHanoiDemo
//
//  Created by csdc-iMac on 2017/5/17.
//  Copyright © 2017年 Cloudox. All rights reserved.
//

#import "OXTowerView.h"

//设备的宽高
#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height

@implementation OXTowerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 竖线
        UIView *verticalView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-5)/2, 0, 5, self.frame.size.height-5)];
        verticalView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:verticalView];
        
        // 横线
        UIView *horizontalView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-5, self.frame.size.width, 5)];
        horizontalView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:horizontalView];
    }
    return self;
}

@end
