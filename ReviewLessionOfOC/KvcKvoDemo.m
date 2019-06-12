//
//  KvcKvoDemo.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/15.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "KvcKvoDemo.h"
#import <objc/runtime.h>

@implementation KvcKvoDemo

//对象之间的通信方式（delegate、block、NSNotification、kvc、kvo）总结


//1. delegate：代理是一种设计模式，它是通过被代理者定义代理协议委托代理者实现协议，用于两个对象间的通信交互。在 IOS 中 delegate 主要用于视图与使用对象之间的通信交互，delegate 的效率是最高的，典型的特就是它有返回值。

/*
2. Block是一个C级别的语法以及运行时的一个特性，和标准C中的函数（函数指针）类似，block：block 类似与函数，可作为参数进行传递用于回调，block 可以定义在方法里，函数不能。block 语法简单，写在方法里可以访问局部变量可以使代码更加的紧凑，结构化。相对于 delegate，block 不用建立代理协议，它的实现具有封闭性(closure)，而又能够很容易获取上下文的相关状态信息，使用简单。

用途：常用于逆向传值、作为方法参数、作为类的属性、作为全局变量

注意：
1）在使用block前需要对block指针做判空处理。不判空直接使用，一旦指针为空直接产生崩溃。
2）在block使用之后要对，block指针做赋空值处理，如果是MRC的编译环境下，要先release掉block对象。block作为类对象的成员变量，使用block的人有可能用类对象参与block中的运算而产生循环引用。将block赋值为空，是解掉循环引用的重要方法。（不能只在dealloc里面做赋空值操作，这样已经产生的循环引用不会被破坏掉）
3）使用方将self或成员变量加入block之前要先将self变为__weak
4）在多线程环境下（block中的weakSelf有可能被析构的情况下），需要先将self转为strong指针，避免在运行到某个关键步骤时self对象被析构。
5）在MRC的编译环境下，block如果作为成员参数要copy一下将栈上的block拷贝到堆上

意义：Block是iOS4.0+ 和Mac OS X 10.6+ 引进的对C语言的扩展，用来实现匿名函数的特性。它允许开发者在两个对象之间将任意的语句当做数据进行传递，往往这要比引用定义在别处的函数直观；
 
 3. 通知：NSnotification 一个中心对象注册和发送通知，所用的其他的对象都可以收到通知。
 
 用途：常常用于在向服务器端请求数据或者提交数据的场景，在和服务器端成功交互后，需要处理服务器端返回的数据，或发送响应消息等
 注意：它是同步的消息通知机制，只有Observer将消息处理完毕后，消息发送者才会继续执行，因此在通知处理的地方做大量耗时操作的话，就会带来卡顿的问题啦。
 
 在多线程的应用中，Notification在哪个线程中Post, 就是在那个线程分发，也就在同一个线程中被observer处理。而通常呢，我们会在Observer对象的dealloc方法中去removeObserver,理论上，如果observer的dealloc和消息发送者的postNotification的方法在不同的线程中调用的话，是有可能会导致Crash的。
 
 意义：广播数据，一对多
 4.KVC：键-值编码是用于间接访问对象属性的机制，并不需要调用 set 或者 get 方法访问变量，是通过 set value for key 进行间接访问实例变量。

 5.KVO。当对象的某一个属性发生变化的时候，我们得到一个相应的通知。
*/


#pragma mark - KVC

//1.KVC
-(void)kvcDemo
{
    Person  *person = [[Person alloc] init];
    [person setValue:@"Jose" forKey:@"_name"];
    NSString *pname = [person valueForKey:@"_name"];
    
    [person setValue:@"M" forKey:@"_sex"];
    NSString *psex = [person valueForKey:@"_sex"];
    Money *money1  = [Money new];
    money1.bank    = @"chinese";
    [person setValue:money1 forKey:@"_money"];
    
    Money *money111 = [person valueForKey:@"_money"];
    NSString *bank  = [money111 valueForKey:@"_bank"];
    
    // 有类属性的 需要使用KeyPath 结合点语法使用
    [person setValue:@"Chinese" forKeyPath:@"_money._bank"];
    NSString *pbank = [person valueForKeyPath:@"_money._bank"];
    
    // [person setValue:@"25" forUndefinedKey:@"Age"];//它的默认实现是抛出异常，可以重写这函数做错误处理
    NSLog(@"pname = %@;psex = %@. money.bank = %@.",pname,psex,pbank);
}

#pragma mark - KVO
// 2.kvo Key-Value Observing
/*
 1 . 注册，指定被观察者的属性(实现观察)
 2 . 实现回调方法(在被观察的 key path 的值变化时调用)
 3 . 移除观察(dealloc)
 */
