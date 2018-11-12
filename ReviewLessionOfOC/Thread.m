//
//  Thread.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/6.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "Thread.h"

@implementation Thread
{
    NSTimer *timer1,*timer2;
}

#pragma mark - 一.NSThread

/*
对于多线程的开发，iOS系统提供了多种不同的接口，先谈谈iOS多线程最基础方面的使用。产生线程的方式姑且分两类，一类是显式调用，另一类是隐式调用。

一、显示调用的类为NSThread。一般构造NSThread的线程对象可通过两种方式：
1. 初始化线程主方法：
[NSThread detachNewThreadSelector:@selector(run:) toTarget:target withObject:obj];//类方法
或
NSThread *newThread = [[NSThread alloc] initWithTarget:target selector:@selector(run:) object:obj];//实例方法可以拿到线程对象，便于以后终止线程。

2. 定义NSThread的子类MyThread，然后实现main方法（即方法1中的run）。然后创建新对象:
MyThread *newThread = [[MyThread alloc] init];
启动线程：[newThread start];
终止线程：实际上没有真正提供终止线程的api，但有个cancel方法可以利用; 它改变线程运行的一个状态标志，我们可以这样来利用：

先在run:或main方法中这样实现线程循环：
- (void)main
{
    // thread init
    while (![[NSThread currentThread] isCancelled])
    {
        // thread loop
        [NSThread sleepForTimeInterval:1.0]; //等同于sleep(1);
    }
    
    // release resources of thread
}

这时如果调用[newThread cancel]; 就可以终止线程循环了。
NSThread有个类方法exit是用于立即结束当前线程的运行（不安全），因为无法保证当前线程对资源的释放，所以不推荐使用。像java中Thread的stop方法也被弃用一样，因为不安全。

 
二、隐式调用
通过NSObject的Category方法调用，罗列如下：
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait; //在主线程中运行方法，wait表示是否阻塞这个方法的调用，如果为YES则等待主线程中运行方法结束。一般可用于在子线程中调用UI方法。
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)wait; //在指定线程中执行，但该线程必须具备run loop。
- (void)performSelectorInBackground:(SEL)aSelector withObject:(id)arg; //隐含产生新线程。


三、NSThread的其它一些常用的方法
创建的线程是非关联线程（detached thread），即父线程和子线程没有执行依赖关系，父线程结束并不意味子线程结束。

1. + (NSThread *)currentThread; //获得当前线程
2. + (void)sleepForTimeInterval:(NSTimeInterval)ti; //线程休眠
3. + (NSThread *)mainThread; //主线程，亦即UI线程了
4. - (BOOL)isMainThread; + (BOOL)isMainThread; //当前线程是否主线程
5. - (BOOL)isExecuting; //线程是否正在运行
6. - (BOOL)isFinished; //线程是否已结束


四、一些非线程调用（NSObject的Category方法）
即在当前线程执行，注意它们会阻塞当前线程（包括UI线程）：
- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

以下调用在当前线程延迟执行，如果当前线程没有显式使用NSRunLoop或已退出就无法执行了，需要注意这点：
- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes;
- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;

而且它们可以被终止：
+ (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anArgument;
+ (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget;


五、线程执行顺序
通常UI需要显示网络数据时，可以简单地利用线程的执行顺序，避免显式的线程同步：

1. UI线程调用
[threadObj performSelectorInBackground:@selector(loadData) withObject:nil];

2. 子线程中回调UI线程来更新UI
- (void)loadData
{
    //query data from network
    //update data model
    //callback UI thread
    [uiObj performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
}

也可以使用NSThread实现同样的功能，loadData相当于NSThread的main方法。
*/



#pragma mark - 二.Lock

/*
谈到线程同步，一般指如何对线程间共享数据的同步读写，如何避免混乱的读写结果。一个基本的解决办法就是使用锁（LOCK）。
iOS提供多种同步锁的类和方法，这里介绍下基本用法。

1. NSLock：最基本的同步锁，使用lock来获得锁，unlock释放锁。如果其它线程已经使用lock，这时lock方法会阻塞当前线程，直到其它线程调用unlock释放锁为止。
           NSLock锁一般用于简单的同步算法。比如生产者线程产生数据（produce），消费线程显示数据（consume），可以这样实现：

- (void)produce
{
    while (1)
    {
        [theLock lock];
        // create data
        [theLock unlock];
    }
}

- (void)consume
{
    while (1)
    {
        if ([theLock tryLock])
        {
            // display data
            [theLock unlock];
        }
        
        sleep(1.0); //sleep a while
    }
}

 NSLock的tryLock方法可以避免阻塞当前线程，如果不能获得锁则返回NO。也可使用：
 - (BOOL)lockBeforeDate:(NSDate *)limit; 设置超时返回时间。
 
 
 
 2. NSConditionLock，即条件锁，可以设置自定义的条件来获得锁。比如上面的例子可以这样改用条件锁实现：
 
 - (void)produce
 {
 　　while (1)
 　　{
 　　　　[theLock lockWhenCondition:NO_DATA];
 　　　　// create data
 　　　　[theLock unlockWithCondition:HAS_DATA];
 　　}
 }
 
 - (void)consume
 {
 　　while (1)
 　　{
 　　　　if ([theLock tryLockWhenCondition:HAS_DATA])
 　　　　{
            // display data
 　　　　　　[theLock unlockWithCondition:NO_DATA];
 　　　　}
 
 　　　　sleep(1.0); //sleep a while
 　　}
 }
 
 
 
 3. NSCondition：条件（一种信号量），类似Java中的Condition，但有所不同的是NSCondition是锁和条件的组合实现。wait方法用于线程的等待（相当于Java Condition的await())，然后通过signal方法通知等待线程（相当于Java Condition的signal())，或者broadcast通知所有等待的线程相当于Java Condition的signalAll())。一个简单生产消费同步例子：
 
 - (void)produce
 {
 　　[theLock lock];
 　　// create data
 　　hasData = YES;
 　　[theLock signal]; //这时通知调用wait的线程结束等待并返回
 　　[theLock unlock];
 }
 
 - (void)consume
 {
 　　[theLock lock];
 　　while (!hasData)
 　　　　[theLock wait]; //注意：这时其它线程的lock调用会成功返回
 　　//display data
 　　hasData = NO;
 　　[theLock unlock];
 }
 
 
 
 4. NSRecursiveLock：递归锁，顾名思义一般用于递归程序。它可以让同一线程多次获得锁，解锁次数也必须相同，然后锁才能被其它线程获得。看下官网文档中的简单例子就能明白：
 
 void MyRecursiveFunction(int value)
 {
 　　[theLock lock];
 　　if (value != 0)
 　　{
 　　　　--value;
 　　　　MyRecursiveFunction(value);
 　　}
 
 　　[theLock unlock];
 }
 
 当然不只用于递归程序，类似Java中的ReentrantLock。
 
 
 
 5. @synchronized实现对象锁，类似Java中synchronized关键词。一般这样使用，但不多啰嗦了：

 @synchronized(anObj)
 {
    //......
 }
 
*/



