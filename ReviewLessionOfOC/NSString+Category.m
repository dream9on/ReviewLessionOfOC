//
//  NSString+Category.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/13.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

/*
#import "NSString+Category.h"
#import <objc/runtime.h>
static const void *IndieBandNameKey = &IndieBandNameKey;

@implementation NSString (Category)
@dynamic indieBandName;
*/

/*
 在类别中添加实例变量
 那我偏偏想要在类别中添加实例变量该怎么办呢？这时候就要用到runtime了，不要忘记了Objective-C是动态语言。
 一种常见的办法是通过runtime.h中objc_getAssociatedObject / objc_setAssociatedObject来访问和生成关联对象。
 这两个方法可以让一个对象和另一个对象关联，就是说一个对象可以保持对另一个对象的引用，并获取那个对象。
 
 */

/*

- (NSString *)indieBandName {
    return objc_getAssociatedObject(self, IndieBandNameKey);
}
- (void)setIndieBandName:(NSString *)indieBandName {
    objc_setAssociatedObject(self, IndieBandNameKey, indieBandName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
*/

/*
 给 Category 添加 weak 属性。
 首先，给 Category 属性是需要使用runtime中的关联来实现set 和 get 方法。但runtime只提供如下几种修饰实现，并没有weak。
 
 **typedef OBJC_ENUM(uintptr_t, objc_AssociationPolicy) {
 OBJC_ASSOCIATION_ASSIGN = 0,            // < Specifies a weak reference to the associated object. *
 OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,  //< Specifies a strong reference to the associated object.
                                          The association is not made atomically. *
 OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   //< Specifies that the associated object is copied.
                                        *  The association is not made atomically. *
 OBJC_ASSOCIATION_RETAIN = 01401,      //< Specifies a strong reference to the associated object.
                                        *   The association is made atomically. *
 OBJC_ASSOCIATION_COPY = 01403          //< Specifies that the associated object is copied.
                                        *   The association is made atomically. *
};
 */


/*

- (id)objc_weak_id {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setObjc_weak_id:(id)objc_weak_id {
    NSString *ob = [[NSString alloc] initWithBlock:^{
        objc_setAssociatedObject(self, @selector(objc_weak_id), nil, OBJC_ASSOCIATION_ASSIGN);
    }];
    // 这里关联的key必须唯一，如果使用_cmd，对一个对象多次关联的时候，前面的对象关联会失效。
    objc_setAssociatedObject(objc_weak_id, (__bridge const void *)(ob.block), ob, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, @selector(objc_weak_id), objc_weak_id, OBJC_ASSOCIATION_ASSIGN);
}


-(instancetype)initWithBlock:(DeallocBlock)block1
{
    if (self = [super init]) {
        self.block = block1;
    }
    
    return self;
}

-(void)dealloc
{
    self.block? self.block():nil;
}

@end
*/
