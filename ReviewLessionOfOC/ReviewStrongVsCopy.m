//
//  ReviewStrongVsCopy.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/1.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "ReviewStrongVsCopy.h"

@implementation ReviewStrongVsCopy


//1.传递NSString类型，更改NSString值，查看结果得出：Strong & Copy 是同一个对象，不会随着TargetString改变
-(void)testDeliverString
{
    NSString *targetString = @"Target.";
    self.strongStr = targetString;
    self.cpStr =targetString;
    
    
    NSLog(@"targetString:[%@], %p,%p",targetString,targetString,&targetString);
    NSLog(@"strongString:[%@], %p,%p",_strongStr,_strongStr,_strongStr);
    NSLog(@"copyString:[%@], %p,%p",_cpStr,_cpStr,_cpStr);
    
    //targetString:[Target.], 0x100002070,0x7ffeefbfe618
    //strongString:[Target.], 0x100002070,0x100002070
    //copyString:[Target.], 0x100002070,0x100002070
    
    //上段代码中strongStr与targetStr指向同样的地址，他们指向的是同一个对象@“Target.”，这个对象的地址没变，所以他们的值是一样的。
    //当把targetStr赋值给copy的cStr时，cStr对象是深复制而来，一个新的对象，这个对象有新的地址不再是原来的地址.
    
    // 改变targetString 的值
    targetString = @"new target.";
    NSLog(@"targetString:[%@], %p,%p",targetString,targetString,&targetString);
    NSLog(@"strongString:[%@], %p,%p",_strongStr,_strongStr,_strongStr);
    NSLog(@"copyString:[%@], %p,%p",_cpStr,_cpStr,_cpStr);
    //targetString:[new target.], 0x1000020f0,0x7ffeefbfe618
    //strongString:[Target.], 0x100002070,0x100002070
    //copyString:[Target.], 0x100002070,0x100002070
    
    // 从上面可以看出 只有targetString 进行了改变
}

//2.传递NSMutableString. 改变值时，Strong类型保持指针不变，内容变动；CopyString 会穿件
-(void)testDeliverMutableString
{
    NSMutableString *targetString = [NSMutableString stringWithString:@"Target."];
    self.strongStr = targetString;
    self.cpStr =targetString;
    
    NSLog(@"targetString:[%@], %p,%p",targetString,targetString,&targetString);
    NSLog(@"strongString:[%@], %p,%p",_strongStr,_strongStr,_strongStr);
    NSLog(@"copyString:[%@], %p,%p",_cpStr,_cpStr,_cpStr);
    
    //targetString:[Target.], 0x600000255cc0,0x7ffeefbfe618
    //strongString:[Target.], 0x600000255cc0,0x600000255cc0
    //copyString:[Target.], 0x2e74656772615475,0x2e74656772615475
    
    //上段代码中strongStr与targetStr指向同样的地址，他们指向的是同一个对象@“Target.”，这个对象的地址没变，所以他们的值是一样的。
    //当把targetStr赋值给copy的cStr时，cStr对象是深复制而来，一个新的对象，这个对象有新的地址不再是原来的地址.
    
    // 改变targetString 的值
    [targetString appendString: @"new string"];
    NSLog(@"targetString:[%@], %p,%p",targetString,targetString,&targetString);
    NSLog(@"strongString:[%@], %p,%p",_strongStr,_strongStr,_strongStr);
    NSLog(@"copyString:[%@], %p,%p",_cpStr,_cpStr,_cpStr);
    
    //targetString:[Target.new string], 0x600000255cc0,0x7ffeefbfe618    ---内容改动
    //strongString:[Target.new string], 0x600000255cc0,0x600000255cc0    ---内容改动
    //copyString:[Target.], 0x2e74656772615475,0x2e74656772615475        ---内容不变
}


// 为Copy 功能实现; 属性也要赋值，否则为未初始化状态[nil/0]
-(id)copyWithZone:(NSZone *)zone
{
    ReviewStrongVsCopy *rsv = [[ReviewStrongVsCopy allocWithZone:zone] init];
    
    // 这里self其实就要被copy的那个对象，很显然要自己赋值给新对象，所以这里可以控制copy的属性
    rsv.strongStr = self.strongStr;
    rsv.cpStr = self.cpStr;
    return rsv;
}

@end