#pragma mark - 三.RunLoop

+(void)createLoop
{
    __block int count = 0;
    NSPort *port = [NSPort port];
    //1.建立一个一般的线程
    NSThread *thread_1 = [[NSThread alloc] initWithBlock:^{
        NSLog(@"thread_1 run. count = %d.",++count);
        NSRunLoop *loop = [NSRunLoop currentRunLoop];

        NSTimer *timer1 =  [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:2] interval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"Default count++ = %d。",count++);
            //[loop addTimer:timer forMode:NSRunLoopCommonModes];
        }];
        
        [loop addTimer:timer1 forMode:NSDefaultRunLoopMode];
        [timer1 fire];
        
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"common count = %d",count++);
            [loop addTimer:timer forMode:NSRunLoopCommonModes];
        }];
        
        //Ps:Runloop运行首先判断Mode是否为空，如果为空则退出循环，还可以通过removePort来移除端口。本例用添加port来实现，其他方法请读者自己多尝试。：）
        if (loop.currentMode != NSDefaultRunLoopMode) {
            //[loop removePort:port forMode:NSDefaultRunLoopMode];
            [loop removePort:port forMode:NSRunLoopCommonModes];
            [loop addPort:port forMode:NSDefaultRunLoopMode];
            
        }else{
            //   通过添加port 或者timer 保持线程存在
            [loop removePort:port forMode:NSDefaultRunLoopMode];
            [loop addPort:port forMode:NSRunLoopCommonModes];
        }
        
        [loop run];
    }];
    
    //2.线程命名
    [thread_1 setName:@"myThread_1"];
    [thread_1 start];
    
    
    //CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    
    /*
    2018-11-07 19:08:33.868255+0800 ReviewLessionOfOC[34747:2983936]
     Thread1.current loop. = <CFRunLoop 0x6040001e4f00 [0x7fffa8742af0]>{wakeup port = 0x710f, stopped = false, ignoreWakeUps = true,
        current mode = (none),
        common modes = <CFBasicHash 0x6040002584e0 [0x7fffa8742af0]>{type = mutable set, count = 1,
            entries =>
            2 : <CFString 0x7fffa864d178 [0x7fffa8742af0]>{contents = "kCFRunLoopDefaultMode"}
        },
        common mode items = (null),
        modes = <CFBasicHash 0x6040004413e0 [0x7fffa8742af0]>{type = mutable set, count = 1,
            entries =>
            2 : <CFRunLoopMode 0x6040001860b0 [0x7fffa8742af0]>{name = kCFRunLoopDefaultMode, port set = 0xd703, queue = 0x604000144620, source = 0x604000182b10 (not fired), timer port = 0x12803,
                sources0 = (null),
                sources1 = (null),
                observers = (null),
                timers = (null),
                currently 563281714 (193802166931086) / soft deadline in: 1.84465503e+10 sec (@ -1) / hard deadline in: 1.84465503e+10 sec (@ -1)
            },
        }
    }
    */
}

