//
//  RCTAppleHealthKit+OxygenSaturation.h
//  bda4phr
//
//  Created by Fabio Cipriani on 03/09/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RCTAppleHealthKit.h"

@interface RCTAppleHealthKit (Methods_OxygenSaturation)

- (void)oxygenSaturation_getOxygenSaturation:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;

@end
