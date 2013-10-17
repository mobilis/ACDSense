#import <MXi/MXi.h>
#import "SensorItem.h"

@interface DelegateSensorItems : MXiBean <MXiIncomingBean>

@property (nonatomic, strong) NSMutableArray* sensorItems;

- (id)init;

@end