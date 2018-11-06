//
//  TxtLog.h
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/6.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TxtLog : NSObject

+(void)WriteLog:(NSString*)path Content:(NSString*)content queue:(dispatch_queue_t)q;

@end

NS_ASSUME_NONNULL_END
