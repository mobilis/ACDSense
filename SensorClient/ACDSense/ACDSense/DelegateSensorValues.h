#import <MXi/MXi.h>

@interface DelegateSensorValues : MXiBean <MXiIncomingBean>

@property (nonatomic, strong) NSMutableArray* sensorValues;

- (id)init;

@end