/*
弄清楚NSRunLoop确实需要花时间，这个类的概念和模式似乎是Apple的平台独有（iOS+MacOSX），很难彻底搞懂（iOS没开源，呜呜）。
官网的解释是说run loop可以用于处理异步事件，很抽象的说法。不罗嗦，先看看NSRunLoop几个常用的方法。

+ (NSRunLoop *)currentRunLoop; //获得当前线程的run loop
+ (NSRunLoop *)mainRunLoop; //获得主线程的run loop
- (void)run; //进入处理事件循环，如果没有事件则立刻返回。注意：主线程上调用这个方法会导致无法返回（进入无限循环，虽然不会阻塞主线程），因为主线程一般总是会有事件处理。
- (void)runUntilDate:(NSDate *)limitDate; //同run方法，增加超时参数limitDate，避免进入无限循环。使用在UI线程（亦即主线程）上，可以达到暂停的效果。
- (BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)limitDate; //等待消息处理，好比在PC终端窗口上等待键盘输入。一旦有合适事件（mode相当于定义了事件的类型）被处理了，则立刻返回；类同run方法，如果没有事件处理也立刻返回；有否事件处理由返回布尔值判断。同样limitDate为超时参数。
- (void)acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limitDate; //似乎和runMode:差不多（测试过是这种结果，但确定是否有其它特殊情况下的不同），没有BOOL返回值。

官网文档也提到run和runUntilDate:会以NSDefaultRunLoopMode参数调用runMode:来处理事件。

当app运行后，iOS系统已经帮助主线程启动一个run loop，而一般线程则需要手动来启动run loop。
使用run loop的一个好处就是避免线程轮询的开销，run loop在无事件处理时可以自动进入睡眠状态，降低CPU的能耗。
比如一般线程轮询的方式为：
while (condition)
{
　　// waiting for new data
　　sleep(1);
　　// process current data
}

其实这种方式是很能消耗CPU时间片的，如果在UI线程中这样使用还会阻塞UI响应。而改用NSRunLoop来实现，则可大大改善线程的执行效率，而且不会阻塞UI（很神奇，呵呵。有点像javascript，用单线程实现多线程的效果）。上面的例子可以改为：

while (condition)
{
　　// waiting for new data
　　if ([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
　　{
　　　　// process current data
　　}
}

接下来我们看看具体的例子，包括如何实现线程执行的关联同步（join），以及UI线程run loop的一般使用技巧等。
假设有个线程A，它会启动线程B，然后等待B线程的结束。NSThread是没有join的方法，用run loop方式实现就比较精巧。
NSThread *A; //global
A = [[NSThread alloc] initWithTarget:self selector:@selector(runA) object:nil]; //生成线程A

[A start]; //启动线程A
- (void)runA
{
　　[NSThread detachNewThreadSelector:@selector(runB) toTarget:self withObject:nil]; //生成线程B
　　while (1)
　　{
　　　　if ([[NSRunLoop currentRunLoop] runMode:@"CustomRunLoopMode" beforeDate:[NSDate distantFuture]]) //相当于join
　　　　{
　　　　　　NSLog(@"线程B结束");
　　　　　　break;
　　　　}
　　}
}

- (void)runB
{
　　sleep(1);
　　[self performSelector:@selector(setData) onThread:A withObject:nil waitUntilDone:YES modes:@[@"CustomRunLoopMode"]];
}

实际运行时，过1秒后线程A也会自动结束。这里用到自定义的mode，一般在UI线程上调用run loop会使用缺省的mode。结合while循环，UI线程就可以实现子线程的同步运行（具体例子这里不再描述，可参看：http://www.cnblogs.com/tangbinblog/archive/2012/12/07/2807088.html）。

下面罗列调用主线程的run loop的各种方式，读者可以加深理解：

[[NSRunLoop mainRunLoop] run]; //主线程永远等待，但让出主线程时间片
[[NSRunLoop mainRunLoop] runUntilDate:[NSDate distantFuture]]; //等同上面调用
[[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]]; //立即返回
[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10.0]]; //主线程等待，但让出主线程时间片，然后过10秒后返回
[[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]]; //主线程等待，但让出主线程时间片；有事件到达就返回，比如点击UI等。
[[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date]]; //立即返回
[[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate dateWithTimeIntervalSinceNow:10.0]]; //主线程等待，但让出主线程时间片；有事件到达就返回，如果没有则过10秒返回。

*/


/*
 ⭐️ NSRunLoop 接口
 //运行 NSRunLoop，运行模式为默认的NSDefaultRunLoopMode模式，没有超时限制
 - (void)run;
 //运行 NSRunLoop: 参数为运时间期限，运行模式为默认的NSDefaultRunLoopMode模式
 - (void)runUntilDate:(NSDate *)limitDate;
 //运行 NSRunLoop: 参数为运行模式、时间期限，返回值为YES表示是处理事件后返回的，NO表示是超时或者停止运行导致返回的
 - (BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)limitDate;
 
 ⭐️ CFRunLoopRef的运行接口
 //运行 CFRunLoopRef
 void CFRunLoopRun();
 //运行 CFRunLoopRef: 参数为运行模式、时间和是否在处理Input Source后退出标志，返回值是exit原因
 SInt32 CFRunLoopRunInMode (mode, seconds, returnAfterSourceHandled);
 //停止运行 CFRunLoopRef
 void CFRunLoopStop( CFRunLoopRef rl );
 //唤醒CFRunLoopRef
 void CFRunLoopWakeUp ( CFRunLoopRef rl );

 */





// 这种方式叫做 source0
-(void)RunLoopDemo1
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"线程开始");
        //获取当前线程
        self.thread = [NSThread currentThread];
        NSRunLoop *runloop  = [NSRunLoop currentRunLoop];
        // 添加一个Port 防止runloop无事件直接退出
        [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        //运行一个runloop [NSDate distantFuture]: 很久后才失效
        [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        NSLog(@"线程结束");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //在开启的异步线程中调用方法
            [self performSelector:@selector(recieveMsg) onThread:self.thread withObject:nil waitUntilDone:NO];
        });
        
    });
}

-(void)recieveMsg
{
    NSLog(@"收到消息，在这个线程：%@",[NSThread currentThread]);
}

