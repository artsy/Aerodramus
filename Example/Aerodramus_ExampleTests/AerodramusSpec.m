#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Aerodramus/Aerodramus.h>
#import <Forgeries/Forgeries.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@interface Aerodramus(PrivateButTests)
@property (nonatomic, copy, readonly) NSString *filename;
@property (nonatomic, strong, readonly) AeroRouter *router;
@property (nonatomic, strong) NSFileManager *fileManager;
@end


SpecBegin(AeroTests)

__block Aerodramus *subject;

describe(@"getting the default file", ^{

    before(^{
        NSURL *url = [NSURL URLWithString:@"http://echo.com"];
        subject = [[Aerodramus alloc] initWithServerURL:url accountID:1 APIKey:@"KEY" localFilename:@"EchoTest"];
    });

    it(@"prioritises looking in user documents", ^{
        ForgeriesFileManager *fm = [ForgeriesFileManager withFileStringMap:@{
             @"/docs/EchoTest.json" : @{ @"updated_at" : @"2001-01-23" },
             @"/app/EchoTest.json": @{ @"updated_at" : @"1985-01-23" }
        }];
        subject.fileManager = fm;
        [subject setup];

        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:subject.lastUpdatedDate];
        expect(components.year).to.equal(2001);
    });

    it(@"falls back to the App's JSON", ^{
        ForgeriesFileManager *fm = [ForgeriesFileManager withFileStringMap:@{
             @"/docs/NotEchoTest.json" : @{ @"updated_at" : @"2001-01-23" },
             @"/app/EchoTest.json": @{ @"updated_at" : @"1985-01-23" }
        }];

        subject.fileManager = fm;
        [subject setup];

        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:subject.lastUpdatedDate];
        expect(components.year).to.equal(1985);
    });
});

describe(@"ORM", ^{

    before(^{
        NSURL *url = [NSURL URLWithString:@"http://echo.com"];
        subject = [[Aerodramus alloc] initWithServerURL:url accountID:1 APIKey:@"KEY" localFilename:@"EchoStubbed"];
    });

    it(@"sets up Aerodramus", ^{
        [subject setup];
        expect(subject.name).to.equal(@"eigen");
        expect(subject.accountID).to.equal(1);

        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        NSDate *date = [formatter dateFromString:@"2016-01-21T13:50:16.982Z"];
        expect(subject.lastUpdatedDate).to.equal(date);
    });

    it(@"converts features", ^{
        [subject setup];
        expect([subject features].count).to.equal(2);

        Feature *feature = subject.features[@"ipad_vir"];
        expect(feature.name).to.equal(@"ipad_vir");
        expect(feature.state).to.equal(false);
    });

    it(@"converts messages", ^{
        [subject setup];
        expect([subject messages].count).to.equal(1);

        Message *message = subject.messages.allValues.firstObject;
        expect(message.name).to.equal(@"intro_text");
        expect(message.content).to.equal(@"Artsy has 300,000 artworks");
    });

    it(@"converts routes", ^{
        [subject setup];
        expect([subject routes].count).to.equal(11);

        Route *route = subject.routes[@"ARArtistRoute"];
        expect(route.name).to.equal(@"ARArtistRoute");
        expect(route.path).to.equal(@"/artist/:id");
    });
});


SpecEnd

