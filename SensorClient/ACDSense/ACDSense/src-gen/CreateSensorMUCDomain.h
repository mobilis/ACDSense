#import <MXi/MXi.h>
#import "SensorMUCDomain.h"

@interface CreateSensorMUCDomain : MXiBean <MXiOutgoingBean>

@property (nonatomic, strong) SensorMUCDomain* sensorDomain;

- (id)init;

@end