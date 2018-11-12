//
//  AppDelegate.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/1.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSTextField *lbl_label1;   //NSTimer调用
@property (weak) IBOutlet NSTextField *lbl_label2;   //NSTimer调用

- (IBAction)Btn_StrongVsCopy:(NSButton *)sender;

- (IBAction)Btn_Block:(NSButton *)sender;
- (IBAction)Btn_BlockDefine:(NSButton *)sender;
- (IBAction)Btn_BlockAsParamter:(NSButton *)sender;
- (IBAction)Btn_BlockAsResult:(NSButton *)sender;

- (IBAction)Btn_Thread死锁:(NSButton *)sender;
- (IBAction)Btn_WriteLog:(NSButton *)sender;
- (IBAction)Btn_DispatchQueueApply:(NSButton *)sender;
- (IBAction)Btn_DispatchQueueBarrier:(NSButton *)sender;
- (IBAction)Btn_NSTimer:(NSButton *)sender;
- (IBAction)Btn_ThreadRunLoop:(NSButton *)sender;



@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
{
   __block BlockDemo *blockDemo;
    Thread *threadDemo;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        blockDemo = [BlockDemo new];
        threadDemo = [Thread new];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //NSLog(@"main loop = %@",[NSRunLoop currentRunLoop]);
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
    blockDemo.myBlock1 = ^{NSLog(@"Btn-This is myBlock1");};
    blockDemo.myBlock1();
}

- (IBAction)Btn_BlockDefine:(NSButton *)sender {
    [blockDemo definedBlock];
}

- (IBAction)Btn_BlockAsParamter:(NSButton *)sender {
    [blockDemo asParameterBlock];
}

- (IBAction)Btn_BlockAsResult:(NSButton *)sender {
    [blockDemo asFunctionResult];
}

- (IBAction)Btn_Thread死锁:(NSButton *)sender {
    [[Thread new] DeadLock];
}
- (IBAction)Btn_usualBlock:(NSButton *)sender {
    //测试Block的执行顺序
    [blockDemo usualBlock];
}

- (IBAction)Btn_SequenceBlock:(NSButton *)sender { dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self->blockDemo blockSequenceRun];
    });
}

- (IBAction)Btn_WriteLog:(NSButton *)sender {
    [[Thread new] writeLog];
}

- (IBAction)Btn_DispatchQueueApply:(NSButton *)sender {
    [[Thread new] dispatchQueueApply];
}

- (IBAction)Btn_DispatchQueueBarrier:(NSButton *)sender {
    [[Thread new] DownloadFilesWithGCD];
}

- (IBAction)Btn_NSTimer:(NSButton *)sender {
    [threadDemo timer:self.lbl_label1 label2:self.lbl_label2];
}

- (IBAction)Btn_ThreadRunLoop:(NSButton *)sender {
    [Thread createLoop];
}


@end
