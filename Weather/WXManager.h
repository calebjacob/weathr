//
//  WXManager.h
//  Weather
//
//  Created by Caleb Jacob on 5/20/14.
//  Copyright (c) 2014 Caleb Jacob. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "WXCondition.h"

@interface WXManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedManager;

@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;
@property (nonatomic, strong, readonly) NSString *backgroundImage;

- (void)findCurrentLocation;

@end
