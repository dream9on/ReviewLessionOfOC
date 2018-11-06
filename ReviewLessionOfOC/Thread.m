//
//  Thread.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/6.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "Thread.h"

@implementation Thread



#pragma mark - Dispatch GCD

//死锁
-(void)DeadLock
{
    //如果queue是一个串行队列的话，这段代码立即产生死锁： 不建议使用同步嵌套sync
    dispatch_queue_t queue = dispatch_queue_create("com.dispatch.deadlock", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        dispatch_sync(queue, ^{
            NSLog(@"deadlock internet run.");
        });
        NSLog(@"deadlock externet run.");
    });
    
}



/**
 写文件类:
 如果多个线程向同一个文件中写文件：必须使用一个队列queue,而且是DISPATCH_QUEUE_SERIAL(串行),数据不会丢失且完整。
 如果使用 DISPATCH_QUEUE_CONCURRENT(并发)会丢失数据
 
 下面的例子是 2个线程同时向同一个文件写log,第3个线程等待上面2个线程写完后，最后再写一个完成.
 要求：不可以丢失数据，线程3写入的数据一定是在最后
 */
-(void)writeLog
{
    // 1.创建一个文件的写入串行队列   【如果用DISPATCH_QUEUE_CONCURRENT 会丢失数据】
    dispatch_queue_t logQueue = dispatch_queue_create("com.dispatch.logQueue", DISPATCH_QUEUE_SERIAL);
    
    // 2.创建一个并行队列 执行GCD1.GCD2 写入文件 【如果用DISPATCH_QUEUE_SERIAL 会成为单线程顺序，无意义】
    dispatch_queue_t globalQueue =dispatch_queue_create("com.dispatch.GCD", DISPATCH_QUEUE_CONCURRENT);
    NSString *logpath = @"/vault/log.txt";
    
    // 3.GCD1 写Log
    dispatch_async(globalQueue, ^{
        int x = 0;
        while (x<5) {
            NSString *data = [NSString stringWithFormat:@"GCD1 %d_Time: %@",++x,[NSDate date]];
            NSLog(@"GCD1 Writelog: %d.",x);
            [TxtLog WriteLog:logpath Content:data queue:logQueue];
            sleep(1);
        }
    });
    
    // 4.GCD2 写Log
    dispatch_async(globalQueue, ^{
        int x = 0;
        while (x<5) {
            NSString *data = [NSString stringWithFormat:@"GCD2 %d_Time: %@",++x,[NSDate date]];
            NSLog(@"GCD2 Writelog: %d.",x);
            [TxtLog WriteLog:logpath Content:data queue:logQueue];
            sleep(1);
        }
    });
    
    // 等待DISPATCH_QUEUE_CONCURRENT 队列【GCD1,GCD2】完成后再执行
    dispatch_barrier_async(globalQueue, ^{
        NSLog(@"write complete.");
        [TxtLog WriteLog:logpath Content:@"Write complete." queue:logQueue];
    });
    
    /*  正确的log格式
    GCD1 1_Time: 2018-11-06 09:09:16 +0000
    GCD2 1_Time: 2018-11-06 09:09:16 +0000
    GCD1 2_Time: 2018-11-06 09:09:17 +0000
    GCD2 2_Time: 2018-11-06 09:09:17 +0000
    GCD1 3_Time: 2018-11-06 09:09:18 +0000
    GCD2 3_Time: 2018-11-06 09:09:18 +0000
    GCD1 4_Time: 2018-11-06 09:09:19 +0000
    GCD2 4_Time: 2018-11-06 09:09:19 +0000
    GCD1 5_Time: 2018-11-06 09:09:20 +0000
    GCD2 5_Time: 2018-11-06 09:09:20 +0000
    Write complete.
    */
    
    /* 错误的log格式
     如果使用DISPATCH_QUEUE_CONCURRENT  会丢失数据
    GCD1 1_Time: 2018-11-06 08:47:27 +0000
    GCD2 2_Time: 2018-11-06 08:47:28 +0000
    GCD1 2_Time: 2018-11-06 08:47:28 +0000
    GCD1 3_Time: 2018-11-06 08:47:29 +0000
    GCD1 4_Time: 2018-11-06 08:47:30 +0000
    GCD2 5_Time: 2018-11-06 08:47:31 +0000
    CD1 5_Time: 2018-11-06 08:47:31 +0000
     
    GCD2 1_Time: 2018-11-06 08:48:00 +0000
    GCD1 2_Time: 2018-11-06 08:48:01 +0000
    GCD2 3_Time: 2018-11-06 08:48:02 +0000
    GCD2 4_Time: 2018-11-06 08:48:03 +0000
    GCD2 5_Time: 2018-11-06 08:48:04 +0000
     */
    
}



