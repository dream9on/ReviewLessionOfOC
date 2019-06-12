//
//  KvcKvoDemo.h
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/15.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface KvcKvoDemo : NSObject
{
    Person *p1;
    id _observer;
}
-(void)kvcDemo;
-(void)kvoDemo;
-(void)changeP1Name:(NSString *)name Bank:(NSString *)bank;
-(void)createNotification;
@end

NS_ASSUME_NONNULL_END
