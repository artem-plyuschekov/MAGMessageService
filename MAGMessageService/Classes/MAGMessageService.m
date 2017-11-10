//
//  MAGMessageService.m
//  MAGStompKit
//
//  Created by Zykov Mikhail on 16.05.17.
//  Copyright © 2017 Zykov Mikhail. All rights reserved.
//

#import "MAGMessageService.h"
#import "MAGSocketClient.h"
#import "MAGMessageRAMQueue.h"

@interface MAGMessageService() <MAGSocketClientDelegate>

@property (nonatomic, strong) MAGSocketClient *socket;
@property (nonatomic, assign) NSInteger reopenCounter;
@property (nonatomic, strong) MAGReachability *hostReachability;
@property (nonatomic, assign) MAGNetworkStatus currentStatus;
@property (nonatomic, assign) BOOL isRun;
@property (nonatomic, strong) id<MAGMessageQueue> messageQueue;

@end

@implementation MAGMessageService

- (instancetype)init {
    self = [super init];
    if (self) {
        _socket = [[MAGSocketClient alloc] init];
        _socket.delegate = self;
        _reopenCounter = 1;
        _currentStatus = NotReachable;
        _isRun = NO;
        _messageQueue = [MAGMessageRAMQueue new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kMAGReachabilityChangedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(messagePushedToQueue:)
                                                     name:kMAGMessageQueuePushMessage
                                                   object:nil];
        
        self.hostReachability = [MAGReachability reachabilityWithHostName:@"www.google.com"];
        [self.hostReachability startNotifier];
    }
    return self;
}

- (void)start {
    self.isRun = YES;
    [self _start];
}

- (void)stop {
    self.isRun = NO;
    [self.hostReachability stopNotifier];
    [self _stop];
}

- (void)sendMessage:(NSDictionary *)message {
    [self.messageQueue pushMessage:message];
}

- (BOOL)setReachabilityHostName:(NSString *)hostName {
    [self.hostReachability stopNotifier];
    self.hostReachability = [MAGReachability reachabilityWithHostName:hostName];
    return [self.hostReachability startNotifier];
}

- (BOOL)setReachability:(MAGReachability *)reachability {
    [self.hostReachability stopNotifier];
    self.hostReachability = reachability;
    [self.hostReachability startNotifier];
}

- (void)setMessageQueue:(id<MAGMessageQueue>)queue {
    self.messageQueue = queue;
}

#pragma mark - Privater


- (void)didEnterBackground {
    [self _stop];
}

- (void)willEnterForeground {
    if (self.isRun == YES) {
        [self _start];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reachabilityChanged:(NSNotification *)note {
    MAGReachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[MAGReachability class]]);
    
    MAGNetworkStatus status = [curReach currentReachabilityStatus];
    if (self.currentStatus == status) {
        return;
    }
    
    self.currentStatus = status;
    if (!self.isRun) {
        return;
    }
    switch (status) {
        case NotReachable:
            [self _stop];
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            [self _start];
            break;
    }
}

- (void)messagePushedToQueue:(NSNotification *)notification {
    [self sendMessagesFromQueue];
}

- (void)sendMessagesFromQueue {
    while ((self.currentStatus != NotReachable) && (self.isRun)) {
        NSDictionary *message = [self.messageQueue firstMessage];
        if (message == nil) {
            break;
        }
        [self.socket sendMessage:message];
        [self.messageQueue removeFirstMessage];
    }
}

- (void)_start {
    __weak typeof(self) wSelf =  self;
    [self.delegate messageService:self connectingHandler:^(NSURL *url, NSString *token) {
        [wSelf.socket connectWithUrl:url token:token];
    }];
}

- (void)_stop {
    [self.socket disconnect];
    self.reopenCounter = 1;
}

#pragma mark - <MAGSocketClientDelegate>

- (void)didOpenSocketClient:(MAGSocketClient *)client {
    self.reopenCounter = 1;
    if ([self.delegate respondsToSelector:@selector(messageServiceConnected:)]) {
        [self.delegate messageServiceConnected:self];
    }
    [self sendMessagesFromQueue];
}

- (void)didCloseSocketClient:(MAGSocketClient *)client {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reopenCounter * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _start];
    });
    self.reopenCounter *= 2;
}

- (void)socketClient:(MAGSocketClient *)client receivedMessage:(NSDictionary *)message {
    NSLog(@"receivedMessage");
    [self.delegate messageService:self receivedMessage:message];
}

- (void)socketClient:(MAGSocketClient *)client receivedError:(NSError *)error {
    [self.delegate messageService:self receivedError:error];
}

@end