-(void)dispatchQueueApply
{
    //void dispatch_apply(size_t iterations, dispatch_queue_t queue, void (^block)(size_t));
    //重复执行block，需要注意的是这个方法是同步返回，也就是说等到所有block执行完毕才返回，如需异步返回则嵌套在dispatch_async中来使用。多个block的运行是否并发或串行执行也依赖queue的是否并发或串行。
    
    dispatch_queue_t queue = dispatch_queue_create("com.Dispatch.Apply", DISPATCH_QUEUE_CONCURRENT);
    
    // 多次执行block --10次
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"Apply index=%ld",index);
    });
    
    NSLog(@"Well done.");
    
    /*
    2018-11-06 19:46:27.842695+0800 ReviewLessionOfOC[18472:2423251] Apply index=1
    2018-11-06 19:46:27.842687+0800 ReviewLessionOfOC[18472:2423215] Apply index=0
    2018-11-06 19:46:27.842719+0800 ReviewLessionOfOC[18472:2423241] Apply index=2
    2018-11-06 19:46:27.842727+0800 ReviewLessionOfOC[18472:2423243] Apply index=3
    2018-11-06 19:46:27.842727+0800 ReviewLessionOfOC[18472:2423215] Apply index=5
    2018-11-06 19:46:27.842727+0800 ReviewLessionOfOC[18472:2423251] Apply index=4
    2018-11-06 19:46:27.842742+0800 ReviewLessionOfOC[18472:2423241] Apply index=6
    2018-11-06 19:46:27.842742+0800 ReviewLessionOfOC[18472:2423243] Apply index=7
    2018-11-06 19:46:27.842743+0800 ReviewLessionOfOC[18472:2423215] Apply index=9
    2018-11-06 19:46:27.842743+0800 ReviewLessionOfOC[18472:2423251] Apply index=8
    2018-11-06 19:46:27.842760+0800 ReviewLessionOfOC[18472:2423215] Well done.
    */
}



//#多线程 设定执行顺序

//经常有这样的需求：
//1，有m个网络请求。
//2，先并发执行其中n几个。
//3，待这n个请求完成之后再执行第n+1个请求。
//4然后等 第n+1个请求完成后再并发执行剩下的m-(n+1)个请求。

