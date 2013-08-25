#import "SensorValue.h"
@interface SensorItem : NSObject

@property (nonatomic, strong) NSString* sensorId;
@property (nonatomic, strong) NSMutableArray* values;
@property (nonatomic, strong) NSString* location;
@property (nonatomic, strong) NSString* type;

@end