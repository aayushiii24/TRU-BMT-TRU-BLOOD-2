//
//  AppDelegate.m
//  Pain
//
//  Created by Jude Jonassaint on 7/3/12.
//  Copyright (c) 2012 Jude Jonassaint. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "SAMKeychain.h"
//#import "BandConsent.h"
//
#import "CHCSVParser.h"
#import "AFHTTPRequestOperation.h"
#import "AFNetworking.h"
#import <CoreMotion/CoreMotion.h>




#import "CHCSVParser.h"



static NSString * const kwShareFileBaseFolder = @"Dev/SMARTa";
static NSString * const kwShareFileBaseURL = @"https://scdi.sharefile-webdav.com:443";
static NSString * const kwShareFileDataFolder = @"Data";
static NSString * const kwShareFileName = @"wearable.csv";
static NSString * const kwShareFileNameSingleRow = @"wearableSingleRow.csv";
static NSString * const kwShareFileNameSingleRowHK = @"wearableSingleRowHK.csv";

//#import "AFNetworkActivityIndicatorManager.h"
@interface AppDelegate ()


@property (nonatomic, strong) NSString *hrDataQualityString;
@property (nonatomic, strong) NSNumber *rrIntervalNumber;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@property (nonatomic, strong) NSURL *url;

@end



@implementation AppDelegate


@synthesize symptomsViewController =_symptomsViewController;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIColor *myRedColor = [UIColor colorWithRed:206.0f/255.0f
                                          green:53.0f/255.0f
                                           blue:53.0f/255.0f
                                          alpha:1.0f];
    [[UITabBar appearance] setTintColor:myRedColor];
    [[UINavigationBar appearance] setTintColor:myRedColor];
    [[UITableViewCell appearance] setTintColor:myRedColor];
    
    
    //TODO: self.hrDataQualityString = @"Unknown";
    //TODO: self.rrIntervalNumber = 0;
    //TODO: self.hrDataQualityString = @";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //SENSOR:Consent
    if ([[defaults objectForKey:@"YES"] length] < 1) {
         [defaults setObject:@"Unknown" forKey:@"gotConsent"];
    }
   
    //TODO: [defaults setObject:@"Unknown" forKey:@"heartRateDataQuality"];
    
    
    if (!self.backgroundSession) {
        self.backgroundSession = [self backgroundSession];
    }
    
    if (!self.session) {
        self.session = [self session];
    }
    
    
//    if (![defaults objectForKey:@"gotConsent"]) {
//        //NSLog(@"We do not have consent");
//    }
    
    if (![defaults objectForKey:@"participantUUID"]) {
        [defaults setObject:[[NSUUID UUID] UUIDString] forKey:@"participantUUID"];
        //NSLog(@"We do not have consent %@",[defaults objectForKey:@"participantUUID"]);
    }
    
    //TODO: [self setupBand];
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // [self requestAuthForLocationManagement];
    //Set up magical record stack
    //[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"SmartCares.sqlite"];
    
    // Fetch Main Storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    
    // Instantiate Root Navigation Controller
    UINavigationController *rootNavigationController = (UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"rootNavigationController"];
    
    // Configure Window
    [self.window setRootViewController:rootNavigationController];
    
    
    
    //LOCAL NOTIFICATION
    //NSLog(@"Current device %@ iOS version %.1f",[[UIDevice currentDevice] model], [[[UIDevice currentDevice] systemVersion] floatValue] ) ;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    
    
    UIBackgroundTaskIdentifier bgTask = UIBackgroundTaskInvalid;
    UIApplication *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
