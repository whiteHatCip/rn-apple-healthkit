//
//  RCTAppleHealthKit+OxygenSaturation.m
//  bda4phr
//
//  Created by Fabio Cipriani on 03/09/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RCTAppleHealthKit+OxygenSaturation.h"
#import "RCTAppleHealthKit+Utils.h"
#import "RCTAppleHealthKit+Queries.h"

@implementation RCTAppleHealthKit (Methods_OxygenSaturation)

RCT_EXPORT_METHOD(getOxygenSaturationSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback)
{
  [self oxygenSaturation_getOxygenSaturation:input callback:callback];
}

- (void)oxygenSaturation_getOxygenSaturation:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback {
  NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
  NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
  if(startDate == nil){
    callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
    return;
  }
  
  HKQuantityType *oxygenSaturationType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
  HKUnit *oxygenSaturationUnit = [HKUnit percentUnit];
  NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];
  
  [self fetchQuantitySamplesOfType:oxygenSaturationType
                              unit:oxygenSaturationUnit
                         predicate:predicate
                         ascending:false
                             limit:HKObjectQueryNoLimit
                        completion:^(NSArray *results, NSError *error) {
                          if(results){
                            callback(@[[NSNull null], results]);
                            return;
                          } else {
                            NSLog(@"error getting oxygen saturation samples: %@", error);
                            callback(@[RCTMakeError(@"error getting oxygen saturation samples", nil, nil)]);
                            return;
                          }
                        }];
}

@end
