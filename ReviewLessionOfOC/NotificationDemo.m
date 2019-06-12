//
//  NotificationDemo.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/22.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "NotificationDemo.h"

#define NOTIFICATION_1 @"Notification_1"
#define NOTIFICATION_2 @"Notification_2"
#define NOTIFICATION_3 @"Notification_3"

static int count =0;
/*
 通知和delegate的基本区别：
 
 通知是允许多对多的，而delegate只能是1对1的。
 通知是松耦合的，通知方不需要知道被通知方的任何情况，而delegate不行。
 通知的效率比起delegate略差。
 */
@implementation NotificationDemo
{
    // 该通知中心是Mac OS中，进程间通知使用
   // NSDistributedNotificationCenter *center;
}

//-(void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

// 1.添加Observer
-(void)bandObserver
{
    // 观察方式A:selector方式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doEvent) name:NOTIFICATION_1 object:nil];
    
    // 观察方式B:block方式(queue参数决定你想把该block在哪一个NSOperationQueue里面执行)
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_1 object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"Block run sequence: %d.",++count);
    }];
}


// 2.发送Notification
-(void)postNotification
{
    // 发送方式A:   手动定义NSNotification
    NSNotification *noti = [NSNotification notificationWithName:NOTIFICATION_1 object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:noti];
    
    // 发送方式B：  自动定义NSNotification
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_1 object:nil];
    
    NSLog(@"测试同步还是异步");
    /*
    2017-02-26 19:13:04.739 notification[15240:12674807] selector 1
    2017-02-26 19:13:04.743 notification[15240:12674807] block 2
    2017-02-26 19:13:04.743 notification[15240:12674807] selector 3
    2017-02-26 19:13:04.744 notification[15240:12674807] block 4
    2017-02-26 19:13:04.744 notification[15240:12674807] 测试同步还是异步

    链接：https://www.jianshu.com/p/356f7af4f2ee
    */
}



/** 同步or异步**/
//同步和异步都是相对于发送通知所在的线程的。

// 3.响应事件
-(void)doEvent
{
    NSLog(@"Selector run sequence: %d.",++count);
}



#pragma mark - Notification Queues & 异步通知







#pragma mark - NSUserNotification





//右上角弹框

//如果不设置代理，通知可能发送成功并显示在通知栏，但是不会弹出。打断点的话，会弹出。
- (void)sendNotice0{
    //设置通知的代理
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    
    NSUserNotification *localNotify = [[NSUserNotification alloc] init];
    localNotify.title = @"Title";//标题
    localNotify.subtitle = @"subTitle";//副标题
    
    //图片的相关设置
    //1.显示在弹窗右边的提示。
    localNotify.contentImage = [NSImage imageNamed:@"image1.jpeg"];
    //2.显示在推送左边的图片
   //
    [localNotify setValue:[NSImage imageNamed:@"image1.jpeg"] forKey:@"_identityImage"];
    //3.设置图片边框(私有属性)
    [localNotify setValue:@(1) forKey:@"_identityImageHasBorder"];
    
    localNotify.informativeText = @"body message";
    localNotify.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:localNotify];
    //设置通知的代理
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}


// 带有按钮的通知
- (void)sendNotice1{
    //设置通知的代理
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    NSUserNotification *localNotify = [[NSUserNotification alloc] init];
    
    localNotify.title = @"title";//标题
    localNotify.subtitle = @"subtitle";//副标题
    
    localNotify.informativeText = @"body message";
    localNotify.soundName = NSUserNotificationDefaultSoundName;
    
    //只有当用户设置为提示模式时，才会显示按钮.不设置的话，默认为yes
    localNotify.hasActionButton = YES;
    localNotify.actionButtonTitle = @"确定";
    localNotify.otherButtonTitle = @"取消";
    
    [localNotify setValue:@YES forKey:@"_showsButtons"]; //需要显示按钮

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:localNotify];
    //设置通知的代理
    //[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}



#pragma mark - NSUserNotificationCenterDelegate

//通知已经提交给通知中心
// Sent to the delegate when a notification delivery date has arrived. At this time, the notification has either been presented to the user or the notification center has decided not to present it because your application was already frontmost.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    NSLog(@"1 receive:UserNotificationCenter:%@,UserNotification:%@.",center,notification);
}


//用户已经点击了通知
// Sent to the delegate when a user clicks on a notification in the notification center. This would be a good time to take action in response to user interacting with a specific notification.
// Important: If want to take an action when your application is launched as a result of a user clicking on a notification, be sure to implement the applicationDidFinishLaunching: method on your NSApplicationDelegate. The notification parameter to that method has a userInfo dictionary, and that dictionary has the NSApplicationLaunchUserNotificationKey key. The value of that key is the NSUserNotification that caused the application to launch. The NSUserNotification is delivered to the NSApplication delegate because that message will be sent before your application has a chance to set a delegate for the NSUserNotificationCenter.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification;
{
    NSLog(@"2:UserNotificationCenter:%@,UserNotification:%@.",center,notification);
    NSLog(@"用户点击");
    NSLog(@"activationType : %ld , actualDeliveryDate : %@",(long)notification.activationType,notification.actualDeliveryDate);
    //如果推送有按钮，点击按钮时，activationType 会变为 2
}


//returen YES;强制显示(即不管通知是否过多)
// Sent to the delegate when the Notification Center has decided not to present your notification, for example when your application is front most. If you want the notification to be displayed anyway, return YES.
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    NSLog(@"3.shouldPresentnotification.");
    return YES;
}

@end