/*
/// RunLoop的实现
int CFRunLoopRunSpecific(runloop, modeName, seconds, stopAfterHandle) {
    
    /// 首先根据modeName找到对应mode
    CFRunLoopModeRef currentMode = __CFRunLoopFindMode(runloop, modeName, false);
    /// 如果mode里没有source/timer/observer, 直接返回。
    if (__CFRunLoopModeIsEmpty(currentMode)) return;
    
    /// 1. 通知 Observers: RunLoop 即将进入 loop。
    __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopEntry);
    
    /// 内部函数，进入loop
    __CFRunLoopRun(runloop, currentMode, seconds, returnAfterSourceHandled) {
        
        Boolean sourceHandledThisLoop = NO;
        int retVal = 0;
        do {
            
            /// 2. 通知 Observers: RunLoop 即将触发 Timer 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeTimers);
            /// 3. 通知 Observers: RunLoop 即将触发 Source0 (非port) 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeSources);
            /// 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);
            
            /// 4. RunLoop 触发 Source0 (非port) 回调。
            sourceHandledThisLoop = __CFRunLoopDoSources0(runloop, currentMode, stopAfterHandle);
            /// 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);
            
            /// 5. 如果有 Source1 (基于port) 处于 ready 状态，直接处理这个 Source1 然后跳转去处理消息。
            if (__Source0DidDispatchPortLastTime) {
                Boolean hasMsg = __CFRunLoopServiceMachPort(dispatchPort, &msg)
                if (hasMsg) goto handle_msg;
            }
            
            /// 6.通知 Observers: RunLoop 的线程即将进入休眠(sleep)。
            if (!sourceHandledThisLoop) {
                __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeWaiting);
            }
            
            /// 7. 调用 mach_msg 等待接受 mach_port 的消息。线程将进入休眠, 直到被下面某一个事件唤醒。
            /// ? 一个基于 port 的Source 的事件。
            /// ? 一个 Timer 到时间了
            /// ? RunLoop 自身的超时时间到了
            /// ? 被其他什么调用者手动唤醒
            __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort) {
                mach_msg(msg, MACH_RCV_MSG, port); // thread wait for receive msg
            }
            
            /// 8. 通知 Observers: RunLoop 的线程刚刚被唤醒了。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopAfterWaiting);
            
            /// 9.收到消息，处理消息。
        handle_msg:
            
            /// 10.1 如果一个 Timer 到时间了，触发这个Timer的回调。
            if (msg_is_timer) {
                __CFRunLoopDoTimers(runloop, currentMode, mach_absolute_time())
            }
            
            /// 10.2 如果有dispatch到main_queue的block，执行block。
            else if (msg_is_dispatch) {
                __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
            }
            
            /// 10.3 如果一个 Source1 (基于port) 发出事件了，处理这个事件
            else {
                CFRunLoopSourceRef source1 = __CFRunLoopModeFindSourceForMachPort(runloop, currentMode, livePort);
                sourceHandledThisLoop = __CFRunLoopDoSource1(runloop, currentMode, source1, msg);
                if (sourceHandledThisLoop) {
                    mach_msg(reply, MACH_SEND_MSG, reply);
                }
            }
            
            /// 执行加入到Loop的block
            __CFRunLoopDoBlocks(runloop, currentMode);
            
            
            if (sourceHandledThisLoop && stopAfterHandle) {
                /// 进入loop时参数说处理完事件就返回。
                retVal = kCFRunLoopRunHandledSource;
            } else if (timeout) {
                /// 超出传入参数标记的超时时间了
                retVal = kCFRunLoopRunTimedOut;
            } else if (__CFRunLoopIsStopped(runloop)) {
                /// 被外部调用者强制停止了
                retVal = kCFRunLoopRunStopped;
            } else if (__CFRunLoopModeIsEmpty(runloop, currentMode)) {
                /// source/timer/observer一个都没有了
                retVal = kCFRunLoopRunFinished;
            }
            
            /// 如果没超时，mode里没空，loop也没被停止，那继续loop。
        } while (retVal == 0);
    }
    
    /// 11. 通知 Observers: RunLoop 即将退出。
    __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
}

作者：涂耀辉
链接：https://www.jianshu.com/p/4d5b6fc33519
來源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
*/

#pragma mark - 四. NSTimer
/*
理解run loop后，才能彻底理解NSTimer的实现原理，也就是说NSTimer实际上依赖run loop实现的。
先看看NSTimer的两个常用方法：

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo; //生成timer但不执行

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo; //生成timer并且纳入当前线程的run loop来执行

NSRunLoop与timer有关方法为：
- (void)addTimer:(NSTimer *)timer forMode:(NSString *)mode; //在run loop上注册timer
主线程已经有run loop，所以NSTimer一般在主线程上运行都不必再调用addTimer:。但在非主线程上运行必须配置run loop，该线程的main方法示例代码如下：

- (void)main
{
　　NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
　　NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

　　[runLoop addTimer:myTimer forMode:NSDefaultRunLoopMode]; //实际上这步是不需要，scheduledTimerWithTimeInterval已经纳入当前线程运行。如果使用timerWithTimeInterval则需要

　　while (condition)
　　　　[runLoop run];
}

实际上这个线程无法退出，因为有timer事件需要处理，[runLoop run]会一直无法返回。解决办法就是设置一个截止时间：
[runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10.0]]; //每隔10秒检查下线程循环条件，当然时间值可以根据实际情况来定。

我们通常在主线程中使用NSTimer，有个实际遇到的问题需要注意。当滑动界面或按住界面控件不放时，系统为了更好地处理UI事件和滚动显示，主线程runloop会暂时停止处理一些其它事件，这时主线程中运行的NSTimer就会被暂停。解决办法就是改变NSTimer运行的mode（mode可以看成事件类型），不使用缺省的NSDefaultRunLoopMode，而是改用NSRunLoopCommonModes，这样主线程就会继续处理NSTimer事件了。具体代码如下：

NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
大家可以参看博文http://bluevt.org/?p=209，加深理解NSTimer和NSRunLoop的关系。

以前博文中提到延迟调用的方法，其实就是在当前线程的run loop上注册timer来实现定时运行的。所以如果是在非主线程上使用，一定要有一个run loop。
- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes;
- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;
*/

-(void)timer:(NSTextField *)label label2:(NSTextField *)label2
{
    if (timer1.valid) {
        [timer1 invalidate];
    }

    if (timer2.valid) {
        [timer2 invalidate];
    }

    // 该方法创建的Timer默认添加到当前Runloop，并且模式是kCFRunloopDefaultMode。当UI主界面有操控动作时,runloop为了更好的处理UI事件,主线程runloop会暂停其他NSTimer.
    timer1 =  [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        label.intValue = label.intValue+1;

        // 解决办法：将NSTimer添加到占位模式
         [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }];

    __block int count =0;
    timer2= [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        label2.stringValue = [NSString stringWithFormat:@"EventRacking: %d",count++];

        // 将NSTimer添加到事件追踪模式  --不与UI同一模式
       // [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:@"CustomerRunLoopMode"];
    }];
}


