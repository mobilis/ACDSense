#import <MXi/MXi.h>

@class DelegateSensorValues;

@interface PublishSensorValues : MXiBean <MXiOutgoingBean>

@property (nonatomic, strong) NSMutableArray* sensorValues;

- (id)init;

@end