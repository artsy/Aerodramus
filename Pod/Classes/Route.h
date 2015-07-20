#import <Foundation/Foundation.h>

@interface Route : NSObject

- (instancetype)initWithName:(NSString *)name route:(NSString *)route;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *route;

@end
