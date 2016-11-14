//
//  ViewController.m
//  JiGuangVoice
//
//  Created by yaoshuai on 2016/11/12.
//  Copyright © 2016年 yss. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)beginPlay:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.voiceArray = [NSMutableArray arrayWithArray:@[@"你已经",@"骑行",@"1",@"百",@"2",@"十",@"3",@".",@"5",@"8",@"公里",@"用时",@"3",@"小时",@"2",@"十",@"7",@"分钟",@"平均速度",@"3",@"十",@"7",@"公里每小时",@"太棒了"]];
    [delegate voicePlay];
}

@end
