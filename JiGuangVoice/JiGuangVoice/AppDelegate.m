//
//  AppDelegate.m
//  JiGuangVoice
//
//  Created by yaoshuai on 2016/11/12.
//  Copyright © 2016年 yss. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>


@interface AppDelegate ()<JPUSHRegisterDelegate>

/**
 语音播放器
 */
@property(nonatomic,strong) AVPlayer *voicePlayer;

/**
 系统提供的声音字典
 */
@property(nonatomic,strong) NSDictionary *voiceDictionary;

@end

@implementation AppDelegate

#pragma mark - 属性懒加载
- (AVPlayer *)voicePlayer{
    if(_voicePlayer == nil){
        _voicePlayer = [[AVPlayer alloc] init];
    }
    return _voicePlayer;
}
- (NSDictionary *)voiceDictionary{
    if(_voiceDictionary == nil){
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"voice" withExtension:@"json" subdirectory:@"voice.bundle"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        _voiceDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    return _voiceDictionary;
}
- (NSMutableArray *)voiceArray{
    if(_voiceArray == nil){
        _voiceArray = [NSMutableArray arrayWithArray:@[@"你已经",@"骑行",@"1",@"百",@"2",@"十",@"3",@".",@"5",@"8",@"公里",@"用时",@"3",@"小时",@"2",@"十",@"7",@"分钟",@"平均速度",@"3",@"十",@"7",@"公里每小时",@"太棒了"]];
    }
    return _voiceArray;
}

#pragma mark - 播放合成音效
- (void)voicePlay{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self playFirstVoice];
}

- (void)playFirstVoice{
    if(!self.voiceArray.count){
        // 禁用音乐会话
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        return;
    }
    
    NSString *key = self.voiceArray.firstObject;
    
    [self.voiceArray removeObjectAtIndex:0];
    
    NSString *mp3 = self.voiceDictionary[key];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:mp3 withExtension:nil subdirectory:@"voice.bundle"];
    
    if(!url){
        [self playFirstVoice];
        NSLog(@"%@ 对应的 mp3 没有找到",key);
        return;
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    
    [self.voicePlayer replaceCurrentItemWithPlayerItem:item];
    
    [self.voicePlayer play];
}

- (void)playItemDidEnd:(NSNotification *)noti{
    [self playFirstVoice];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 系统方法：AppDelegate代理方法

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playItemDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:NULL];
    
    
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
    }
    
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:@"11026c72c5b583635e00e45c"
                          channel:@"App Store"
                 apsForProduction:0
            advertisingIdentifier:advertisingId];
    
    return YES;
}



- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"deviceToken:%@",deviceToken);
    [JPUSHService registerDeviceToken:deviceToken];
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    
    _voiceArray = [NSMutableArray arrayWithArray:@[@"你已经",@"骑行",@"1",@"百",@"2",@"十",@"3",@".",@"5",@"8",@"公里",@"用时",@"3",@"小时",@"2",@"十",@"7",@"分钟",@"平均速度",@"3",@"十",@"7",@"公里每小时",@"太棒了"]];
    [self voicePlay];
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    
    _voiceArray = [NSMutableArray arrayWithArray:@[@"你已经",@"骑行",@"1",@"百",@"2",@"十",@"3",@".",@"5",@"8",@"公里",@"用时",@"3",@"小时",@"2",@"十",@"7",@"分钟",@"平均速度",@"3",@"十",@"7",@"公里每小时",@"太棒了"]];
    [self voicePlay];

    
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    
    _voiceArray = [NSMutableArray arrayWithArray:@[@"你已经",@"骑行",@"1",@"百",@"2",@"十",@"3",@".",@"5",@"8",@"公里",@"用时",@"3",@"小时",@"2",@"十",@"7",@"分钟",@"平均速度",@"3",@"十",@"7",@"公里每小时",@"太棒了"]];
    [self voicePlay];
    
    //语音播报
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:userInfo[@"aps"][@"alert"]];
    
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    
    [synth speakUtterance:utterance];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    _voiceArray = [NSMutableArray arrayWithArray:@[@"你已经",@"骑行",@"1",@"百",@"2",@"十",@"3",@".",@"5",@"8",@"公里",@"用时",@"3",@"小时",@"2",@"十",@"7",@"分钟",@"平均速度",@"3",@"十",@"7",@"公里每小时",@"太棒了"]];
    [self voicePlay];
    
    //语音播报
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:userInfo[@"aps"][@"alert"]];
    
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    
    [synth speakUtterance:utterance];
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}

@end