-(void)DownloadFilesWithGCD{
    dispatch_queue_t queue = dispatch_queue_create("downQueue",DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"gcd任务1");
        sleep(3);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"gcd任务2");
        sleep(1);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"gcd任务3");
        sleep(3);
    });
    
    //void dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
    //这个函数可以设置同步执行的block，它会等到在它加入队列之前的block执行完毕后，才开始执行。在它之后加入队列的block，则等到这个block执行完毕后才开始执行。
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"gcd处理任务 1 2 3");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"gcd任务4");
        [self downloadFilesWithNSOperation];
    });
    
    dispatch_async(queue, ^{
        NSLog(@"gcd任务5");
        sleep(3);
    });
    
    
    
    

    
    /*
     Dispatch Queues的生成可以有这几种方式：
     
     1. dispatch_queue_t queue = dispatch_queue_create("com.dispatch.serial", DISPATCH_QUEUE_SERIAL); //生成一个串行队列，队列中的block按照先进先出（FIFO）的顺序去执行，实际上为单线程执行。第一个参数是队列的名称，在调试程序时会非常有用，所有尽量不要重名了。
     
     2. dispatch_queue_t queue = dispatch_queue_create("com.dispatch.concurrent", DISPATCH_QUEUE_CONCURRENT); //生成一个并发执行队列，block被分发到多个线程去执行
     
     3. dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); //获得程序进程缺省产生的并发队列，可设定优先级来选择高、中、低三个优先级队列。由于是系统默认生成的，所以无法调用dispatch_resume()和dispatch_suspend()来控制执行继续或中断。需要注意的是，三个队列不代表三个线程，可能会有更多的线程。并发队列可以根据实际情况来自动产生合理的线程数，也可理解为dispatch队列实现了一个线程池的管理，对于程序逻辑是透明的。
     
     官网文档解释说共有三个并发队列，但实际还有一个更低优先级的队列，设置优先级为DISPATCH_QUEUE_PRIORITY_BACKGROUND。Xcode调试时可以观察到正在使用的各个dispatch队列。
     
     4. dispatch_queue_t queue = dispatch_get_main_queue(); //获得主线程的dispatch队列，实际是一个串行队列。同样无法控制主线程dispatch队列的执行继续或中断。
     
     接下来我们可以使用dispatch_async或dispatch_sync函数来加载需要运行的block。
     dispatch_async(queue, ^{
        //block具体代码
     }); //异步执行block，函数立即返回
     
     dispatch_sync(queue, ^{
        //block具体代码
     });
     //同步执行block，函数不返回，一直等到block执行完毕。编译器会根据实际情况优化代码，所以有时候你会发现block其实还在当前线程上执行，并没用产生新线程。
     
     实际编程经验告诉我们，尽可能避免使用dispatch_sync，嵌套使用时还容易引起程序死锁。
     如果queue1是一个串行队列的话，这段代码立即产生死锁：
     dispatch_sync(queue1, ^{
        dispatch_sync(queue1, ^{
            ......
        });
        ......
     });
     
     那实际运用中，一般可以用dispatch这样来写，常见的网络请求数据多线程执行模型：
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         //子线程中开始网络请求数据
         ......
     
         //更新数据模型
         dispatch_sync(dispatch_get_main_queue(), ^{
            //在主线程中更新UI代码
            ......
         });
     });
     
     程序的后台运行和UI更新代码紧凑，代码逻辑一目了然。
     
     dispatch队列是线程安全的，可以利用串行队列实现锁的功能。比如多线程写同一数据库，需要保持写入的顺序和每次写入的完整性，简单地利用串行队列即可实现：
     dispatch_queue_t queue1 = dispatch_queue_create("com.dispatch.writedb", DISPATCH_QUEUE_SERIAL);
     
      - (void)writeDB:(NSData *)data
      {
      　　dispatch_async(queue1, ^{
      　　　　//write database
      　　});
      }
      下一次调用writeDB:必须等到上次调用完成后才能进行，保证writeDB:方法是线程安全的。
 
      dispatch队列还实现其它一些常用函数，包括：
      void dispatch_apply(size_t iterations, dispatch_queue_t queue, void (^block)(size_t)); //重复执行block，需要注意的是这个方法是同步返回，也就是说等到所有block执行完毕才返回，如需异步返回则嵌套在dispatch_async中来使用。多个block的运行是否并发或串行执行也依赖queue的是否并发或串行。
 
      void dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block); //这个函数可以设置同步执行的block，它会等到在它加入队列之前的block执行完毕后，才开始执行。在它之后加入队列的block，则等到这个block执行完毕后才开始执行。
 
      void dispatch_barrier_sync(dispatch_queue_t queue, dispatch_block_t block); //同上，除了它是同步返回函数
 
      void dispatch_after(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block); //延迟执行block
 
      最后再来看看dispatch队列的一个很有特色的函数：
      void dispatch_set_target_queue(dispatch_object_t object, dispatch_queue_t queue);
      它会把需要执行的任务对象指定到不同的队列中去处理，这个任务对象可以是dispatch队列，也可以是dispatch源（以后博文会介绍）。而且这个过程可以是动态的，可以实现队列的动态调度管理等等.
     比如说有两个队列dispatchA和dispatchB，这时把dispatchA指派到dispatchB：
      dispatch_set_target_queue(dispatchA, dispatchB);
      那么dispatchA上还未运行的block会在dispatchB上运行。这时如果暂停dispatchA运行：
      dispatch_suspend(dispatchA);
      则只会暂停dispatchA上原来的block的执行，dispatchB的block则不受影响。而如果暂停dispatchB的运行，则会暂停dispatchA的运行。
      */
    
    //    参考：http://www.cnblogs.com/sunfrog/p/3305614.html
}

