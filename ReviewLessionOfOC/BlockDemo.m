//
//  BlockDemo.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/1.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

/*
 Block 的各种写法  “^” 符号声明blockName为一个块对象
 1.As a local variable:              returnType (^blockName)(parameterTypes) = ^returnType(parameters) {...};
 2.As a property:                    @property (nonatomic, copy) returnType (^blockName)(parameterTypes);
 3.As a method parameter:            - (void)someMethodThatTakesABlock:(returnType (^)(parameterTypes))blockName;
 4.As an argument to a method call:  [someObject someMethodThatTakesABlock:^returnType (parameters) {...}];
 5.As a typedef:                     typedef returnType (^TypeName)(parameterTypes);
                                     TypeName blockName = ^returnType(parameters) {...};
 */


#import "BlockDemo.h"

@implementation BlockDemo


#pragma mark - 1.定义Block几种形式   ^返回值类型 (参数列表) 表达式
//1. 定义Block的方式：  returnType (^blockName)(parameterTypes) = ^returnType(parameters) {...};
-(void)definedBlock
{
    //1.1 无参数无返回值的Block
    void (^block1)(void)=^(){ // 括号可省略  「^{」
        NSLog(@"Hello,block1:这是一个无参数无返回值的Block.");
    };
    
    _myBlock1 =^{
        NSLog(@"This is _myBlock1 Function.");
    };
    
    // 执行Block1
    block1();
    _myBlock1();
    
    //1.2 有参数无返回值的Block
    void (^block2)(int age,NSString *name)=^(int age,NSString *name){
        NSString *infomation = [NSString stringWithFormat:@"Name:%@,Age:%d",name,age];
        NSLog(@"Hello,block2:这是一个有参数无返回值的Block.  Infomation:%@",infomation);
    };
    
    // 执行Block2
    block2(30,@"Jack");
    
    //1.3 无参数有返回值的Block
    int (^block3)(void) =^int{
        NSLog(@"Hello,block3:这是一个无参数有返回值的Block,返回值为int类型");
        return 5;
    };
    
    // 执行Block3
    block3();
    
    //1.4 有参数有返回值的Block
    NSString *(^block4)(NSString* name,NSString *sex,int age) = ^(NSString* name,NSString*sex,int age)
    {
        NSString *information = [NSString stringWithFormat:@"Name:%@,Sex:%@,Age:%d",name,sex,age];
        NSLog(@"Hello,block4:这是一个有参数有返回值的block,返回值为NSString类型");
        return information;
    };
    
    // 执行Block4
    NSString *msg = block4(@"Sam",@"M",40);
    
    //NSRunAlertPanel 的第二个参数为Format,参数放在最后--msg
    NSRunAlertPanel(@"msg", @"information: %@", @"OK", @"Cancel",nil,msg);
}




#pragma mark - 2.作为参数使用的Block

/**
 调用作为参数的Block方法
 */
-(void)asParameterBlock
{
    [self blockParameter1:^{
        NSLog(@"Block.parameter1");
    }];
    
    [self blockParameter2:^(NSString *name, int age) {
        NSLog(@"block2.parameters---Name :%@,Age:%d",name,age);
    }];
    
    [self blockParameter3:^NSString *{
        NSLog(@"block3.parameters -- null. return string.");
        return @"This is Block3";
    }];
    
    [self blockParameter4:^NSString *(NSString *name, int age) {
        // 按要求返回数据类型
        return [NSString stringWithFormat:@"Person information:name_%@,age_%d",name,age];
    }];
    
    NSString *str1 = @"rose";
    int num = 10;
    
    //调用Block时 是不可以直接外部传递参数,只可以内部传递参数 如name,age 的传递方法，不可以直接在第一行上写 str1，num
    [self blockParameter4:^NSString *(NSString *name,int age) {
        name = str1;
        age =num;
        
        return [NSString stringWithFormat:@"name:%@,age:%d",name,age];
    }];
}

/**
 1.无参数无返回值Block
 @param block1 p1
 */
-(void)blockParameter1:(void(^)(void))block1
{
    NSLog(@"*******************");
    NSLog(@"Method: %s",__func__);
    
    block1();
}

/**
 2.有参数无返回值Block
 @param block2 p1
 */
-(void)blockParameter2:(void(^)(NSString *name,int age))block2
{
    NSLog(@"*******************");
    NSLog(@"Method: %s",__func__);
    
    block2(@"Name",23);
}


/**
 3.有参数有返回值Block
 @param block3 p1
 */
