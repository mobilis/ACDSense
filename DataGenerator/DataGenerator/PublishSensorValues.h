#import <MXi/MXi.h>
#import "SensorValue.h"

@interface PublishSensorValues : MXiBean <MXiOutgoingBean>

@property (nonatomic, strong) NSMutableArray* sensorValues;

- (id)init;

@end