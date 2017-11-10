#import <UIKit/UIKit.h>

static NSString *const kMAGMessageQueuePushMessage = @"kMAGMessageQueuePushMessage";

@protocol MAGMessageQueue

- (void)pushMessage:(NSDictionary *)message;
- (NSArray<NSDictionary*> *)getMessages;
- (void)removeAllMessages;

- (NSDictionary *)firstMessage;
- (void)removeFirstMessage;

@end