/*
    if ([CMMotionActivityManager isActivityAvailable]) {
        CMMotionActivityManager *manager = [CMMotionActivityManager new];
        [manager startActivityUpdatesToQueue:[NSOperationQueue new]
                                 withHandler:^(CMMotionActivity *activity) {
                                     if (activity.confidence  == CMMotionActivityConfidenceHigh)
                                     {
                                         NSLog(@"Quite probably a new activity.");
                                         [defaults setObject:@"New activity" forKey:@"Activity"];
                                         [self startHRSensorWithoutButton];
                                          [self setupBand];
                                         
                                         HeartRateViewController *rootViewController = [[HeartRateViewController alloc] init];
                                         //TEMP HOLD [rootViewController setupBand];
                                         
                                         
                                         //[self getWeatherDataForWearable];
                                         
                                         //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                         //NSLog(@"Connected: %@",[defaults objectForKey:@"BandConnected"]);
                                     }
                                 }];
        HeartRateViewController *rootViewController = [[HeartRateViewController alloc] init];
        //TEMP HOLD [rootViewController setupBand];
        [manager startActivityUpdatesToQueue:[NSOperationQueue new]
                                 withHandler:^(CMMotionActivity *activity) {
                                     if (activity.confidence  == CMMotionActivityConfidenceHigh){
                                         NSLog(@"Quite probably a new activity with high confidence.");
                                         [self startHRSensorWithoutButton];
                                          [self setupBand];
                                         //[self getWeatherDataForWearable];
                                         
                                         HeartRateViewController *rootViewController = [[HeartRateViewController alloc] init];
                                         //TEMP HOLD [rootViewController setupBand];
                                         
                                         NSDate *started = activity.startDate;
                                         if (activity.stationary) {
                                             [defaults setObject:@"Doing nothing" forKey:@"Activity"];
                                             NSLog(@"Sitting, doing nothing %@", started);
                                             NSLog(@"Quite probably a new sitting activity.");
                                              [self setupBand];
                                             
                                             HeartRateViewController *rootViewController = [[HeartRateViewController alloc] init];
                                             //TEMP HOLD [rootViewController setupBand];
                                             //[rootViewController reloadWKWebView];
                                             
                                         } else if (activity.running){
                                             NSLog(@"Active! Running! %@", started);
                                             NSLog(@"Quite probably a new run.");
                                             [defaults setObject:@"Running" forKey:@"Activity"];
                                              [self setupBand];
                                             HeartRateViewController *rootViewController = [[HeartRateViewController alloc] init];
                                             //TEMP HOLD [rootViewController setupBand];
                                             //[rootViewController reloadWKWebView];
                                         } else if (activity.automotive){
                                              [self setupBand];
                                             NSLog(@"Driving along! %@", started);
                                             [defaults setObject:@"Driving" forKey:@"Activity"];
                                             HeartRateViewController *rootViewController = [[HeartRateViewController alloc] init];
                                             //TEMP HOLD [rootViewController setupBand];
                                             //[rootViewController reloadWKWebView];
                                         } else if (activity.walking){
                                              [self setupBand];
                                             [defaults setObject:@"Walking" forKey:@"Activity"];
                                             NSLog(@"Strolling round the city..%@", started);
                                             NSLog(@"Quite probably a walk.");
                                             HeartRateViewController *rootViewController = [[HeartRateViewController alloc] init];
                                             //TEMP HOLD [rootViewController setupBand];
                                             //[rootViewController reloadWKWebView];
                                         }
                                     }
                                 }];
        
        [manager queryActivityStartingFromDate:[NSDate dateWithTimeIntervalSinceNow:-60*2]
                                        toDate:[NSDate new]
                                       toQueue:[NSOperationQueue new]
                                   withHandler:^(NSArray *activities, NSError *error) {
                                       // time to work with data.
                                        [self setupBand];
                                       NSLog(@"Activities in last 2 minutes %@", activities);
                                       HeartRateViewController *rootViewController = [[HeartRateViewController alloc] init];
                                       //TEMP HOLD [rootViewController setupBand];;
                                       //[rootViewController reloadWKWebView];
                                       
                                   }];
    }

    
    
 
//    [self getWeatherDataForWearable];
    //[[BandConsent sharedConsent] connectToBandWithActivity:@"Unkown"];
    //[self getWeatherDataForWearable];
 
 */
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BOOL flag = NO;
    
    return flag;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
