//
//  Person.h
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/15.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Money : NSObject
@property NSString *bank;

@end

NS_ASSUME_NONNULL_BEGIN


@interface Person : NSObject
{
    NSString *_sex;
}

@property (nonatomic,retain) NSString* name;
@property (nonatomic,strong) NSString* age;
@property (nonatomic,strong) Money* money;
-(void)doEvent:(NSNotification *)n;
@end

NS_ASSUME_NONNULL_END