-(void)blockParameter3:(NSString *(^)(void))block3
{
    NSLog(@"******** 无参数有返回值的Block ******");
    NSLog(@"Method: %s",__func__);
    NSLog(@"Block4 的返回值是： [%@].",block3());
}


/**
 4.有参数有返回值Block
 @param block4 p1
 */
-(void)blockParameter4:(NSString *(^)(NSString *name,int age))block4
{
    NSLog(@"*******************");
    NSLog(@"Method: %s",__func__);
    
    NSLog(@"Block3 的返回值是：[%@].",block4(@"Name",23));
}





#pragma mark - 3.作为返回值调用的Block
-(void)asFunctionResult
{
    int age =15;
    NSString *name = @"Rose";
    // 无参无返回值的Block
    [self repayBlock1]();
    
    // 有参无返回值的Block
    [self repayBlock2](age);
    
    // 无参有返回值的Block
    NSArray *arr = [self replyBlock3]();
    
    // 有参数有返回值的Block
    NSString *str = [self replyBlock4](age,name);
    NSLog(@"arr = %@,str = %@.",arr,str);
}


/**
  返回Block类型：无参数无返回值
 */
-(void(^)(void))repayBlock1
{
    void (^block1)(void) = ^(){    // 无参数时 括号可以省略
        NSLog(@"This is block1");
    };
    
    return block1;
}

/**
 返回Block类型：有参数无返回值
 @return void(^)(int age)   block
 */
-(void(^)(int age))repayBlock2
{
    void (^block2)(int age) = ^(int age){
        NSLog(@"This is block2");
    };
    
    return block2;
}

/**
 返回Block类型：无参数有返回值
 */
-(NSArray *(^)(void))replyBlock3
{
    NSArray *(^block3)(void) = ^()
    {
        NSArray * array = [NSArray arrayWithObjects:@"1",@"2",@"3", nil];
        return array;
    };
    
    return block3;
}

/**
 返回Block类型：有参数有返回值
 */
-(NSString *(^)(int age,NSString *name))replyBlock4
{
    NSString *(^block4)(int age,NSString *name) =^(int age,NSString *name)
    {
        return [NSString stringWithFormat:@"23"];
    };
    
    return block4;
}






#pragma mark - Block 信号量的使用


/**
 最普通的用法，Block会在线程中顺序执行，外部也会顺序执行
 */
-(void)usualBlock
{
    // 子线程进行运算不占用主线程资源（如UI）
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self blockParameter1:^{
            sleep(1);
            NSLog(@"1.block1 run.");
        }];
    });
    
    NSLog(@"2.usualBlock");

    /*
    2018-11-06 12:00:26.845883+0800 ReviewLessionOfOC[15821:2062519] 2.usualBlock
    2018-11-06 12:00:26.845891+0800 ReviewLessionOfOC[15821:2062577] *******************
    2018-11-06 12:00:26.845914+0800 ReviewLessionOfOC[15821:2062577] Method: -[BlockDemo blockParameter1:]
    2018-11-06 12:00:27.849197+0800 ReviewLessionOfOC[15821:2062577] 1.block1 run.
     */
}





//利用GCD的 dispatch_semaphore_t 设置线程依赖   Block的执行顺序
-(NSString *)blockSequenceRun
{
    __block NSString* alertStr;   //__block 修饰的作用
    
    // 创建一个全局队列
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 创建一个Semaphre 信号量（值为0）  不可以为负值
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(queue, ^{
        [self blockParameter1:^{
            
            int num=0;
            while (num<3) {
                sleep(1);
                NSLog(@"num= %d",++num);
            }
            //发出已完成的信号（信号量加1）
            dispatch_semaphore_signal(semaphore);
        }];
    });
    
    //等待执行，不会占用资源  （信号量减1，如果>0，则向下执行，否则等待）
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSLog(@"2.usualBlock");
    
    return alertStr;
    /*
    2018-11-06 13:21:53.252715+0800 ReviewLessionOfOC[16006:2093748] *******************
    2018-11-06 13:21:53.252764+0800 ReviewLessionOfOC[16006:2093748] Method: -[BlockDemo blockParameter1:]
    2018-11-06 13:21:54.258003+0800 ReviewLessionOfOC[16006:2093748] num= 1
    2018-11-06 13:21:55.262175+0800 ReviewLessionOfOC[16006:2093748] num= 2
    2018-11-06 13:21:56.266913+0800 ReviewLessionOfOC[16006:2093748] num= 3
    2018-11-06 13:21:56.267050+0800 ReviewLessionOfOC[16006:2094595] 2.usualBlock
    */
}




















@end