//    if ([_client.sensorManager heartRateUserConsent] == MSBUserConsentGranted) {
//        //[[BandConsent sharedConsent] getHeartRateSensorData];
//        //[[BandConsent sharedConsent] getRRSensorData];
//        //[defaults setObject:@"NO" forKey:@"RequestedUserConsent"];
//        
//    }
//    else {
//        //[[BandConsent sharedConsent] firstRequestForHeartRateSensorData];
//    }
    //[self setupBand];
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
//    if ([_client.sensorManager heartRateUserConsent] == MSBUserConsentGranted) {
//        [[BandConsent sharedConsent] getHeartRateSensorData];
//        [[BandConsent sharedConsent] getRRSensorData];
//        //[defaults setObject:@"NO" forKey:@"RequestedUserConsent"];
//        
//    }
//    else {
//        [[BandConsent sharedConsent] firstRequestForHeartRateSensorData];
//    }
    //[self setupBand];
}


- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //NSLog(@"describe userInfoDictionary from push %@", userInfo);
    NSLog(@"application didReceiveRemoteNotification");
    NSString *remoteMessage = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"something remote was sent");
        
    }
    else if  ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //NSLog(@"else, while active, something remote was sent");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Urgent"
                                                        message:remoteMessage
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
        
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //NSLog(@"Did Fail to Register for Remote Notifications");
    //NSLog(@"%@, %@", error, error.localizedDescription);
    
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    UIApplicationState state = [application applicationState];
//    if (state == UIApplicationStateActive) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SMART Reminder"
//                                                        message:notification.alertBody
//                                                       delegate:self cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }
    // Set icon badge number to zero
    
    application.applicationIconBadgeNumber = 0;
}



- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler {
    self.backgroundSessionCompletionHandler = completionHandler;
    //[self webData];
    //add notification
    //[self presentNotification];
    //[[BandConsent sharedConsent] connectToBandWithActivity:@"Unknown"];
}
//-(void) webData  {
    
 /*   NSString *username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
    //auth
    NSString *password = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:username];
    
    AFWebDAVManager *webDAVManager = [[AFWebDAVManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://scdi.sharefile-webdav.com"]];
    webDAVManager.credential = [NSURLCredential credentialWithUser:username
                                                          password:password
                                                       persistence:NSURLCredentialPersistenceForSession];
    //    NSString *url = [NSString stringWithFormat:@"/Dev/ITP/%@/Lessons/NewDir9",self.username];
    //    NSString *originURLString = [self getMovieURL];
    
    
    
    //
    
    //Works to copy from URL to URL but origin and destination needs to be of the same base URL.
    //On sharefile side the destination folder should not allow revisions or else the copied file and all its revision will be copied
    //If revision is not allowed on the destination folder then only the most current revision from the the origin folder is copied
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMddyyyy";
    NSString *fileDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"File date: %@", fileDate);
    NSString *originURLString = [NSString stringWithFormat:@"/Dev/SMARTa/%@/Data/media.mp4",username];
    NSString *destinationURLString = [NSString stringWithFormat:@"/Dev/SMARTa/%@/Data/MediaData/%@.mp4",username,fileDate];
    [webDAVManager copyItemAtURLString:originURLString toURLString:destinationURLString overwrite:YES completionHandler:^(NSURL *fileURL, NSError *error)
     {
         if (error) {
             NSLog(@"[Error] %@", error);
             
         } else {
             //NSLog(@"File uploaded successfully");
             //[self.responseLabel setText:[NSString stringWithFormat:@"file copied: %@", fileURL]];
             //TODO ask to delete the file
             [self presentNotification];
             }
     }];
 */   
//}


-(void)presentNotification {
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
//    localNotification.alertBody = @"data transmission completed successfully";
//    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//    //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void) requestAuthForLocationManagement {
    self.locationManager = [CLLocationManager new];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager setDistanceFilter:kCLLocationAccuracyBestForNavigation];
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 20; // meters
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager startUpdatingLocation];
    _locationManager.delegate = self;
    //NSLog(@"request location capablity");
    [self getCurrentLocation];
    
}
- (void)getCurrentLocation {
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [_locationManager startUpdatingLocation];
    
}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    // regions are stored by system
    NSLog(@"regions%@, %@, %@ for user location", [self.locationManager monitoredRegions], _userLocationLatitude,_userLocationLongitude);
    //start
    
    
}

