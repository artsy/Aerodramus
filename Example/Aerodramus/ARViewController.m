@import Aerodramus;

#import "ARViewController.h"

@interface ARViewController ()

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *uRL = [NSURL URLWithString:@"https://echo.artsy.net"];

    Aerodramus *aero = [[Aerodramus alloc] initWithServerURL:uRL localFilename:@"Echo"];
    [aero setup];
    [aero checkForUpdates:^(BOOL updatedDataOnServer) {
        if (!updatedDataOnServer) return;

        [aero update:^(BOOL updated, NSError *error) {
            NSLog(@"Updated");
        }];
    }];
}


@end
