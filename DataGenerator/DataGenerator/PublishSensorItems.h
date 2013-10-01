#import <MXi/MXi.h>
#import "SensorItem.h"

@interface PublishSensorItems : MXiBean <MXiOutgoingBean>

@property (nonatomic, strong) NSMutableArray* sensorItems;

- (id)init;

@end