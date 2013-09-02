#import <MXi/MXi.h>
#import "SensorMUCDomain.h"

@interface SensorMUCDomainRemoved : MXiBean <MXiIncomingBean>

@property (nonatomic, strong) SensorMUCDomain* sensorDomain;

- (id)init;

@end