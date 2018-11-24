//
//  RCTAppleHealthKit+Methods_Activity.m
//  RCTAppleHealthKit
//
//  Created by Alexander Vallorosi on 4/27/17.
//  Copyright © 2017 Alexander Vallorosi. All rights reserved.
//

#import "RCTAppleHealthKit+Methods_Activity.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Methods_Activity)

- (void)activity_getActiveEnergyBurned:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *activeEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    HKUnit *cal = [HKUnit kilocalorieUnit];

    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:activeEnergyType
                                unit:cal
                           predicate:predicate
                           ascending:false
                               limit:HKObjectQueryNoLimit
                          completion:^(NSArray *results, NSError *error) {
                              if(results){
                                  callback(@[[NSNull null], results]);
                                  return;
                              } else {
                                  NSLog(@"error getting active energy burned samples: %@", error);
                                  callback(@[RCTMakeError(@"error getting active energy burned samples", nil, nil)]);
                                  return;
                              }
                          }];
}

- (void)activity_getActivitySummary:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    // Create the date components for the predicate
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    
    NSDateComponents *startDateComponents = [calendar components:unit fromDate:startDate];
    startDateComponents.calendar = calendar;
    
    NSDateComponents *endDateComponents = [calendar components:unit fromDate:endDate];
    endDateComponents.calendar = calendar;
    
    // Create the predicate for the query
    NSPredicate *summariesWithinRange =
    [HKQuery predicateForActivitySummariesBetweenStartDateComponents:startDateComponents endDateComponents:endDateComponents];
    
    // Build the query
    HKActivitySummaryQuery *query = [[HKActivitySummaryQuery alloc] initWithPredicate:summariesWithinRange resultsHandler:^(HKActivitySummaryQuery * _Nonnull query, NSArray<HKActivitySummary *> * _Nullable activitySummaries, NSError * _Nullable error) {
        
        if (activitySummaries) {
            NSMutableArray *results = [NSMutableArray arrayWithCapacity:1];
            for (HKActivitySummary *summary in activitySummaries) {
                NSLog(@"Summary: %@", summary.activeEnergyBurned);
                NSLog(@"Summary: %@", summary.appleExerciseTime);
                NSLog(@"Summary: %@", summary.activeEnergyBurnedGoal);
                NSLog(@"Summary: %@", summary.appleStandHours);
                NSLog(@"Summary: %@", summary.appleStandHoursGoal);
                
                NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
                
                NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"%@", summary.activeEnergyBurned]];
                NSString *activeEnergyBurnedString;
                [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
                [scanner scanCharactersFromSet:numbers intoString:&activeEnergyBurnedString];
                
                NSString *activeEnergyBurnedGoalString;
                scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"%@", summary.activeEnergyBurnedGoal]];
                [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
                [scanner scanCharactersFromSet:numbers intoString:&activeEnergyBurnedGoalString];
                
                NSString *appleStandHoursString;
                scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"%@", summary.appleStandHours]];
                [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
                [scanner scanCharactersFromSet:numbers intoString:&appleStandHoursString];
                
                NSString *appleStandHoursGoalString;
                scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"%@", summary.appleStandHoursGoal]];
                [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
                [scanner scanCharactersFromSet:numbers intoString:&appleStandHoursGoalString];
                
                NSString *appleExerciseTimeString;
                scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"%@", summary.appleExerciseTime]];
                [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
                [scanner scanCharactersFromSet:numbers intoString:&appleExerciseTimeString];
                
                NSString *appleExerciseTimeGoalString;
                scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"%@", summary.appleExerciseTimeGoal]];
                [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
                [scanner scanCharactersFromSet:numbers intoString:&appleExerciseTimeGoalString];
                
                NSDictionary *elem = @{
                                       @"activeEnergyBurned" : activeEnergyBurnedString,
                                       @"activeEnergyBurnedGoal" : activeEnergyBurnedGoalString,
                                       @"appleStandHours" : appleStandHoursString,
                                       @"appleStandHoursGoal" : appleStandHoursGoalString,
                                       @"appleExcerciseTime" : appleExerciseTimeString,
                                       @"appleExcerciseTimeGoal" : appleExerciseTimeGoalString,
                                       };
                
                [results addObject:elem];
                NSLog(@"activity summaries: %@", summary);
            }
            callback(@[[NSNull null], results]);
        } else {
            // Handle the error here...
            NSLog(@"the was an error getting activity summaries");
            callback(@[RCTMakeError(@"error getting active energy burned samples", nil, nil)]);
            return;
        }
        // Do something with the summaries here...
        
    }];
    [self.healthStore executeQuery:query];
}

@end
