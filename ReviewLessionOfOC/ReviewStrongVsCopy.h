//
//  ReviewStrongVsCopy.h
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/1.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//


/*
 @property是一个属性访问声明，扩号内支持以下几个属性：
 1，getter=getterName，setter=setterName，设置setter与getter的方法名
 2，readwrite,readonly，设置可供访问级别
 2，assign，setter方法直接赋值，不进行任何retain操作，为了解决原类型与环循引用问题
 3，retain，setter方法对参数进行release旧值再retain新值，所有实现都是这个顺序(CC上有相关资料)
 4，copy，setter方法进行Copy操作，与retain处理流程一样，先旧值release，再Copy出新的对象，retainCount为1。这是为了减少对上下文的依赖而引入的机制。
 5，nonatomic，非原子性访问，不加同步，多线程并发访问会提高性能。注意，如果不加此属性，则默认是两个访问方法都为原子型事务访问。锁被加到所属对象实例级。
 @synthesize xxx;  为这个心属性自动生成读写函数；
 
 extain 1:
 Copy其实是建立了一个相同的对象，而retain不是：
 比如一个NSString 对象，地址为0×1111 ，内容为@”STR”
 Copy 到另外一个NSString 之后，地址为0×2222 ，内容相同，新的对象retain为1 ，旧有对象没有变化
 retain 到另外一个NSString 之后，地址相同（建立一个指针，指针拷贝），内容当然相同，这个对象的retain值+1
 也就是说，retain 是指针拷贝，copy 是内容拷贝。哇，比想象的简单多了…
 
 extain 2:
 atomic和nonatomic用来决定编译器生成的getter和setter是否为原子操作。
 atomic：设置成员变量的@property属性时，默认为atomic，提供多线程安全。
 nonatomic：禁止多线程，变量保护，提高性能。atomic是OC使用的一种线程保护技术，基本上来说，是防止在写未完成的时候被另一个线程读取，造成数据错误。而这种机制是耗费系统资源的。所以在iPhone这种小型设备上，如果没有使用多线程间的通讯编程，那么nonatomic是一个非常好的选择。
 *基础数据类型和c类型不使用引用计数器（用assign修饰）。assign是直接赋值，retain是使用引用计数器。
 */



#import <Foundation/Foundation.h>


#if DEBUG
#warning NSLog will be shown
#else
#define NSLog(...) {}
#endif



NS_ASSUME_NONNULL_BEGIN

@interface ReviewStrongVsCopy : NSObject

@property (strong,nonatomic) NSString * strongStr;
@property (copy,nonatomic) NSString * cpStr;  //copyString   命名不能以关键字开头



/*
 如果一般情况下，我们不希望字串的值跟着mStr变化，所以我们一般用copy来设置string的属性。
 如果希望字串的值跟着赋值的字串的值变化，可以使用strong，retain。
 注意：上面的情况是针对于当把NSMutableString赋值给NSString的时候，才会有不同，如果是赋值是NSString
 对象，那么使用copy还是strong，结果都是一样的，因为NSString对象根本就不能改变自身的值，他是不可变的。
 把一个对象赋值给一个属性变量，当这个对象变化了，如果希望属性变量变化就使用strong属性，如果希望属性变量不跟着变化，就是用copy属性。
 */
-(void)testDeliverString;
-(void)testDeliverMutableString;



@end

NS_ASSUME_NONNULL_END