// GCD 定时器
 /*GCD定时器的优点有很多，首先不受Mode的影响，而NSTimer受Mode影响时常不能正常工作，除此之外GCD的精确度明显高于NSTimer，这些优点让我们有必要了解GCD定时器这种方法。
  1.1.2.2  CFRunloopSourceRef  事件源(输入源)
  　　按照苹果官方文档,Source分类
  　　Port-Based  Sources  基于端口的  和其他线程 或者内核
  　　Custom Input  Sources
  　　Cocoa   Perform   Selector  Sources
  
  　　按照函数调用栈来分类
  　　Source0 :   非基于Port的
  　　Source1:   基于port的，通过内核 和其他线程通信，接收、分发事件。
  
  1.1.2.3  CFRunloopObservorRef  观察者监听runloop状态改变
  
   // Run Loop Observer Activities
   typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
        kCFRunLoopEntry = (1UL << 0),
        kCFRunLoopBeforeTimers = (1UL << 1),
        kCFRunLoopBeforeSources = (1UL << 2),
        kCFRunLoopBeforeWaiting = (1UL << 5),
        kCFRunLoopAfterWaiting = (1UL << 6),
        kCFRunLoopExit = (1UL << 7),
        kCFRunLoopAllActivities = 0x0FFFFFFFU
    };
  */


-(void)CFRunLoopDemo
{
    // 创建observer
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
    NSLog(@"----监听到RunLoop状态发生改变---%zd", activity);
    });

    // 添加观察者：监听RunLoop的状态
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    //CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
}





#pragma mark - 五. 如何让NSURLConnection在子线程中运行

/*
可以有两个办法让NSURLConnection在子线程中运行，即将NSURLConnection加入到run loop或者NSOperationQueue中去运行。

前面提到可以将NSTimer手动加入NSRunLoop，Cocoa库也为其它一些类提供了可以手动加入NSRunLoop的方法，这些类有NSPort、NSStream、NSURLConnection、NSNetServices，方法都是[scheduleInRunLoop:forMode:]形式。我暂时只介绍下最常用的NSURLConnection类，看看如何把NSURLConnection的网络下载加入到其它线程的run loop去运行。

如果NSURLConnection是在主线程中启动的，实际上它就在主线程中运行 -- 并非启动的另外的线程，但又具备异步运行的特性，这个确实是run loop的巧妙所在。如果对run loop有了初步的了解和概念后，实际上就能明白NSURLConnection的运行，实际也是需要当前线程具备run loop。

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode; //将加入指定的run loop中运行，必须保证这时NSURLConnection不能启动，否则不起作用了

- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode; //将取消在指定run loop中的运行，实际上就会停止NSURLConnection的运行

下面是如何在其它线程中运行NSURLConnection的主要实现代码：

NSRunLoop *runloop; //global

[self performSelectorInBackground:@selector(thread) withObject:nil]; //启动包含run loop的线程

NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO]; //注意这时不能先启动NSURLConnection

[conn scheduleInRunLoop:runloop forMode:NSRunLoopCommonModes]; //指定在上面启动的线程中运行NSURLConnection

[conn start]; //启动NSURLConnection

- (void)thread

{

　　runloop = [NSRunLoop currentRunLoop]; //设置为当前线程的run loop值

　　while (condition)

　　{

　　　　[runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]]; //启动run loop

　　}

}



将NSURLConnection加入到NSOperationQueue中去运行的方式基本类似：

NSOperationQueue *queue = [[NSOperationQueuealloc] init];

NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];

[conn setDelegateQueue:queue];

[conn start];


*/

