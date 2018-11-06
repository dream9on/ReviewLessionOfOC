//
//  BlockDemo.h
//  ReviewLessionOfOC
//  block作为属性,作为参数,作为返回值的各种情况演示
//  参考原文：https://blog.csdn.net/lybeen2007/article/details/48391339
//  Created by Dylan Xiao on 2018/11/1.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlockDemo : NSObject

#pragma mark  - block作为属性

/**<没有返回值,没有参数的block*/
@property (nonatomic,copy) void(^myBlock1)(void);

/**<有返回值,没有参数的block*/
@property (nonatomic,copy) int(^myBlock2)(void);

/**<没有返回值,有参数的block*/
@property (nonatomic, copy) void(^myBlock3)(int, int);

/**<有返回值,有参数的block*/
@property (nonatomic, copy) int(^myBlock4)(int, int);

/**<age*/
@property (nonatomic,assign) int age;




// 定义Block的几种方法
-(void)definedBlock;

// 作为参数的Block
-(void)asParameterBlock;

// 做为返回值的Block
-(void)asFunctionResult;



-(void)usualBlock;

-(NSString *)blockSequenceRun;
@end

NS_ASSUME_NONNULL_END
