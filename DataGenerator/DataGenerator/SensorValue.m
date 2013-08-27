#import "SensorValue.h"

@implementation SensorValue

- (id)mutableCopyWithZone:(NSZone *)zone
{
    SensorValue *newValue = [[SensorValue allocWithZone:zone] init];
    newValue.subType = self.subType;
    newValue.value = self.value;
    newValue.unit = self.unit;
    
    return newValue;
}

@end