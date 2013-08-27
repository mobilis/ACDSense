#import <MXi/MXi.h>
#import "SensorMUCDomain.h"

@interface SensorMUCDomainCreated : MXiBean <MXiIncomingBean>

@property (nonatomic, strong) SensorMUCDomain* domain;

- (id)init;

@end