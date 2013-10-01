#import "SensorValue.h"

@implementation SensorValue

- (id)mutableCopyWithZone:(NSZone *)zone
{
    SensorValue *value = [[SensorValue allocWithZone:zone] init];
    value.subType = self.subType;
    value.value = self.value;
    value.unit = self.unit;
    value.timestamp = self.timestamp;
    return value;
}

@end