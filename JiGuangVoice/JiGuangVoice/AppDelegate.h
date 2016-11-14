//
//  AppDelegate.h
//  JiGuangVoice
//
//  Created by yaoshuai on 2016/11/12.
//  Copyright © 2016年 yss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 需要播放的语音键值对
 */
@property(nonatomic,strong) NSMutableArray *voiceArray;

/**
 播放合成音效
 */
- (void)voicePlay;

@end
