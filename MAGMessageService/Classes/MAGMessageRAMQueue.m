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
    if (!message) {
        [self.messages addObject:message];
    }
}

- (NSArray<NSDictionary*> *)getMessages; {
    return self.messages;
}

@end