- (void)downloadFilesWithNSOperation{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op任务1");
        sleep(5);
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op任务2");
        sleep(2);
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op任务3");
        sleep(3);
    }];
    
    [op3 addDependency:op1]; // 添加依赖关系 op3 在 op1 完成以后执行
    [op3 addDependency:op2]; // 添加依赖关系 op3 在 op2 完成以后执行
    
    //设置队列中操作同时执行的最大数目，也就是说当前队列中呢最多由几个线程在同时执行，一般情况下允许最大的并发数2或者3
    [queue setMaxConcurrentOperationCount:3];
    [queue addOperations:@[op1,op2,op3] waitUntilFinished:YES];
    
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op任务4");
        sleep(3);
    }];

    NSBlockOperation *op5 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op任务5");
    }];

    NSOperationQueue *queue1 = [[NSOperationQueue alloc]init];
    [op4 addDependency:op3]; // 添加依赖关系 op4 在 op3 完成以后执行
    [op5 addDependency:op3]; // 添加依赖关系 op5 在 op3 完成以后执行

    //    - (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait;
    
    //批量加入执行operation，wait标志是否当前线程等待所有operation结束后，才返回
    [queue1 addOperations:@[op4,op5] waitUntilFinished:YES];
    
    /*
     NSOperation 常用方法：
          - (void)start; //在当前任务状态和依赖关系合适的情况下，启动NSOperation的main方法任务，需要注意缺省实现只是在当前线程运行。如果需要并发执行，子类必须重写这个方法，并且使 - (BOOL)isConcurrent 方法返回YES
          - (void)main; //定义NSOperation的主要任务代码
          - (BOOL)isCancelled; //当前任务状态是否已标记为取消
          - (void)cancel; //取消当前NSOperation任务，实质是标记isCancelled状态
          - (BOOL)isExecuting; //NSOperation任务是否在运行
          - (BOOL)isFinished; //NSOperation任务是否已结束
     
          NSOperation其它常用方法，包括依赖关系：
          - (BOOL)isReady; //是否能准备运行，这个值和任务的依赖关系相关
          - (void)addDependency:(NSOperation *)op; //加上任务的依赖，也就是说依赖的任务都完成后，才能执行当前任务
          - (void)removeDependency:(NSOperation *)op; //取消任务的依赖，依赖的任务关系不会自动消除，必须调用该方法
          - (NSArray *)dependencies; //得到所有依赖的NSOperation任务
     
          以及用于任务同步：
          - (void)waitUntilFinished; //阻塞当前线程，直到该NSOperation结束。可用于线程执行顺序的同步
          - (void)setCompletionBlock:(void (^)(void))block; //设置NSOperation结束后运行的block代码，由于NSOperation有可能被取消，所以这个block运行的代码应该和NSOperation的核心任务无关。
     
          NSOperationQueue的其它常用方法：
          - (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait; //批量加入执行operation，wait标志是否当前线程等待所有operation结束后，才返回
          - (void)addOperationWithBlock:(void (^)(void))block; //相当于加入一个NSBlockOperation执行任务
          - (NSArray *)operations; //返回已加入执行operation的数组，当某个operation结束后会自动从这个数组清除
          - (NSUInteger)operationCount //返回已加入执行operation的数目
          - (void)setSuspended:(BOOL)b; //是否暂停将要执行的operation，但不会暂停已开始的operation
          - (BOOL)isSuspended; //返回暂停标志
          - (void)cancelAllOperations; //取消所有operation的执行，实质是调用各个operation的cancel方法
          + (id)currentQueue; //返回当前NSOperationQueue，如果当前线程不是在NSOperationQueue上运行则返回nil
     + (id)mainQueue; //返回主线程的NSOperationQueue，缺省总是有一个queue
          */
    //    参考： http://www.jb51.net/article/130108.htm
    
}





@end
