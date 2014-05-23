//
//  WXClient.m
//  Weather
//
//  Created by Caleb Jacob on 5/20/14.
//  Copyright (c) 2014 Caleb Jacob. All rights reserved.
//

#import "WXClient.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"

@interface WXClient ()

@property (nonatomic, strong) NSURLSession *session;
@property NSString *parsedContent;

@end

@implementation WXClient

- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration];
    }
    
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@", url.absoluteString);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                
                if (!jsonError) {
                    [subscriber sendNext:json];
                }
                
                else {
                    [subscriber sendError:jsonError];
                }
            }
            
            else {
                [subscriber sendError:error];
            }
            
            [subscriber sendCompleted];
        }];
        
        [dataTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        return [MTLJSONAdapter modelOfClass:[WXCondition class]
                         fromJSONDictionary:json
                                      error:nil];
    }];
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        RACSequence *list = [json[@"list"] rac_sequence];
        
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WXCondition class]
                             fromJSONDictionary:item
                                          error:nil];
        }] array];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        RACSequence *list = [json[@"list"] rac_sequence];
        
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

- (RACSignal *)fetchImageForConditions:(NSString *)conditions atLocation:(NSString *)location {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/feeds/photos_public.gne?format=xml&tags=%@,%@", conditions, location];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        parser.delegate = self;
        
        NSLog(@"Fetching: %@", url);
        
        [parser parse];
        
        [RACObserve(self, parsedContent) subscribeNext:^(NSString *image) {
            if (image) {
                NSLog(@"Background image for \"%@\" near \"%@\": %@", conditions, location, image);
                [subscriber sendNext:image];
                [subscriber sendCompleted];
            }
            
            else {
                NSLog(@"No images were found for \"%@\" near \"%@\". Attempting a more generic search without a specifc location...", conditions, location);
                
                [[[self fetchImageForConditions:conditions] deliverOn:RACScheduler.mainThreadScheduler] subscribeError:^(NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
        }];
    }] doError:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (RACSignal *)fetchImageForConditions:(NSString *)conditions {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/feeds/photos_public.gne?format=xml&tags=%@,weather", conditions];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        parser.delegate = self;
        
        [parser parse];
        
        NSLog(@"Fetching: %@", url);

        [RACObserve(self, parsedContent) subscribeNext:^(NSString *image) {
            NSLog(@"Background image for \"%@\": %@", conditions, image);
            [subscriber sendNext:image];
            [subscriber sendCompleted];
        }];

        return [RACDisposable disposableWithBlock:^{
        }];
    }] doError:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - NSXMLParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"link"]
        && [[attributeDict objectForKey:@"type"] isEqualToString:@"image/jpeg"]) {
        self.parsedContent = [attributeDict objectForKey:@"href"];
        [parser abortParsing];
    }
}

@end