#pragma mark - 六. NSOperation
/*
 iOS平台提供更高级的并发（异步）调用接口，让你可以集中精力去设计需完成的任务代码，避免去写与程序逻辑无关的线程生成、运行等管理代码。当然实质上是这些接口隐含生成线程和管理线程的运行，从而更加简洁地实现多线程。下面先来研究NSOperation和NSOperationQueue类的使用。
 
 NSOperation实质是封装了需要并发运行的代码，一些主要接口和NSThread基本相同，可以看做没有线程运行能力的thread类的抽象。参考NSThread，NSOperation的一些相同的接口有：
 
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
 
 
 
 除了继承NSOperation来实现并发代码，通常更简便的办法是使用它的两个子类NSInvocationOperation或NSBlockOperation，然后加入到NSOperationQueue执行队列中去运行。部分示例代码如下：
 
 NSInvocationOperation *opA = [[NSInvocationOperationalloc] initWithTarget:self selector:@selector(operate) object:nil];
 
 NSBlockOperation *opB = [NSBlockOperation blockOperationWithBlock:^{
 
 [self operate];
 
 }];
 
 - (void)operate
 {
 　　//thread loop
 　　while (condition)
 　　{
 　　　　//....
 　　}
 }
 
 NSOperationQueue *queue = [[NSOperationQueuealloc] init];
 
 queue.maxConcurrentOperationCount = 2; //设置最大并发执行数，如果为1则同时只有一个并发任务在运行，可控制顺序执行关系
 
 [queue addOperation:opA]; //加入到执行队列中，如果isReady则开始执行
 
 [queue addOperation:opB]; //同上，需要注意这时opA和opB是在并发运行
 
 [queue waitUntilAllOperationsAreFinished]; //当前线程等待，直到opA和opB都执行结束
 
 如果要求opB在opA执行完成后才开始执行，需要加上依赖关系即可：
 
 [opB addDependency:opA];
 
 当然也可以使用同步方法waitUntilFinished，在前面的例子中加入：
 
 NSBlockOperation *opB = [NSBlockOperation blockOperationWithBlock:^{
 
 　　　[opA waitUntilFinished]; //opB线程等待直到opA执行结束（正常结束或被取消）
 
 [self operate];
 
 }];
 
 建立依赖关系或等待关系，一定要出现避免循环依赖或循环等待，否则就会造成线程死锁。
 
 最后看看NSOperationQueue的其它常用方法：
 
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

#pragma mark - 七.Dispatch对象

/*
谈起iOS的dispatch（正式称谓是Grand Central Dispatch或GCD），不得不说这又是iOS（包括MacOSX）平台的创新，优缺点这里不讨论，只有当你使用时才能真正体会到。我们说dispatch函数的主要目的是实现多任务并发代码，那么要理解dispatch函数，先来了解dispatch对象的定义。



dispatch对象类型的部分定义，主要使用C语言的宏定义：

<os/object.h>文件：

#define OS_OBJECT_CLASS(name) OS_##name

#define OS_OBJECT_DECL(name, ...) \

@protocol OS_OBJECT_CLASS(name) __VA_ARGS__ \

@end \

typedef NSObject<OS_OBJECT_CLASS(name)> *name##_t

#define OS_OBJECT_DECL_SUBCLASS(name, super) \

OS_OBJECT_DECL(name, <OS_OBJECT_CLASS(super)>)



<dispatch/object.h>文件：

#define DISPATCH_DECL(name) OS_OBJECT_DECL_SUBCLASS(name, dispatch_object)

#define DISPATCH_GLOBAL_OBJECT(type, object) ((OS_OBJECT_BRIDGE type)&(object))

OS_OBJECT_DECL(dispatch_object); //定义dispatch_object_t



<dispatch/queue.h>文件（dispatch队列类定义，其它dispatch对象类似）：

DISPATCH_DECL(dispatch_queue); //定义dispatch_queue_t



可以通过Xcode预编译后可以看到最终结果，最终定义的都是NSObject类，虽然它们之间没用直接继承关系，但都实现OS_dispatch_object接口，这样dispatch_queue_t对象也同样是dispatch_object_t的对象了。下面就是预编译dispatch_object_t和dispatch_queue_t的结果：

@protocol OS_dispatch_object

@end

typedef NSObject<OS_dispatch_object> *dispatch_object_t;

@protocol OS_dispatch_queue <OS_dispatch_object>

@end

typedef NSObject<OS_dispatch_queue> *dispatch_queue_t;



由于dispatch api接口定义成C函数的形式，dispatch的对象都是由C函数形式的厂方法得到（不能继承dispatch类，不用alloc），这样做隐藏dispatch对象的具体形态，把注意力放在如何调用dispatch api上。

从上面dispatch对象宏定义可以看到dispatch对象类的名称一般为dispatch_xyz_t（严格来讲是对象指针），它们都可以看成dispatch_object_t的子类（对象指针），所以使用dispatch对象时套用这个概念就行。



有关dispatch对象的基本接口如下：

void dispatch_retain(dispatch_object_t object); //替代dispatch对象常规的retain来持有对象，但ARC编程中不再允许

void dispatch_release(dispatch_object_t object); //替代dispatch对象常规的release来释放对象，同样ARC编程中不再允许

void dispatch_set_context(dispatch_object_t object, void *context); //给dispatch对象绑定特定数据对象（类似线程的TLS数据），会被传给dispatch对象的finalizer函数

void *dispatch_get_context(dispatch_object_t object); //返回dispatch对象绑定的数据对象指针

void dispatch_set_finalizer_f(dispatch_object_t object, dispatch_function_t finalizer); //设置dispatch对象的finalizer函数，当该对象释放时会调用finalizer，部分代码解释如何使用这个函数（ARC模式）：

dispatch_object_t dispatchObject = ...;

void *context = ...;

dispatch_set_context(dispatchObject, context);

dispatch_set_finalizer_f(dispatchObject, finalizer);

......

dispatchObject = nil; //dispatchObject被释放，这时调用finalizer函数

......

void finalizer(void *context)

{

　　//处理或释放context相关资源

}



dispatch对象的另外两个接口是：

void dispatch_resume(dispatch_object_t object); //激活（启动）在dispatch对象上的block调用，可以运行多个block

void dispatch_suspend(dispatch_object_t object); //挂起（暂停）在dispatch对象上的block调用，已经运行的block不会停止

一般这两个函数的调用必须成对，否则运行会出现异常。

至此你是否发现这两个函数有些与众不同呢？好像从来没有这么使用对象的，启动对象--暂停对象，呵呵。这正是理解dispatch对象的关键所在。dispatch对象其实是抽象的任务，把动态的任务变成对象来管理。任务是动态的，不存在继承关系，这就是为什么GCD没有提供静态继承dispatch对象类的方式。如果能这样理解，那么在使用dispatch函数时就能够更灵活地去编写代码，实现各种并发的多任务代码。

 */




#pragma mark - 八.Dispatch 队列   GCD
/*
 GCD编程的核心就是dispatch队列，dispatch block的执行最终都会放进某个队列中去进行，它类似NSOperationQueue但更复杂也更强大，并且可以嵌套使用。所以说，结合block实现的GCD，把函数闭包（Closure）的特性发挥得淋漓尽致。
 */


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






/**
 将NSDate 转化为 dispatch_time_t

 @param date  date
 @return dispatch_time_t
 */
