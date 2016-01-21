@import ISO8601DateFormatter;

#import "Aerodramus.h"
#import "AeroRouter.h"

#import "Feature.h"
#import "Message.h"
#import "Route.h"

@interface Aerodramus()
@property (nonatomic, copy, readonly) NSString *filename;
@property (nonatomic, strong, readonly) AeroRouter *router;
@end

@implementation Aerodramus

- (instancetype)initWithServerURL:(NSURL *)url accountID:(NSInteger)accountID APIKey:(NSString *)APIKey localFilename:(NSString *)filename;
{
    self = [super init];
    if (!self) return nil;

    _filename = url.copy;
    _filename = filename.copy;
    _accountID = accountID;
    _router = [[AeroRouter alloc] initWithAPIKey:APIKey baseURL:url];

    NSURL *pathForStoredJSON = [self filePathForFileName:filename];
    NSString *errorMessage = [NSString stringWithFormat:@"Could not find a default json for Aerodramus at %@", pathForStoredJSON];
    NSAssert(pathForStoredJSON, errorMessage);
    if (!pathForStoredJSON) return nil;

    NSData *data = [NSData dataWithContentsOfURL:pathForStoredJSON];
    [self updateWithJSONData:data];

    return self;
}

- (NSURL *)storedDocumentsFilePathWithName:(NSString *)name
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *docsDir = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [docsDir URLByAppendingPathComponent:[name stringByAppendingString:@".json"]];
}

- (NSURL *)filePathForFileName:(NSString *)name
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *fileDocsURL = [self storedDocumentsFilePathWithName:name];
    if ([manager fileExistsAtPath:fileDocsURL.path]) { return fileDocsURL; }

    return [[NSBundle mainBundle] URLForResource:name withExtension:@"json"];
}

- (void)updateWithJSONData:(NSData *)JSONdata
{
    NSError *error = nil;
    id JSON = [NSJSONSerialization JSONObjectWithData:JSONdata options:0 error:&error];
    if (error) {
        NSLog(@"Could not serialize Aerodramus JSON: %@", error.localizedDescription);
        return;
    }

    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSString *lastUpdatedDateString = JSON[@"updated_at"];

    _lastUpdatedDate = [formatter dateFromString:lastUpdatedDateString];
    _name = [JSON[@"name"] copy];

    _features = [self mapArray:JSON[@"features"] map:^id(NSDictionary *featureDict) {
        return [[Feature alloc] initWithName:featureDict[@"name"] state:featureDict[@"value"]];
    }];

    _messages = [self mapArray:JSON[@"messages"] map:^id(NSDictionary *messageDict) {
        return [[Message alloc] initWithName:messageDict[@"name"] content:messageDict[@"content"]];
    }];

    _routes = [self mapDict:JSON[@"routes"] map:^id(NSDictionary *routeDict) {
        return [[Route alloc] initWithName:routeDict[@"name"] path:routeDict[@"path"]];
    }];
}

- (void)checkForUpdates:(void (^)(BOOL updatedDataOnServer))updateCheckCompleted
{
    NSURLRequest *request = [self.router headLastUpdateRequestForAccountID:self.accountID];
    [self performRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error) {
            updateCheckCompleted(NO);
            return;
        }

        if ([response isKindOfClass:NSHTTPURLResponse.class]) {
            NSHTTPURLResponse *httpResponse = (id)response;
            ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
            
            NSString *updatedAtString =  httpResponse.allHeaderFields[@"Updated-At"];
            NSDate *lastUpdatedDate = [formatter dateFromString:updatedAtString];

            BOOL later = ([lastUpdatedDate compare:self.lastUpdatedDate] == NSOrderedDescending);
            updateCheckCompleted(later);
            return;
        }

        updateCheckCompleted(NO);
        return;
    }];
}

- (void)update:(void (^)(BOOL updated, NSError *error))completed;
{
    NSURLRequest *request = [self.router getFullContentRequestForAccountID:self.accountID];
    [self performRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error || data == nil) {
            completed(NO, error);
            return;
        }

        [self updateWithJSONData:data];
        BOOL saved = [self saveJSONToDisk:data];
        completed(saved, nil);

        return;
    }];
}

- (BOOL)saveJSONToDisk:(NSData *)JSONdata
{
    NSError *error;
    NSURL *url = [self storedDocumentsFilePathWithName:self.filename];
    BOOL success = [JSONdata writeToURL:url options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"Error saving Aerodramus json data: %@", error.localizedDescription);
    }
    return success;
}


#pragma mark Helper methods

- (NSArray *)mapArray:(NSArray *)array map:(id (^)(id object))block {
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];

    for (id object in array) {
        id newObject = block(object);
        if (newObject) {
            [newArray addObject:newObject];
        }
    }

    return [NSArray arrayWithArray:newArray];
}

- (NSDictionary *)mapDict:(NSArray *)array map:(id (^)(id object))block {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];

    for (id object in array) {
        id newObject = block(object);
        if (newObject) {
            NSString *key = object[@"name"];
            newDict[key] = newObject;
        }
    }

    return [NSDictionary dictionaryWithDictionary:newDict];
}

- (void)performRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}

@end