//MARK: Manage Location

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //    [errorAlert show];
    //NSLog(@"Error: %@",error.description);
}


- (void)startSignificantChangeUpdates
{
    NSLog(@"performed location significant changes check");
    // Create the location manager
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    _userLocationLatitude = [NSString  stringWithFormat:@"%.8f",location.coordinate.latitude];
    _userLocationLongitude = [NSString  stringWithFormat:@"%.8f",location.coordinate.longitude];
    
    if (abs(howRecent) < 15.0) {
        _userLocationLatitude = [NSString  stringWithFormat:@"%.8f",location.coordinate.latitude];
        _userLocationLongitude = [NSString  stringWithFormat:@"%.8f",location.coordinate.longitude];
        
    }
    
    NSString *latitudeText = _userLocationLatitude;
    NSString *longitudeText = _userLocationLongitude;
    NSString *altitudeText = [NSString stringWithFormat:@"%.0f m",location.altitude];
    NSString *speedText = [NSString stringWithFormat:@"%.1f m/s", location.speed];
    
    NSString *log= [NSString stringWithFormat:@"Locations appdelegate: %@, %@, %@, %@", latitudeText,longitudeText, altitudeText, speedText];
    NSLog(@"%@", log);
    //NSLog(@"performed location recent check");
    //this method is called once background check is performed
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"perform fetch with completion handler");

    
    //HeartRateViewController *rootViewController = [[HeartRateViewController alloc] init];
    //TEMP HOLD [rootViewController setupBand];
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; //[[NSUserDefaults alloc] init];
    ;
    if (![defaults objectForKey:@"currentWeather"]) {
        [defaults setObject:@"-999" forKey:@"currentWeather"];
        
    }
    
    //NSLog(@"Current weather %@",[defaults objectForKey:@"currentWeather"]);
    
   
    //start
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLLocationAccuracyBestForNavigation];
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 20; // meters
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [_locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    _locationManager.delegate = self;
    [self getCurrentLocation];
    
    NSString *currentLocationURLString = [NSString stringWithFormat:@"https://api.forecast.io/forecast/1b6778758dc77c7ac727e17286b546ed/%@,%@",_userLocationLatitude, _userLocationLongitude];
    //NSLog(@"currentLocation string %@", currentLocationURLString);
    NSURL *globalurl = [NSURL URLWithString:currentLocationURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:globalurl];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        //NSLog(@"App.net Global Stream: %@", JSON);
        NSDictionary *JSON = (NSDictionary *)responseObject;
        //[JSON objectForKey:@"weatherDesc"];
        //NSLog(@"describe the array of weather description %@", JSON);
        //NSLog(@"weather summary: %@, icon: %@, and at the next hour: %@", [[JSON valueForKeyPath:@"currently"] objectForKey:@"summary"],
              
              
//        [[JSON valueForKeyPath:@"currently"] objectForKey:@"icon"],
//        [[[[JSON valueForKeyPath:@"hourly"] objectForKey:@"data"] objectAtIndex:3] objectForKey:@"time"]);
        // append the weather data to the altitude variable
        NSString *myAltitude = @" ";
        
        float temperature = [[[JSON valueForKeyPath:@"currently"] objectForKey:@"temperature"] floatValue];
        NSString * currentTemperature = [NSString stringWithFormat:@"%.f", temperature];
        
        float t = [[[JSON valueForKeyPath:@"currently"] objectForKey:@"apparentTemperature"] floatValue];
        NSString * apparentTemperature = [NSString stringWithFormat:@"%.f", t];
        
        float c = [[[JSON valueForKeyPath:@"currently"] objectForKey:@"cloudCover"] floatValue]*100;
        NSString * cloudCover = [NSString stringWithFormat:@"%.f%%", c];
        
        float h = [[[JSON valueForKeyPath:@"currently"] objectForKey:@"humidity"] floatValue]*100;
        NSString * humidity = [NSString stringWithFormat:@"%.f%%", h];
        
        float p = [[[JSON valueForKeyPath:@"currently"] objectForKey:@"pressure"] floatValue];
        NSString * pressure =[NSString stringWithFormat:@"%.f", p];
        
        float o = [[[JSON valueForKeyPath:@"currently"] objectForKey:@"ozone"] floatValue];
        NSString * ozone = [NSString  stringWithFormat:@"%.f", o];
        
        float ws = [[[JSON valueForKeyPath:@"currently"] objectForKey:@"windSpeed"] floatValue];
        NSString * windspeed = [NSString stringWithFormat:@"%.f mph", ws];
        
        myAltitude = [myAltitude stringByAppendingFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %.f",
                      [[JSON valueForKeyPath:@"currently"] objectForKey:@"summary"],
                      currentTemperature,
                      apparentTemperature,
                      cloudCover,
                      humidity,
                      pressure,
                      ozone,
                      windspeed, _locationManager.location.altitude];
        
        [_dataDictionary setObject:myAltitude forKey:@"myAltitude"];
        //NSLog(@"dataDictionary in treatmentsViewController %@",_dataDictionary);
        //NSLog(@"Weather Report in treatmentsViewController %@, in dataDictionary %@",myAltitude, _dataDictionary);
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        [defaults setObject:myAltitude forKey:@"currentWeather"];
        [defaults synchronize];
        
        //[[UIApplication sharedApplication] cancelAllLocalNotifications];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        NSDate *now = [NSDate date];
        localNotification.fireDate = now;
        localNotification.alertBody = [NSString stringWithFormat:@"%@.", myAltitude];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        //[[BandConsent sharedConsent] connectToBandWithActivity:[defaults objectForKey:@"gettingWeather"]];
        //[self sendNotification:@"gettingWeather"];
        NSLog(@"Fetch completed myAltitude %@", myAltitude);
        
    }
     
     
    failure:nil];
    [operation start];
    
    //[self sendNotification:@"fetchWeather"];
   // [[BandConsent sharedConsent] connectToBandWithActivity:[defaults objectForKey:@"fetchWeather"]];
    completionHandler(UIBackgroundFetchResultNoData);
    NSLog(@"Fetch completed myAltitude %@", [defaults objectForKey:@"currentWeather"]);
    
   
    //[self sendNotification:@"weatherNewData"];
    
    NSLog(@"Fetch completed");
}

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    //This method has not been called
    
    NSLog(@"fetch new data with completion handler");
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    [defaults setObject:@"BackgroundUpload-Activity unknown" forKey:@"Activity"];
     //[self sendNotification:@"fetchNewDataWithCompletionHandler"];
    
    //NSLog(@"Current weather %@",[defaults objectForKey:@"currentWeather"]);
    /*
    if ([[defaults objectForKey:@"currentWeather"] isEqualToString:@"-999"]) {
        completionHandler(UIBackgroundFetchResultNoData);
        [defaults setObject:@"BackgroundUpload No Data" forKey:@"currentWeather"];
        //[[BandConsent sharedConsent] connectToBandWithActivity:[defaults objectForKey:@"currentWeather"]];
        //NSLog(@"No new data found.");
    }
    if ([[defaults objectForKey:@"currentWeather"] isEqualToString:@"-99"]) {
        completionHandler(UIBackgroundFetchResultFailed);
        [defaults setObject:@"BackgroundUpload Failed Data" forKey:@"currentWeather"];
        //[[BandConsent sharedConsent] connectToBandWithActivity:[defaults objectForKey:@"currentWeather"]];
        //NSLog(@"Failed to fetch new data.");
        
    }
    
    else{
        completionHandler(UIBackgroundFetchResultNewData);
        [defaults setObject:@"BackgroundUpload New Data" forKey:@"currentWeather"];
        //[[BandConsent sharedConsent] connectToBandWithActivity:[defaults objectForKey:@"currentWeather"]];
        //NSLog(@"fetch got new data.");
    }
     */
    completionHandler(UIBackgroundFetchResultNewData);
    
    //[[BandConsent sharedConsent] connectToBandWithActivity:[defaults objectForKey:@"currentWeather"]];
    
}

