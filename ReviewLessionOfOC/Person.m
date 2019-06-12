//
//  Person.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/15.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "Person.h"

@implementation Money

@end


@implementation Person

+(BOOL)automaticallyNotifiesObserversOfName
{
    return YES;
}

+(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    NSLog(@"autonaticallyNotifiesObserversForKey:%@",key);
    return YES;
}

-(instancetype)init
{
    if (self = [super init]) {
        _money = [[Money alloc] init];
    }
    return self;
}

-(void)setBank
{
    _money.bank = @"Chinese";
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"object = %@,keypath =%@,change =%@.",object,keyPath,change);
}


//  Event of notification observer
-(void)doEvent:(NSNotification *)n
{
    NSLog(@"notification=%@,person event done.",n);
}

@end
