@import Aerodramus;
@import Keys;

#import "ARViewController.h"

@interface ARViewController ()

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    AerodramusKeys *keys = [[AerodramusKeys alloc] init];

    NSURL *prodURL = [NSURL URLWithString:@"https://echo-api-production.herokuapp.com/"];

    Aerodramus *aero = [[Aerodramus alloc] initWithServerURL:prodURL accountID:1 APIKey:keys.echoKey localFilename:@"default"];
    [aero checkForUpdates:^(BOOL updatedDataOnServer) {
        if (!updatedDataOnServer) return;

        [aero update:^(BOOL updated, NSError *error) {

        }];
    }];
}


@end
