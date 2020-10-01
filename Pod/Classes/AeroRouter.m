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

- (NSURLRequest *)headLastUpdateRequestForAccountID:(NSInteger)account
{
    NSURL *url = [self urlForPath:[NSString stringWithFormat:@"/Echo.json"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    [request setValue:@"application/vnd.echo-v2+json" forHTTPHeaderField:@"Accept"];
    return request;
}

- (NSURLRequest *)getFullContentRequestForAccountID:(NSInteger)account
{
    NSURL *url = [self urlForPath:[NSString stringWithFormat:@"/Echo.json"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/vnd.echo-v2+json" forHTTPHeaderField:@"Accept"];
    return request;
}


@end
