#import <UIKit/UIKit.h>

#define kMAGMessageQueuePushMessage = @"kMAGMessageQueuePushMessage"

@protocol MAGMessageQueue

- (void)pushMessage:(NSDictionary *)message;
- (NSArray<NSDictionary*> *)getMessages;

@end