dispatch_time_t getDispatchTimeByDate(NSDate *date)
{
    NSTimeInterval interval;
    double second,subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval =[date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);  //计算绝对时间
    return milestone;
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
    
    
    dispatch_apply(10, queue, ^(size_t count) {
        // 异步返回
        dispatch_async(queue, ^{
            NSLog(@"count = %ld.",count);
            usleep(500000);
        });
    });
    
    NSLog(@"async well done.");
    
    /*
    2018-11-07 13:16:49.150819+0800 ReviewLessionOfOC[20517:2675356] count = 0.
    2018-11-07 13:16:49.150897+0800 ReviewLessionOfOC[20517:2675342] count = 1.
    2018-11-07 13:16:49.150904+0800 ReviewLessionOfOC[20517:2675343] count = 2.
    2018-11-07 13:16:49.150934+0800 ReviewLessionOfOC[20517:2675311] async well done.
    2018-11-07 13:16:49.150944+0800 ReviewLessionOfOC[20517:2675348] count = 3.
    2018-11-07 13:16:49.150979+0800 ReviewLessionOfOC[20517:2675349] count = 4.
    2018-11-07 13:16:49.151023+0800 ReviewLessionOfOC[20517:2675354] count = 5.
    2018-11-07 13:16:49.151066+0800 ReviewLessionOfOC[20517:2675341] count = 6.
    2018-11-07 13:16:49.151097+0800 ReviewLessionOfOC[20517:2675437] count = 7.
    2018-11-07 13:16:49.151128+0800 ReviewLessionOfOC[20517:2675438] count = 8.
    2018-11-07 13:16:49.151161+0800 ReviewLessionOfOC[20517:2675439] count = 9.
    */
    
    
    //void dispatch_after(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block); //延迟执行block
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);  //延时3S
    
    dispatch_after(time, queue, ^{
        dispatch_async(queue,^(void){
            dispatch_apply(10, queue, ^(size_t index) {
                NSLog(@"index = %ld",index);
            });
        });
        
        NSLog(@"00000000");
    });
    
    NSLog(@"010100101");
    
    /*
    2018-11-07 14:14:16.603875+0800 ReviewLessionOfOC[32567:2741780] async well done.
    2018-11-07 14:14:16.603890+0800 ReviewLessionOfOC[32567:2741780] 00000
    2018-11-07 14:14:16.603907+0800 ReviewLessionOfOC[32567:2741840] count = 5.
    2018-11-07 14:14:16.603936+0800 ReviewLessionOfOC[32567:2741944] count = 6.
    2018-11-07 14:14:16.603974+0800 ReviewLessionOfOC[32567:2741945] count = 7.
    2018-11-07 14:14:16.604007+0800 ReviewLessionOfOC[32567:2741946] count = 8.
    2018-11-07 14:14:16.604032+0800 ReviewLessionOfOC[32567:2741947] count = 9.
    2018-11-07 14:14:16.604052+0800 ReviewLessionOfOC[32567:2741948] index = 0
    2018-11-07 14:14:16.604154+0800 ReviewLessionOfOC[32567:2741948] index = 1
    2018-11-07 14:14:16.604168+0800 ReviewLessionOfOC[32567:2741948] index = 2
    2018-11-07 14:14:16.604177+0800 ReviewLessionOfOC[32567:2741948] index = 3
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
      它会把需要执行的任务对象指定到不同的队列中去处理，这个任务对象可以是dispatch队列，也可以是dispatch源（以后博文会介绍）。
      而且这个过程可以是动态的，可以实现队列的动态调度管理等等.
     
      比如说有两个队列dispatchA和dispatchB，这时把dispatchA指派到dispatchB：
      dispatch_set_target_queue(dispatchA, dispatchB);
      那么dispatchA上还未运行的block会在dispatchB上运行。这时如果暂停dispatchA运行：
      dispatch_suspend(dispatchA);
      则只会暂停dispatchA上原来的block的执行，dispatchB的block则不受影响。而如果暂停dispatchB的运行，则会暂停dispatchA的运行。
      dispatch队列不支持cancel（取消），没有实现dispatch_cancel()函数，不像NSOperationQueue，不得不说这是个小小的缺憾。
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



#pragma mark - 九. Dispatch Source

/*
 dispatch源（dispatch source）和RunLoop源概念上有些类似的地方，而且使用起来更简单。要很好地理解dispatch源，其实把它看成一种特别的生产消费模式。dispatch源好比生产的数据，当有新数据时，会自动在dispatch指定的队列（即消费队列）上运行相应地block，生产和消费同步是dispatch源会自动管理的。
 
 dispatch源的使用基本为以下步骤：
 
 1. dispatch_source_t source = dispatch_source_create(dispatch_source_type, handler, mask, dispatch_queue); //创建dispatch源，这里使用加法来合并dispatch源数据，最后一个参数是指定dispatch队列
 
 2. dispatch_source_set_event_handler(source, ^{ //设置响应dispatch源事件的block，在dispatch源指定的队列上运行
 
 　　//可以通过dispatch_source_get_data(source)来得到dispatch源数据
 
 });
 
 3. dispatch_resume(source); //dispatch源创建后处于suspend状态，所以需要启动dispatch源
 
 4. dispatch_source_merge_data(source, value); //合并dispatch源数据，在dispatch源的block中，dispatch_source_get_data(source)就会得到value。
 
 是不是很简单？而且完全不必编写同步的代码。比如网络请求数据的模式，就可以这样来写：
 
 dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_global_queue(0, 0));
 
 dispatch_source_set_event_handler(source, ^{
 
 dispatch_sync(dispatch_get_main_queue(), ^{
 
 　　　　//更新UI
 
 });
 
 });
 
 dispatch_resume(source);
 
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
 
 　　　//网络请求
 
 dispatch_source_merge_data(source, 1); //通知队列
 
 });
 
 dispatch源还支持其它一些系统源，包括定时器、监控文件的读写、监控文件系统、监控信号或进程等，基本上调用的方式原理和上面相同，只是有可能是系统自动触发事件。比如dispatch定时器：
 
 dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
 
 dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 10*NSEC_PER_SEC, 1*NSEC_PER_SEC); //每10秒触发timer，误差1秒
 
 dispatch_source_set_event_handler(timer, ^{
 
 　　//定时处理
 
 });
 
 dispatch_resume(timer);
 
 其它情况的dispatch源就不再一一举例，可参看官网有具体文档: https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/GCDWorkQueues/GCDWorkQueues.html#//apple_ref/doc/uid/TP40008091-CH103-SW1
 
 
 
 最后，dispatch源的其它一些函数大致罗列如下：
 
 uintptr_t dispatch_source_get_handle(dispatch_source_t source); //得到dispatch源创建，即调用dispatch_source_create的第二个参数
 
 unsignedlong dispatch_source_get_mask(dispatch_source_t source); //得到dispatch源创建，即调用dispatch_source_create的第三个参数
 
 void dispatch_source_cancel(dispatch_source_t source); //取消dispatch源的事件处理--即不再调用block。如果调用dispatch_suspend只是暂停dispatch源。
 
 long dispatch_source_testcancel(dispatch_source_t source); //检测是否dispatch源被取消，如果返回非0值则表明dispatch源已经被取消
 
 void dispatch_source_set_cancel_handler(dispatch_source_t source, dispatch_block_t cancel_handler); //dispatch源取消时调用的block，一般用于关闭文件或socket等，释放相关资源
 
 void dispatch_source_set_registration_handler(dispatch_source_t source, dispatch_block_t registration_handler); //可用于设置dispatch源启动时调用block，调用完成后即释放这个block。也可在dispatch源运行当中随时调用这个函数。
 */