- (NSURLSession *)backgroundSession {
    static NSURLSession *backgroundSession = nil;
    
//    NSString *username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
//    //auth
//    NSString *password = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:username];
    
    NSString *username = @"trupain000@me.com";
    NSString *password = @"Trupain000";
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
    ////NSLog(@"user pass: %@,%@",_username,password);
    //
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    
    // Session Configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.sicklesoft.ITP.BackgroundSession.Wearable"];
    
    //set additional header for auth
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Authorization": authValue}];
    sessionConfiguration.sessionSendsLaunchEvents = YES;
    sessionConfiguration.allowsCellularAccess = YES;
    // Initialize Session
    backgroundSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    return backgroundSession;
}
- (NSURLSession *)session {
    static NSURLSession *session = nil;
//    NSString *username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
//    username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
//    //auth
//    NSString *password = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:username];
    NSString *username = @"trupain000@me.com";
    NSString *password = @"Trupain000";
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
    //
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    
    // Session Configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //set additional header for auth
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Authorization": authValue}];
    sessionConfiguration.sessionSendsLaunchEvents = YES;
    sessionConfiguration.allowsCellularAccess = YES;
    
    // Initialize Session
    session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    return session;
}
//an upload in background session mode
-(void) uploadInBackground:(NSURL *)filePath fileName:(NSString *)fileName {
    NSString *username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", kwShareFileBaseURL, kwShareFileBaseFolder,@"trupain000@icloud.com",kwShareFileDataFolder,fileName];
    NSURL *URL = [NSURL URLWithString:urlString];
    //NSLog(@"uploadInBackground to URL: %@ from filepath %@", urlString, filePath);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    

    self.uploadTask = [_backgroundSession uploadTaskWithRequest:request fromFile:filePath];
    [self.uploadTask resume];
}

