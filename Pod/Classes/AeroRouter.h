#import <Foundation/Foundation.h>

/// Offers a way to get NSURLRequests for common tasks

@interface AeroRouter : NSObject

/// Inits with an API key and the URL where you are hosting an Echo instance
- (instancetype)initWithBaseURL:(NSURL *)baseURL;

/// A new reqeust for the HEAD details for an account
- (NSURLRequest *)headLastUpdateRequestForAccountID:(NSInteger)account;

/// a new request that GETs the full content for an account
- (NSURLRequest *)getFullContentRequestForAccountID:(NSInteger)account;

@end