#pragma mark - 十. Dispatch 同步
/*
 GCD提供两种方式支持dispatch队列同步，即dispatch组和信号量。
 
 一、dispatch组（dispatch group）
 
 1. 创建dispatch组
 dispatch_group_t group = dispatch_group_create();
 
 2. 启动dispatch队列中的block关联到group中
 dispatch_group_async(group, queue, ^{
 　　// 。。。
 });
 
 3. 等待group关联的block执行完毕，也可以设置超时参数
 
 dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
 
 4. 为group设置通知一个block，当group关联的block执行完毕后，就调用这个block。类似dispatch_barrier_async。
 
 dispatch_group_notify(group, queue, ^{
 
 　　// 。。。
 
 });
 
 5. 手动管理group关联的block的运行状态（或计数），进入和退出group次数必须匹配
 
 dispatch_group_enter(group);
 
 dispatch_group_leave(group);
 
 所以下面的两种调用其实是等价的，
 
 A)
 
 dispatch_group_async(group, queue, ^{
 
 　　// 。。。
 
 });
 
 B)
 
 dispatch_group_enter(group);
 
 dispatch_async(queue, ^{
 
 　　//。。。
 
 　　dispatch_group_leave(group);
 
 });
 
 所以，可以利用dispatch_group_enter、 dispatch_group_leave和dispatch_group_wait来实现同步，具体例子：http://stackoverflow.com/questions/10643797/wait-until-multiple-operations-executed-including-completion-block-afnetworki/10644282#10644282。
 
 
 
 二、dispatch信号量（dispatch semaphore）
 
 1. 创建信号量，可以设置信号量的资源数。0表示没有资源，调用dispatch_semaphore_wait会立即等待。
 
 dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
 
 2. 等待信号，可以设置超时参数。该函数返回0表示得到通知，非0表示超时。
 
 dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
 
 3. 通知信号，如果等待线程被唤醒则返回非0，否则返回0。
 
 dispatch_semaphore_signal(semaphore);
 
 最后，还是回到生成消费者的例子，使用dispatch信号量是如何实现同步：
 
 
 
 dispatch_semaphore_t sem = dispatch_semaphore_create(0);
 
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ //消费者队列
 
 while (condition) {
 
 　　　　if (dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC))) //等待10秒
 
 　　　　　　continue;
 
 　　　　//得到数据
 
 　　}
 
 });
 
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ //生产者队列
 
 while (condition) {
 
 　　　　if (!dispatch_semaphore_signal(sem))
 　　　　{
 　　　　　　sleep(1); //wait for a while
 　　　　　　continue;
 　　　　}
 
 　　　　//通知成功
 
 　　}
 
 });
 */




/*
 自我介绍
 首先很荣欣
 good afternoon,ladies and gentlement! It's really my honor to have this opportunity for an interview.
 I hope i can make a good performace today.
 Now i will intriduce myself briefly.
 I am 33 years old, born in Anhui province. I graduated from
 
 我毕业于2007年，芜湖教育学院，2013年又自考了北京语言大学（Beijing language and culture university）,取得本科学历及学士学位.
 从2007年到现在已经工作了11年. 先后在4家公司做过.
 第一家公司是芜湖安联，职务是程序员，主要负责软件的调试工作. 这家公司我做了一年.
   一年后 加入到第二家公司 台达电子 Delta. 在台达我做了7年 从2008年到2014年底.主要从事MES / OA的开发工作。  岗位是软件工程师，后来升为开发课长.
 用的开发语言是 C#,Asp.Net + SQL2018
   2015年我加入第三家公司 迈致科技MYZY.主要做Mac的程序开发.公司主要做Apple的iPhone & watch的ICT FCT fixture. So测试软件主要是跟电子相关.
 用到的语言主要是Objective-C and C 通讯协议主要是 SerialPort +Socket +I2C + SPI 等等.
   9月份离职加入 上海德岂智能（B&P） 但目前没有项目在做.
   因为以前的工作中基本上都不用英文，所以我的英文不是很好；我希望能加入外企，在工作中能更快更好的提升我的英文水平.HCL在行业中是个非常不错的攻击公司，我可以在这样的工作环境中收获更多。
 这是我来这里面试的原因。我觉得我是一位具有良好的团队精神.诚恳的人.
  That is the reason why I come here to compete for this position. I am able to work under great pressure. I am confident that I am qualified for the post of devolopment leader in your company. that's all.thank you for listen.
 
 */


@end
