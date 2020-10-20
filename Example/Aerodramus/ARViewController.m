@import Aerodramus;

#import "ARViewController.h"

@interface ARViewController ()

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *prodURL = [NSURL URLWithString:@"https://echo-api-production.herokuapp.com/"];

    Aerodramus *aero = [[Aerodramus alloc] initWithServerURL:prodURL localFilename:@"Echo"];
    [aero setup];
    [aero checkForUpdates:^(BOOL updatedDataOnServer) {
        if (!updatedDataOnServer) return;

        [aero update:^(BOOL updated, NSError *error) {
            NSLog(@"Updated");
        }];
    }];
}


@end