-(void) upload:(NSURL *)filePath fileName:(NSString *)fileName {
    //NSLog(@"fileName %@ to be uploaded",fileName);
    NSString *username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", kwShareFileBaseURL, kwShareFileBaseFolder,@"trupain000@icloud.com",kwShareFileDataFolder,fileName];
    NSURL *URL = [NSURL URLWithString:urlString];
    //NSLog(@"upload csv to URL from: %@ from filepath %@", URL, filePath);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    NSURLSessionUploadTask *uploadTask  = [_session uploadTaskWithRequest:request fromFile:filePath completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error==nil) {
            //NSLog(@"Yeah, file %@ uploaded to URL:%@", URL, fileName);
            // Invalidate Session
            //[_session finishTasksAndInvalidate];
        } else {
            //NSLog(@"response from server: %@", response);
            [self uploadInBackground:filePath fileName:fileName];
        }
    }];
    
    [uploadTask resume];
    
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    //NSLog(@"session did receive challenge");
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    //NSLog(@"All tasks are finished");
    //[self connectToBandWithActivity:@"Unkown"];
    
    
}
- (void)invokeBackgroundSessionCompletionHandler {
    [_backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
        //NSLog(@"pre lastCount %ld", (long)count);
        if (!count) {
            AppDelegate *applicationDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            void (^backgroundSessionCompletionHandler)() = [applicationDelegate backgroundSessionCompletionHandler];
            
            if (backgroundSessionCompletionHandler) {
                //NSLog(@"LASTcount post %ld", (long)count);
                [applicationDelegate setBackgroundSessionCompletionHandler:nil];
                backgroundSessionCompletionHandler();
            }
        }
    }];
}
//delegate method for UPLOAD TASK
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    //NSLog(@"bytes sent %lld", bytesSent);
    //NSLog(@"expected bytes %lld", totalBytesExpectedToSend);
    //NSLog(@"total bytes sent %lld", totalBytesSent);
    //[self performSelectorInBackground:@selector(getSensorData) withObject:nil]; //this would get called if not commented out
    [self invokeBackgroundSessionCompletionHandler]; //in appDelegate
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    
}

@end
