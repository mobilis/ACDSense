#import <MXi/MXi.h>
#import "SensorMUCDomain.h"

@interface GetSensorMUCDomainsResponse : MXiBean <MXiIncomingBean>

@property (nonatomic, strong) NSMutableArray* sensorDomains;

- (id)init;

@end