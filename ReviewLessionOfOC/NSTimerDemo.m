//
//  NSTimerDemo.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/9.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "NSTimerDemo.h"

@implementation NSTimerDemo

/*
 一. 认识NSRunloop
 
 1.1　NSRunloop与程序运行
 
 　　　那么具体什么是NSRunLoop呢?其实NSRunLoop的本质是一个消息机制的处理模式。让我们首先来看一下程序的入口——main.m文件，一个ios程序启动后，只有短短的十行代码居然能保持整个应用程序一直运行而没有退出，是不是有点意思？程序之所以没有直接退出是因为UIApplicationMain这个函数内部默认启动了一个跟主线程相关的NSRunloop对象，而UIApplicationMain这个函数一直执行没有返回就保存程序一直运行的状态。
 
 复制代码
 1 #import <UIKit/UIKit.h>
 2
 3 #import "AppDelegate.h"
 4
 5 int main(int argc, char * argv[]) {
 6
 7     @autoreleasepool {
 8
 9         return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
 10
 11     }
 12
 13 }
 复制代码
 
 
 　　文章之初我们暂且将NSRunloop理解为实现这样功能的一段代码 , 这可以帮助我们更好的理解NSRunloop处理事件的过程(实际上远比这复杂的多：）)。
 
 复制代码
 1 int main(int argc, char * argv[]) {
 2
 3   BOOL runnning =YES;
 4    do{
 5         ...
 6        //处理各种操作 各种事件
 7        ...
 8       }while(running);
 9
 10     return 0;
 11 }
 复制代码
 
 
 
 
 　　　下面用官方提供的一幅非常经典的图片，来认识NSRunloop循环处理时间的流程。
 
 　　　　　　
 
 　　　通过所有的“消息”都被添加到了NSRunLoop中去，而在这里这些消息并分为“input source”和“Timer source” 并在循环中检查是不是有事件需要发生，如果需要那么就调用相应的函数处理。由此形成了运行->检测->休眠 ->运行 的循环状态。
 
 　　　　
 
 
 
 1.1　NSRunloop与线程之间关系的解析
 
 
 
 　　 简单说，一条线程对应一个NSRunloop对象。主线程NSRunloop对象是默认开启的，其他线程的NSRunloop对象需要手动获取。其实NSRunloop对象是懒加载的，所以不需要实例化这个类，而是直接调用获取线程Runloop的方法即可唤醒。Runloop在第一次获取时创建，在线程结束时销毁。保持NSRunloop一直存在的方法稍后介绍。
 
 
 
 　　1.1.1 　获得NSRunloop对象的方法
 
 　　iOS其实有两套Api来访问和使用Runloop , NSRunloop是对CFRunloopRef的进一步封装，并且CFRunloopRef是线程安全的，而这一点NSRunloop并不能保证。
 
 　　Foundation ->NSRunloop
 
 　　 获得当前线程的Runloop的方法  [NSRunloop currentRunloop];
 
 　　获得主线程的Runloop的方法 [NSRunloop  mainRunloop];
 
 
 
 　　Core Foundation ->CFRunloopRef
 
 　　CFRunloopGetCurrent();
 
 　　CFRunloopGetMain();
 
 
 
 　　由苹果官方文档可以看出线程和Runloop对象的对应关系。如果你仔细阅读可以从代码中可以看出runloop的存储方式是字典，而且key是线程。
 
 复制代码
 1 // should only be called by Foundation
 2 // t==0 is a synonym for "main thread" that always works
 3
 4 //函数返回值为CFRunLoopRef  形参类型为pthread_t 根据线程创建runloop对象
 5
 6 CF_EXPORT CFRunLoopRef _CFRunLoopGet0(pthread_t t) {
 7
 8     if (pthread_equal(t, kNilPthreadT)) {
 9
 10 t = pthread_main_thread_np();
 11
 12     }
 13
 14     __CFLock(&loopsLock);
 15
 16     if (!__CFRunLoops) {
 17
 18         __CFUnlock(&loopsLock);
 19
 20 CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, &kCFTypeDictionaryValueCallBacks);
 21
 22 //由此句可得出  调用其他线程NSRunloop对象也会首先创建主线程NSRunloop对象
 23 CFRunLoopRef mainLoop = __CFRunLoopCreate(pthread_main_thread_np());
 24
 25 CFDictionarySetValue(dict, pthreadPointer(pthread_main_thread_np()), mainLoop);
 26
 27 if (!OSAtomicCompareAndSwapPtrBarrier(NULL, dict, (void * volatile *)&__CFRunLoops)) {
 28
 29     CFRelease(dict);
 30
 31 }
 32
 33 CFRelease(mainLoop);
 34
 35         __CFLock(&loopsLock);
 36
 37     }
 38
 39     CFRunLoopRef loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));
 40
 41     __CFUnlock(&loopsLock);
 42
 43     if (!loop) {
 44
 45 CFRunLoopRef newLoop = __CFRunLoopCreate(t);
 46
 47         __CFLock(&loopsLock);
 48
 49 loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));
 50
 51 if (!loop) {
 52
 53     CFDictionarySetValue(__CFRunLoops, pthreadPointer(t), newLoop);
 54
 55     loop = newLoop;
 56
 57 }
 58
 59         // don't release run loops inside the loopsLock, because CFRunLoopDeallocate may end up taking it
 60
 61         __CFUnlock(&loopsLock);
 62
 63 CFRelease(newLoop);
 64
 65     }
 66
 67     if (pthread_equal(t, pthread_self())) {
 68
 69         _CFSetTSD(__CFTSDKeyRunLoop, (void *)loop, NULL);
 70
 71         if (0 == _CFGetTSD(__CFTSDKeyRunLoopCntr)) {
 72
 73             _CFSetTSD(__CFTSDKeyRunLoopCntr, (void *)(PTHREAD_DESTRUCTOR_ITERATIONS-1), (void (*)(void *))__CFFinalizeRunLoop);
 74
 75         }
 76     }
 77     return loop;
 78 }
 复制代码
 
 
 　　1.1.2 　Mode
 
 　　
 
 　　Mode中有三个非常重要的组成部分，Timer（定时器）、 Source（事件源） 以及Observor（观察者）。一个 RunLoop 包含若干个 Mode，每个 Mode 又包含若干个 Source/Timer/Observer。首先要指出的是一个runloop启动时必须指定一个Mode  , 并且这个Mode被称为currentMode 。如果要切换Mode,只能退出runloop重新进入。这样做主要是为了分隔开不同组的 Source/Timer/Observer，让其互不影响。随后我们会分别介绍每一类的具体作用与应用场景。
 
 　　
 
 
 
 　　系统默认注册的Mode有五种
 
 　　　　kCFRunloopDefaultMode    // App默认Mode   通常主线程是在这个mode下运行
 
 　　　　UITrackingRunloopMode    // 界面跟踪Mode  用于scrollView追踪触摸  界面滑动时不受其他Mode影响
 
 　　　　UIinitializationRunloopMode    //在app一启动进入的第一个Mode,启动完成后就不再使用
 
 　　　　GSEventRecieveRunloopMode   //苹果使用绘图相关
 
 　　　　NSRunLoopCommonModes 　　//占位模式
 
 　　
 
 　
 
 　　1.1.2.1 CFRunloopTimerRef 基于时间的触发器
 
 　　NSTimer
 
 　　首先说一下NSTimer，一个NSRunloop可以创建多个Timer。因为定时器只会运行在指定的Mode下 ，一旦Runloop进入其他模式， 定时器就不会工作了。
 
 　　NSTimer的创建方法
 
 [NSTimer scheduledTimerWithTimeInterval:<#(NSTimeInterval)#> target:<#(nonnull id)#> selector:<#(nonnull SEL)#> userInfo:<#(nullable id)#> repeats:<#(BOOL)#>]
 　　该方法默认添加到当前runloop，并且Mode为kCFRunloopDefaultMode。
 
 
 
 1  NSTimer * timer =[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(test) userInfo:nil repeats:YES];
 2     [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes]; //手动添加到runloop  可以指定Mode
 　　这样声明的NSTimer可以解决在滑动scrollView时NSTimer不工作的问题。forMode:NSRunLoopCommonModes的意思为，定时器可以运行在标记为common modes模式下。具体包括两种: kCFRunloopDefaultMode  和   UITrackingRunloopMode。
 
 
 
 　　GCD定时器
 
 　　GCD定时器的优点有很多，首先不受Mode的影响，而NSTimer受Mode影响时常不能正常工作，除此之外GCD的精确度明显高于NSTimer，这些优点让我们有必要了解GCD定时器这种方法。

 　　　1.1.2.2  CFRunloopSourceRef  事件源(输入源)
 
 　　按照苹果官方文档,Source分类
 
 　　Port-Based  Sources  基于端口的  和其他线程 或者内核
 
 　　Custom Input  Sources
 
 　　Cocoa   Perform   Selector  Sources
 
 
 
 　　按照函数调用栈来分类
 
 　　Source0 :   非基于Port的
 　　Source1:   基于port的，通过内核 和其他线程通信，接收、分发事件。
 
 
 
 
 
 
 
 　　　1.1.2.3  CFRunloopObservorRef  观察者监听runloop状态改变
 
 
 
 复制代码
1  //Run Loop Observer Activities
2
3 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    4
    5     kCFRunLoopEntry = (1UL << 0),
    6
    7     kCFRunLoopBeforeTimers = (1UL << 1),
    8
    9     kCFRunLoopBeforeSources = (1UL << 2),
    10
    11     kCFRunLoopBeforeWaiting = (1UL << 5),
    12
    13     kCFRunLoopAfterWaiting = (1UL << 6),
    14
    15     kCFRunLoopExit = (1UL << 7),
    16
    17     kCFRunLoopAllActivities = 0x0FFFFFFFU
    18
    19 };

复制代码
　　// 创建observer

CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
    
    NSLog(@"----监听到RunLoop状态发生改变---%zd", activity);
    
});



// 添加观察者：监听RunLoop的状态

CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);



二 、实际应用

只在NSRUnloopDefaultModes 下显示图片
　　上面再举例NSTimer中已经阐述其中原理了，在此不再重复举例了。

　　2.  常驻线程

　　NSThread * thread  = [NSThread   alloc ]initWithTarget  selector

　　[thread start];

　　通常执行完方法后线程就销毁了，那么现在有这样的需求，需要一条子线程一直存在，等待处理任务，与主线程之间互不干扰  (可以类比主线程存在原理，即添加消息循环Runloop)

1 //   通过添加port 或者timer
2
3  [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
4
5 [[NSRunLoop currentRunLoop] run];


Ps:Runloop运行首先判断Mode是否为空，如果为空则退出循环，还可以通过removePort来移除端口。本例用添加port来实现，其他方法请读者自己多尝试。：）

　　3. 关于自动释放池

　　关于自动释放池，子线程开启runloop时要开启针对当前线程的autoreleasepool，在每次NSRunloop休眠前清理自动释放池。

　　关于自动释放池的具体用法本文暂时不进行描述，待日后在整理修改本帖。





　　参考资料：https://home.cnblogs.com/blog/
 */


@end
