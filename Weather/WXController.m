//
//  WXController.m
//  Weather
//
//  Created by Caleb Jacob on 5/20/14.
//  Copyright (c) 2014 Caleb Jacob. All rights reserved.
//

#import "WXController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WXManager.h"
#import "UIImage+AverageColor.h"
#import "UIImage+darkenWithColor.h"

@interface WXController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@end

@implementation WXController

- (id)init {
    if (self = [super init]) {
        self.hourlyFormatter = [[NSDateFormatter alloc] init];
        self.hourlyFormatter.dateFormat = @"h a";
        
        self.dailyFormatter = [[NSDateFormatter alloc] init];
        self.dailyFormatter.dateFormat = @"EEEE";
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;

    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.layer.opacity = 0;
    [self.view addSubview:self.backgroundImageView];

    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.view addSubview:self.blurredImageView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    
    
    CGAffineTransform scaleZero = CGAffineTransformMakeScale(0, 0);
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20;
    CGFloat circleSize = 200;
    CGFloat temperatureHeight = 60;
    CGFloat hiLoTemperatureSize = 42;
    CGFloat conditionHeight = 30;
    
    CGRect circleFrame = CGRectMake((headerFrame.size.width - circleSize) / 2,
                                    (headerFrame.size.height - circleSize) / 2,
                                    circleSize,
                                    circleSize);
    
    CGRect temperatureFrame = CGRectMake(0,
                                         (circleFrame.size.height - temperatureHeight) / 2,
                                         circleSize,
                                         temperatureHeight);
    
    CGRect conditionsFrame = CGRectMake(0,
                                        temperatureFrame.origin.y - conditionHeight - 15,
                                        circleSize,
                                        conditionHeight);
    
    CGRect hiFrame = CGRectMake(hiLoTemperatureSize / 4,
                                circleSize - hiLoTemperatureSize - (hiLoTemperatureSize / 4),
                                hiLoTemperatureSize,
                                hiLoTemperatureSize);
    
    CGRect loFrame = hiFrame;
    loFrame.origin.x = circleSize - hiLoTemperatureSize - (hiLoTemperatureSize / 4);
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    self.circleView = [[UIView alloc] initWithFrame:circleFrame];
    self.circleView.layer.cornerRadius = circleSize / 2;
    self.circleView.transform = scaleZero;
    [header addSubview:self.circleView];
    
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:76];
    temperatureLabel.textAlignment = NSTextAlignmentCenter;
    [self.circleView addSubview:temperatureLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.textColor = [UIColor whiteColor];
    conditionsLabel.text = @"";
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textAlignment = NSTextAlignmentCenter;
    [self.circleView addSubview:conditionsLabel];
    
    UILabel *hiLabel = [[UILabel alloc] initWithFrame:hiFrame];
    hiLabel.backgroundColor = [UIColor whiteColor];
    hiLabel.textColor = [UIColor colorWithRed:1 green:0.384 blue:0.357 alpha:1];
    hiLabel.text = @"0°";
    hiLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    hiLabel.textAlignment = NSTextAlignmentCenter;
    hiLabel.layer.cornerRadius = hiLoTemperatureSize / 2;
    hiLabel.layer.masksToBounds = YES;
    hiLabel.transform = scaleZero;
    [self.circleView addSubview:hiLabel];
    
    UILabel *loLabel = [[UILabel alloc] initWithFrame:loFrame];
    loLabel.layer.cornerRadius = hiLoTemperatureSize / 2;
    loLabel.backgroundColor = [UIColor whiteColor];
    loLabel.textColor = [UIColor colorWithRed:0.051 green:0.38 blue:0.682 alpha:1];
    loLabel.text = @"0°";
    loLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    loLabel.textAlignment = NSTextAlignmentCenter;
    loLabel.layer.cornerRadius = hiLoTemperatureSize / 2;
    loLabel.layer.masksToBounds = YES;
    loLabel.transform = scaleZero;
    [self.circleView addSubview:loLabel];
    
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, inset, headerFrame.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    [[WXManager sharedManager] findCurrentLocation];
    
    [[RACObserve([WXManager sharedManager], currentCondition) deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(WXCondition *newCondition) {
        if (newCondition) {
            UIColor *backgroundColor = [[newCondition temperatureColor] colorWithAlphaComponent:0.5];
            
            self.circleView.backgroundColor = backgroundColor;
            temperatureLabel.text = [NSString stringWithFormat:@"%.0f°", newCondition.temperature.floatValue];
            conditionsLabel.text = [newCondition.condition capitalizedString];
            cityLabel.text = [newCondition.locationName capitalizedString];
            
            [UIView animateWithDuration:0.4
                                  delay:0
                 usingSpringWithDamping:0.7
                  initialSpringVelocity:0.2
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 CGAffineTransform scaleTrans = CGAffineTransformMakeScale(1, 1);
                                 self.circleView.transform = scaleTrans;
                             }
                             completion:nil];
            
            [UIView animateWithDuration:0.6
                                  delay:0.2
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:0.1
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 CGAffineTransform scaleTrans = CGAffineTransformMakeScale(1, 1);
                                 hiLabel.transform = scaleTrans;
                                 loLabel.transform = scaleTrans;
                             }
                             completion:nil];
        }
    }];
    
    [[RACObserve([WXManager sharedManager], hourlyForecast) deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(NSArray *newForecast) {
        [self.tableView reloadData];
    }];
    
    [[RACObserve([WXManager sharedManager], dailyForecast) deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(NSArray *newForecast) {
        [self.tableView reloadData];
    }];
    
    [[RACObserve([WXManager sharedManager], backgroundImage) deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(NSString *imageURLString) {
        if (imageURLString) {
            NSURL *url = [NSURL URLWithString:imageURLString];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            self.backgroundImageView.image = [image darkenWithColor:[[[WXManager sharedManager] currentCondition] temperatureColor]];
            
            [self.blurredImageView setImageToBlur:image blurRadius:10 completionBlock:nil];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.backgroundImageView.layer.opacity = 1;
            }];
        }
    }];
    
    RAC(hiLabel, text) = [[RACSignal combineLatest:@[RACObserve([WXManager sharedManager], currentCondition.tempHigh)]
                                             reduce:^(NSNumber *high) {
                                                 return [NSString stringWithFormat:@"%.0f°", high.floatValue];
                                             }] deliverOn:RACScheduler.mainThreadScheduler];
    
    RAC(loLabel, text) = [[RACSignal combineLatest:@[RACObserve([WXManager sharedManager], currentCondition.tempLow)]
                                            reduce:^(NSNumber *low) {
                                                return [NSString stringWithFormat:@"%.0f°", low.floatValue];
                                            }] deliverOn:RACScheduler.mainThreadScheduler];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    
    return MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecasts"];
        }
        
        else {
            WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        
        else {
            WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    
    return cell;
}

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°", weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.backgroundColor = [[weather temperatureColor] colorWithAlphaComponent:0.5];
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°", weather.tempHigh.floatValue, weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.backgroundColor = [[weather temperatureColor] colorWithAlphaComponent:0.5];
}

#pragma mark - UIScorllViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    
    self.blurredImageView.alpha = percent;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
