//
//  MAGMessageService.h
//  MAGStompKit
//
//  Created by Zykov Mikhail on 16.05.17.
//  Copyright © 2017 Zykov Mikhail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAGMessageQueue.h"
#import "MAGReachability.h"

@class MAGMessageService;

typedef void(^MAGMessageServiceConnectingHandler)(NSURL *url, NSString *token);

@protocol MAGMessageServiceDelegate <NSObject>

- (void)messageService:(MAGMessageService *)service connectingHandler:(MAGMessageServiceConnectingHandler)handler;
- (void)messageService:(MAGMessageService *)service receivedMessage:(NSDictionary *)message;
- (void)messageService:(MAGMessageService *)service receivedError:(NSError *)error;
@optional
- (void)messageServiceConnected:(MAGMessageService *)service;

@end

@interface MAGMessageService : NSObject

@property (weak, nonatomic) id<MAGMessageServiceDelegate> delegate;

- (void)start;
- (void)stop;
- (void)sendMessage:(NSDictionary *)message;
- (BOOL)setReachabilityHostName:(NSString *)hostName;
- (BOOL)setReachability:(MAGReachability *)reachability;
- (void)setMessageQueue:(id<MAGMessageQueue>)queue;
@end
