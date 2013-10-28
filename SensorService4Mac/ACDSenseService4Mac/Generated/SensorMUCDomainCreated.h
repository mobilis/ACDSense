#import <MXi/MXi.h>
#import "SensorMUCDomain.h"

@interface SensorMUCDomainCreated : MXiBean <MXiIncomingBean, MXiOutgoingBean>

@property (nonatomic, strong) SensorMUCDomain* sensorDomain;

- (id)init;

@end