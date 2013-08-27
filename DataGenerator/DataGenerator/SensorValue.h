@interface SensorValue : NSObject <NSMutableCopying>

@property (nonatomic, strong) NSString* subType;
@property (nonatomic, strong) NSString* value;
@property (nonatomic, strong) NSString* unit;

@end