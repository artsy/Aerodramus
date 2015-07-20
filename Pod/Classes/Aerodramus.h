@import Foundation;

#if __has_feature(objc_generics)
#define NSArrayOf(x) NSArray<x>
#else
#define NSArrayOf(x) NSArray
#endif

@class Route, Feature, Message;

/// A class to communicate with the Artsy Echo API
/// @see Web Interface: https://echo-web-production.herokuapp.com/
/// @see Heroku Settings URL: https://dashboard.heroku.com/apps/echo-web-production/settings

@interface Aerodramus : NSObject

/// Creates an instance of Aerodramus hooked up to an echo URL
/// It will look in the user's document dir for [filename].json
/// and then fall back to looking inside the App bundle.

- (instancetype)initWithServerURL:(NSURL *)url accountID:(NSInteger)accountID APIKey:(NSString *)APIKey localFilename:(NSString *)filename;

/// Does a HEAD request against the server comparing the local date with the last changed
- (void)checkForUpdates:(void (^)(BOOL updatedDataOnServer))updateCheckCompleted;

/// Updates the local instance with data from the server
- (void)update:(void (^)(BOOL updated, NSError *error))completed;

/// Saves the current object to disk
- (BOOL)saveToDisk:(void (^)(BOOL saved))saveCompleted;

/// The Echo account name for this app
@property (nonatomic, nonnull, copy) NSString *name;

/// The Echo account ID for this app
@property (nonatomic, assign) NSInteger accountID;

/// The time when this instance of Aerodramus was last updated
@property (nonatomic, nonnull, strong) NSDate *lastUpdatedDate;

/// Collection of routes from the echo server
@property (nonatomic, nonnull, copy) NSArrayOf(Route *) *routes;

/// Collection of boolean feature switches from the echo server
@property (nonatomic, nonnull, copy) NSArrayOf(Feature *) *features;

/// Collection of messages from the echo server
@property (nonatomic, nonnull, copy) NSArrayOf(Message *) *messages;

@end
