#import "SensorMUCDomain.h"
#import "SensorValue.h"
#import "Location.h"
@interface SensorItem : NSObject

@property (nonatomic, strong) NSString* sensorId;
@property (nonatomic, strong) NSString* sensorDescription;
@property (nonatomic, strong) SensorMUCDomain* sensorDomain;
@property (nonatomic, strong) NSMutableArray* values;
@property (nonatomic, strong) Location* location;
@property (nonatomic, strong) NSString* type;

@end