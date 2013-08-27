#import "Location.h"

@implementation Location

- (id)copyWithZone:(NSZone *)zone
{
    Location *newLocation = [[Location allocWithZone:zone] init];
    newLocation.latitude = self.latitude;
    newLocation.longitude = self.longitude;
    
    return newLocation;
}

@end