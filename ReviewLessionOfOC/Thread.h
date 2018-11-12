//
//  Thread.h
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/6.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TxtLog.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface Thread : NSObject

@property NSThread *thread;


-(void)DeadLock;
-(void)writeLog;

-(void)dispatchQueueApply;
-(void)DownloadFilesWithGCD;

+(void)createLoop;


-(void)timer:(NSTextField *)label label2:(NSTextField *)label2;
@end

NS_ASSUME_NONNULL_END
