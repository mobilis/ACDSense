//
//  main.m
//  DataGeneratorCL
//
//  Created by Martin Weißbach on 9/16/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "DataLoader.h"
#import "NSString+FileReading.h"
#import "MUCInformation.h"
#import "MUCInfoParser.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        if (argc != 5) {
            fprintf(stderr, "-r pathToRoomList -d pathToWeatherData");
            return 1;
        }


        NSString *weatherDataDirectory;
        NSString *roomDataDirectory;
        if (strcmp("-r", argv[1]) == 0) {
            weatherDataDirectory = [NSString stringWithCString:argv[4] encoding:NSUTF8StringEncoding];
            roomDataDirectory = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        }
        else if (strcmp("-d", argv[1]) == 0) {
            roomDataDirectory = [NSString stringWithCString:argv[4] encoding:NSUTF8StringEncoding];
            weatherDataDirectory = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        }

        NSArray *rawMUCInformation = [NSString linesOfStringsOfFile:roomDataDirectory];
        NSMutableArray *mucInformation = [NSMutableArray arrayWithCapacity:rawMUCInformation.count];
        for (NSString *rawMuc in rawMUCInformation)
            [mucInformation addObject:[[MUCInformation alloc] initWithAddress:[MUCInfoParser parseMUCAddressFromString:rawMuc]
                                                                         type:[MUCInfoParser parseMUCTypeFromString:rawMuc]
                                                                   lowerLimit:[MUCInfoParser parseLowerLimitFromString:rawMuc]
                                                                   upperLimit:[MUCInfoParser parseUpperLimitFromString:rawMuc]
                                                            intermediarySteps:[MUCInfoParser parseIntermediaryStepsFromString:rawMuc]]];

        DataLoader *dataLoader = [DataLoader loadWithDirectory:weatherDataDirectory];
        [dataLoader startLoading];
    }
    return 0;
}

