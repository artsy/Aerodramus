#import "Route.h"

@implementation Route

- (instancetype)initWithName:(NSString *)name route:(NSString *)route
{
    self = [super init];
    if (!self) return nil;

    _name = name;
    _route = route;
    return self;
}

@end
