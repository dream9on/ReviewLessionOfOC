//
//  TxtLog.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/6.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "TxtLog.h"

@implementation TxtLog

/**
 写文件类:
 如果多个线程向同一个文件中写文件：必须使用一个队列queue,而且是DISPATCH_QUEUE_SERIAL(串行),数据不会丢失且完整。
 如果使用 DISPATCH_QUEUE_CONCURRENT(并发)会丢失数据
 */
+(void)WriteLog:(NSString*)path Content:(NSString*)content queue:(dispatch_queue_t)q
{
    dispatch_sync(q, ^{
        NSFileManager* fileManger = [NSFileManager defaultManager];
        
        if (![fileManger fileExistsAtPath:path])
        {
            BOOL result= [fileManger createFileAtPath:path contents:nil attributes:nil];
            NSLog(@"create file[%@] %@.",path,result?@"SUCCESS":@"FAIL");
        }
        
        NSFileHandle* handle = [NSFileHandle fileHandleForUpdatingAtPath:path];
        
        if (handle)
        {
            [handle seekToEndOfFile];
            [handle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            [handle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [handle closeFile];
        }
        
    });
}

+(void) CreateDirPath:(NSString*)path
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    BOOL isDir = YES;
    
    if (![manager fileExistsAtPath:path isDirectory:&isDir])
    {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+(void)CreateLog:(NSString*)path
{
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir = [fm fileExistsAtPath:path isDirectory:nil];
    
    if(!isDir)
    {
        [fm createFileAtPath:path contents:nil attributes:nil];
    }
}
@end