-(void)kvoDemo
{
    p1 = [[Person alloc] init];
    [p1 addObserver:p1 forKeyPath:@"_age" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    [p1 addObserver:self forKeyPath:@"_money._bank" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    [p1 addObserver:self forKeyPath:@"_name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

-(void)changeP1Name:(NSString *)name Bank:(NSString *)bank
{
    assert(p1);
    // 直接赋值是不会观察到的
    p1.name = name;
    p1.money.bank = bank;

    // 必须使用KVC才能观察到变化
    [p1 setValue:name forKey:@"_name"];
    [p1 setValue:bank forKeyPath:@"_money._bank"];
    [p1 setValue:@"14" forKey:@"_age"];
}

// 实现KVO回调方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"_money._bank"])
    {
        NSLog(@"p1.money.bank = %@.",[object valueForKeyPath:keyPath]);
    }
    if([keyPath isEqualToString:@"_name"])
    {
        NSLog(@"p1.name = %@.",[object valueForKeyPath:keyPath]);
    }
}


#pragma mark - NSNotification
//NSNotification的对象很简单，就是poster要提供给observer的信息包裹。

//1.在主函数中创建监听通知的过程
-(void)createNotification
{
    //1.通过单例得到通知中心，相当于通知在什么地方发布（黑板）
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    /*
     2.注册通知监听器，只有这一个方法
     observer为监听器
     aSelector为接到收通知后的处理函数
     aName为监听的通知的名称
     object为接收通知的对象，需要与postNotification的object匹配，否则接收不到通知,一般用nil
     */
    [center addObserver:self selector:@selector(testNotificationEvent1:) name:@"Noti_Name1" object:nil];
    
    //通知的对象，常使用nil，如果设置了值注册的通知监听器的object需要与通知的object匹配，否则接收不到通知
    [center addObserver:self selector:@selector(testNotificationEvent2:) name:@"noti_name2" object:p1];
    [center addObserver:self selector:@selector(testNotificationEvent3:) name:@"noti_name2" object:nil];
    [center addObserver:p1 selector:@selector(doEvent:) name:@"noti_name2" object:p1];
    
    
    //1） 这个方法会返回一个 NSObserver 对象，这个对象被系统强持有，调用者需要持有这个对象，用于停止通知移除观察者时使用。这种方式添加的通知，如果不持有这个对象，是无法彻底销毁这个通知的，具体做法如下：
    _observer = [center addObserverForName:@"Noti_Name1" object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"#### block notification event done.");
    }];
    
    
    NSLog(@"post n1 ****** 1 *******");
    //3.创建通知,Post Notification
    NSNotification * notification1 = [NSNotification notificationWithName:@"Noti_Name1" object:self userInfo:nil];
    [center postNotification:notification1];//通过上边建立的通知中心center发布通知notification1.
    
    sleep(1);
    NSLog(@"post n1 ****** 2 *******");
    /*
     发送通知
     aName为注册的通知名称
     anObject为接受通知的对象，通知不传参时可使用该方法
     */
    [center postNotificationName:@"noti_name2" object:nil];  // 只执行 testNotificationEvent3
    
    sleep(1);
    NSLog(@"post n2 ****** 3 *******");
    
    /*
     发送通知
     aName为注册的通知名称
     anObject为接受通知的对象
     aUserInfo为字典类型的数据，可以传递相关数据
     */
    [center postNotificationName:@"noti_name2" object:p1 userInfo:nil];//作用相当于上边2行代码 发布notification2
    
    // 执行 testNotification2+testNotification3+person.doEvent  3个事件
    
 }

-(void)testNotificationEvent1:(NSNotification *)n
{
    NSLog(@"name : %@  boject = %@  userInfo = %@",[n name],[n object],[n userInfo]);
    NSLog(@"notification Event1 done.");
}

-(void)testNotificationEvent2:(NSNotification *)n
{
    NSLog(@"name : %@  boject = %@  userInfo = %@",[n name],[n object],[n userInfo]);
    NSLog(@"notification Event2 done.");
}



// 接收 Obersver = self, object =nil 的通知
-(void)testNotificationEvent3:(NSNotification *)n
{
    NSLog(@"***~~~~~~~");
    NSLog(@"Notification Event3 done.");
}


/*
 1、如果添加通知的时候传入了 object 参数，那么发送通知时，就会匹配 name 和 object 两个条件。如果没传 object 参数，则只匹配 name。
 2、如果中途修改 object 对象，那么通过 [[NSNotificationCenter defaultCenter] postNotificationName:@"lala" object:_name];这种方式发送的通知将会失效。
 3、移除通知的时候，如果remove中的 name 和 object 都存在， 那么以这种方式初始化的并且 name 一致，都会被移除掉。 如果 remove 中只有 name， 那么这个 name 下的所有通知都会被移除。
 4、[[NSNotificationCenter defaultCenter] removeObserver:self];不但会移除自己添加的通知，同时也会移除系统自动添加的通知，所以除非是类要被释放掉，不然谨慎使用这个方法。
 */
-(void)removeNotificationObersver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    /*
     删除通知的监听器
     */
    [center removeObserver:self];
    
    /*
     删除通知的监听器
     aName监听的通知的名称
     anObject监听的通知的发送对象
     */
    [center removeObserver:p1 name:@"noti_name2" object:self];
    [center removeObserver:self name:@"noti_name2" object:nil];
    [center removeObserver:self name:@"noti_name2" object:p1];
    
    if (_observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:_observer];
        _observer = nil;
    }
}

//为 NSNotificationCenter 添加分类，hook 掉系统的移除通知方法
+(void)loadr
{
    Method originRemoveM = class_getInstanceMethod([self class], @selector(removeObserver:));
    Method myRemoveM = class_getInstanceMethod([self class], @selector(my_removeObserver:));
    method_exchangeImplementations(originRemoveM, myRemoveM);
}

- (void)my_removeObserver:(id)observer
{
    NSLog(@"移除通知 -> observer = %@", observer);
    [self my_removeObserver:observer];
}


-(void)dealloc
{
    //[super dealloc];
    [p1 removeObserver:self forKeyPath:@"_money._bank"];
    [p1 removeObserver:self forKeyPath:@"_name"];
    
    [self removeNotificationObersver];
    
    NSLog(@"p1.dealloc");
}
@end
