#import "AeroRouter.h"

@interface AeroRouter()
@property (nonatomic, readonly, copy) NSURL *baseURL;
@end

@implementation AeroRouter

- (instancetype)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    if (!self) { return nil; }

    _baseURL = baseURL;

    return self;
}

- (NSURL *)urlForPath:(NSString *)path
{
    return [self.baseURL URLByAppendingPathComponent:path];
}

- (NSURLRequest *)headLastUpdateRequest
{
    NSURL *url = [self urlForPath:[NSString stringWithFormat:@"Echo.json"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    NSLog(@"Will request HEAD at %@", request.URL);
    return request;
}

- (NSURLRequest *)getFullContentRequest
{
    NSURL *url = [self urlForPath:[NSString stringWithFormat:@"Echo.json"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    NSLog(@"Will request GET at %@", request.URL);
    return request;
}

@end
