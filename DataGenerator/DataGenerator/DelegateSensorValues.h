#import <MXi/MXi.h>
#import "SensorValue.h"

@interface DelegateSensorValues : MXiBean <MXiIncomingBean>

@property (nonatomic, strong) NSMutableArray* sensorValues;

- (id)init;

@end