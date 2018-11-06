//
//  AppDelegate.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/1.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
- (IBAction)Btn_StrongVsCopy:(NSButton *)sender;
- (IBAction)Btn_Block:(NSButton *)sender;
- (IBAction)Btn_Thread死锁:(NSButton *)sender;

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
{
   __block BlockDemo *blockDemo;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        blockDemo = [BlockDemo new];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)Btn_StrongVsCopy:(NSButton *)sender {
    ReviewStrongVsCopy * RSC = [[ReviewStrongVsCopy alloc] init];
    [RSC testDeliverString];
    [RSC testDeliverMutableString];
    
    // Copy 对象会直接报错 unrecognized selector sent to instance；需要实现 allocWithZone:(NSZone*)zone
    ReviewStrongVsCopy *RSC2 = [RSC copy];
    NSLog(@"RSC2.String = %@",RSC2.strongStr);
}

- (IBAction)Btn_Block:(NSButton *)sender {
//    blockDemo.myBlock1 = ^{NSLog(@"Btn-This is myBlock1");};
//    blockDemo.myBlock1();
//
//    [blockDemo viewDidLoad];
//
    [blockDemo definedBlock];
    
    [blockDemo asParameterBlock];
    
    [blockDemo asFunctionResult];
}

- (IBAction)Btn_Thread死锁:(NSButton *)sender {
    [[Thread new] DeadLock];
    
}
- (IBAction)Btn_usualBlock:(NSButton *)sender {
    //测试Block的执行顺序
    [blockDemo usualBlock];
}

- (IBAction)Btn_SequenceBlock:(NSButton *)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self->blockDemo blockSequenceRun];
    });

}
@end
