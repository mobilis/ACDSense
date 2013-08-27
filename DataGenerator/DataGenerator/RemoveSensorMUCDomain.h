#import <MXi/MXi.h>
#import "SensorMUCDomain.h"

@interface RemoveSensorMUCDomain : MXiBean <MXiOutgoingBean>

@property (nonatomic, strong) SensorMUCDomain* domain;

- (id)init;

@end