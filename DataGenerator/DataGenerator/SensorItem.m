#import "SensorItem.h"

@implementation SensorItem

- (id)init
{
    self = [super init];
    if (self) {
        self.values = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

@end