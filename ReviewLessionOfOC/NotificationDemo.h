//
//  NotificationDemo.h
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/22.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN

@interface NotificationDemo : NSObject<NSUserNotificationCenterDelegate>
{
    //NSUserNotificationCenter *center;
    id  NSUserNotificationCenterDelegate_delegate;
}

// 1.添加Observer
-(void)bandObserver;
// 2.发送Notification
-(void)postNotification;

- (void)sendNotice0;
- (void)sendNotice1;
@end

NS_ASSUME_NONNULL_END
