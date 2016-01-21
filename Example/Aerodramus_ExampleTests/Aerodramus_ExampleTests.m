@import Specta;
@import Expecta;
@import Aerodramus;


SpecBegin(InitialSpecs)

describe(@"these will pass", ^{

    it(@"can do maths", ^{
        expect(1).beLessThan(23);
    });

    it(@"can read", ^{
        expect(@"team").toNot.contain(@"I");
    });

    it(@"will wait and succeed", ^{

    });
});

SpecEnd

