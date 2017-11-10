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
@optional
- (void)messageServiceConnected:(MAGMessageService *)service;
- (void)messageService:(MAGMessageService *)service receivedMessage:(NSDictionary *)message;
- (void)messageService:(MAGMessageService *)service receivedError:(NSError *)error;

@end

@interface MAGMessageService : NSObject

@property (weak, nonatomic) id<MAGMessageServiceDelegate> delegate;
@property (strong, nonatomic) id<MAGMessageQueue> queue;

- (void)start;
- (void)stop;
- (void)sendMessage:(NSDictionary *)message;
- (BOOL)setReachabilityHostName:(NSString *)hostName;
- (BOOL)setReachability:(MAGReachability *)reachability;
@end
