//
//  WXClient.h
//  Weather
//
//  Created by Caleb Jacob on 5/20/14.
//  Copyright (c) 2014 Caleb Jacob. All rights reserved.
//

@import CoreLocation;
#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface WXClient : NSObject <NSXMLParserDelegate>

- (RACSignal *)fetchJSONFromURL:(NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchImageForConditions:(NSString *)conditions atLocation:(NSString *)location;

@end
