//
//  AppDelegate.h
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/1.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ReviewStrongVsCopy.h"
#import "BlockDemo.h"
#import "Thread.h"
#import "SscanfDemo.h"

#import "KvcKvoDemo.h"
#import "NotificationDemo.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSUserNotificationCenterDelegate>
{
    NSString *strArr[30];
    KvcKvoDemo *kvcoDemo;
}
@property NSString *name;

- (IBAction)Btn_usualBlock:(NSButton *)sender;

- (IBAction)Btn_SequenceBlock:(NSButton *)sender;
- (IBAction)Btn_KvoDemo:(NSButton *)sender;
- (IBAction)Btn_UserNotification:(NSButton *)sender;
- (IBAction)Btn_Notification:(NSButton *)sender;

@end

