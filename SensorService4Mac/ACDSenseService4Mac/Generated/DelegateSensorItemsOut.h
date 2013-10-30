#import <MXi/MXi.h>
#import "SensorItem.h"

@interface DelegateSensorItemsOut : MXiBean <MXiOutgoingBean>

@property (nonatomic, strong) NSMutableArray* sensorItems;

- (id)init;

@end