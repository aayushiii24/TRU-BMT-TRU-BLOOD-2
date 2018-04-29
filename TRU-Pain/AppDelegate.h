//
//  AppDelegate.h
//  Pain
//
//  Created by Jude Jonassaint on 7/3/12.
//  Copyright (c) 2012 Jude Jonassaint. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>
#import <CoreLocation/CoreLocation.h>



//#import "SMARTp-swift.h"
//#import <HealthKit/HealthKit.h>



@class SymptomsViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, CLLocationManagerDelegate,NSURLSessionDataDelegate,NSURLSessionDelegate,  NSURLSessionDataDelegate>

@property (copy, nonatomic) void (^backgroundSessionCompletionHandler)();
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SymptomsViewController *symptomsViewController;
@property (nonatomic, strong) NSMutableArray *cares;


@property (nonatomic,strong) NSString * userLocationLatitude;
@property (nonatomic,strong) NSString * userLocationLongitude;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableDictionary *dataDictionary;



extern NSString *kLocalNotificationDataKey;
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
//-(void)getWeatherDataForWearable;
@end
