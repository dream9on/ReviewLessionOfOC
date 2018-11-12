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

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property NSString *name;

- (IBAction)Btn_usualBlock:(NSButton *)sender;

- (IBAction)Btn_SequenceBlock:(NSButton *)sender;

@end

