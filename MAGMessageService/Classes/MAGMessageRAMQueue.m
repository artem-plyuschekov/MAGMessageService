#import "MAGMessageRAMQueue.h"

@interface MAGMessageRAMQueue()

    @property (strong, nonatomic) NSMutableArray<NSDictionary*> *messages;

@end

@implementation MAGMessageRAMQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.messages = [NSMutableArray<NSDictionary*> new];
    }
    return self;
}

- (void)pushMessage:(NSDictionary *)message {
    if (message) {
        [self.messages addObject:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMAGMessageQueuePushMessage
                                                            object:message];
    }
}

- (NSArray<NSDictionary*> *)getMessages; {
    return self.messages;
}

- (NSDictionary *)firstMessage {
    return self.messages.firstObject;
}

- (void)removeFirstMessage {
    if (self.messages.count > 0) {
        [self.messages removeObjectAtIndex:0];
    }
}

- (void)removeAllMessages {
    [self.messages removeAllObjects];
}

@end
