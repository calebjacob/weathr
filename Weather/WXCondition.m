//
//  WXCondition.m
//  Weather
//
//  Created by Caleb Jacob on 5/20/14.
//  Copyright (c) 2014 Caleb Jacob. All rights reserved.
//

#import "WXCondition.h"

@implementation WXCondition

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)sunriseJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str) {
        return @[str];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)iconJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

#define MPS_TO_MPH 2.23694f

+ (NSValueTransformer *)windSpeedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue*MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}

+ (NSDictionary *)imageMap {
    static NSDictionary *_imageMap = nil;
    
    if (!_imageMap) {
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    
    return _imageMap;
}

- (NSString *)imageName {
    return [WXCondition imageMap][self.icon];
}

- (UIColor *)temperatureColor {
    NSInteger temperature = self.temperature.integerValue > 0 ? self.temperature.integerValue : self.tempHigh.integerValue;
    
    if (temperature >= 95) {
        return [UIColor colorWithRed:1 green:0.392 blue:0.373 alpha:1];
    }
    
    else if (temperature >= 90) {
        return [UIColor colorWithRed:1 green:0.592 blue:0.369 alpha:1];
    }
    
    else if (temperature >= 85) {
        return [UIColor colorWithRed:1 green:0.816 blue:0.314 alpha:1];
    }
    
    else if (temperature >= 80) {
        return [UIColor colorWithRed:0.373 green:0.729 blue:0.408 alpha:1];
    }
    
    else if (temperature >= 75) {
        return [UIColor colorWithRed:0 green:0.729 blue:0.698 alpha:1];
    }
    
    else if (temperature >= 55) {
        return [UIColor colorWithRed:0.161 green:0.753 blue:0.867 alpha:1];
    }
    
    else if (temperature >= 35) {
        return [UIColor colorWithRed:0 green:0.514 blue:0.769 alpha:1];
    }
    
    else {
        return [UIColor colorWithRed:0.204 green:0.29 blue:0.565 alpha:1];
    }
}

@end
