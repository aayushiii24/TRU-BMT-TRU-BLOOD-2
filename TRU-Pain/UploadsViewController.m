//
//  UploadsViewController.m
//  TRU-BMT
//
//  Created by Jude on 4/21/19.
//  Copyright © 2019 scdi. All rights reserved.
//

#import "UploadsViewController.h"
#import <HealthKit/HealthKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "CHCSVParser.h"
#import "SAMKeychain.h"


static NSString * const kwShareFileBaseStream = @"Stream/wearableData.csv";
static NSString * const kwShareFileBaseFolder = @"Dev/SMARTa";
static NSString * const kwShareFileBaseURL = @"https://scdi.sharefile-webdav.com:443";
static NSString * const kwShareFileDataFolder = @"Data";
static NSString * const kwShareFileName = @"wearable.csv";
static NSString * const kwShareFileNameDaily = @"dailyWearable.csv";
static NSString * const kwShareFileNameDailyStepCount = @"stepCountWearable.csv";
static NSString * const kwShareFileNameDailyActivity = @"activitySummary.csv";
static NSString * const kwShareFileNameDailySleepAnalysis = @"sleepAnalysis.csv";

@interface UploadsViewController ()
//@property (weak, nonatomic) IBOutlet UILabel *selectedDate;
//@property (weak, nonatomic) IBOutlet UIDatePicker *myDatePicker;
//@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
//@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) HKHealthStore *healthstore;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@property (strong, nonatomic) NSURLSessionUploadTask *uploadTaskInBackground;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDate *datePickerDate;

@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;
@end

@implementation UploadsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void) getHKHeartRateData:(NSDate *)pickerDate {
    
    self.healthstore = [[HKHealthStore alloc] init];
    
    
    // the interval of the samples to delete (i observed that for a specific value if start and end date are equal the query doesn't return any objects)
    //    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSDate* sourceDate = [calendar startOfDayForDate:pickerDate];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* selectedStartDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSLog(@"Yesterday destination date: %@", selectedStartDate);
    
    //    NSDate *startDate = selectedStartDate;
    //    NSDate *endDate = [selectedStartDate dateByAddingTimeInterval:60*60*24-1];
    
    // the interval of the samples to delete (i observed that for a specific value if start and end date are equal the query doesn't return any objects)
    NSDate *now = [NSDate date];
    int daysToAdd = -1;
    // set up date components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daysToAdd];
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] ;
    NSDate *yesterday = [gregorian dateByAddingComponents:components toDate:now options:0];
    //NSLog(@"Yesterday: %@", yesterday);
    
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *newComponents = [gregorianCalendar components:NSCalendarUnitDay
                                                           fromDate:selectedStartDate
                                                             toDate:now
                                                            options:0];
    
    long  numbeOfDays = [newComponents day];
    //NSLog(@"%ld", [newComponents day]);
    
    //    NSDate *dateOfSampleToDelete = [NSDate date];
    NSDate *startDate = [yesterday dateByAddingTimeInterval:-60*60*24*numbeOfDays];
    NSDate *endDate = [yesterday dateByAddingTimeInterval:60*60*24];
    
    NSLog(@"StartDate %@ -- %@  Pulse endDate", startDate, endDate);
    //****************** Use a function here with start date and enddate for form a query **************//
    
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    // the predicate used to execute the query
    NSPredicate *queryPredicate = [HKSampleQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    // prepare the query //change HKObjectQueryNoLimit to 1000
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:heartRateType predicate:queryPredicate limit:45000 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (error) {
            
            NSLog(@"Error: %@", error.description);
            
        } else {
            
            NSLog(@"Metadata %@", [[results firstObject] metadata]);
            // NSLog(@"Successfully retrieved samples %@ and count %lu",[[[results firstObject] metadata] objectForKey:@"HKDeviceName"], results.count);
            NSMutableArray * archive = [[NSMutableArray alloc] initWithCapacity:1] ; //we will store each array in the archive mutable array
            if (results.count > 0) {
                //   NSLog(@"if (results.count > 0) -- >>>> %lu", results.count);
                //                self.progressView.progress = 0.0;
                //                [self.activityIndicator setHidden:YES];
                for (HKQuantitySample *sample in results) {
                    double heartRate = [sample.quantity doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    NSString *heartRateString = [NSString stringWithFormat:@"%.f",heartRate];
                    //[arrayHeartRate addObject:[NSNumber numberWithDouble:hbpm]];
                    NSLog(@"Successfully got heart rate %f", heartRate);
                    NSLog(@"heart rate sample metadata \n %@", sample);
                    
                    //                    NSString *HKDevicePropertyKeyFirmwareVersion = HKDevicePropertyKeyFirmwareVersion;
                    NSLog(@"ambientTemp_C: %@,%@, %0.f ,%@, %@, %@, %@, %@", [sample.metadata objectForKey:@"ambientTemp_C"], sample.startDate,heartRate, sample.UUID.UUIDString, [sample.metadata objectForKey:@"HKDeviceName"],[sample.metadata objectForKey:@"deviceConnection"], [sample.metadata objectForKey:@"RRIntervalData"], [sample.metadata objectForKey:@"bandDistanceToday_km"]);
                    
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
                    NSString * sampleStartDateString = [dateFormatter stringFromDate:sample.startDate];
                    
                    //        NSString * deviceName = ([sample.metadata objectForKey:@"HKDeviceName"] ? [sample.metadata objectForKey:@"HKDeviceName"]: @"-99");
                    NSString * deviceName = ([[UIDevice currentDevice] name] ? [[UIDevice currentDevice] name]: @"-99");
                    NSString * userName = ([self userName] ? [self userName]: @"-99");
                    NSString * sampleSource = (sample.sourceRevision.source.name ? sample.sourceRevision.source.name: @"-99");
                    NSString *sampleRevisionSourceDescription = (sample.sourceRevision.source.description ? sample.sourceRevision.source.description: @"-99");
                    NSString *sampleDeviceName = (sample.device.name ? sample.device.name: @"-99");
                    NSString *sampleDeviceHardwareVersion = (sample.device.hardwareVersion ? sample.device.hardwareVersion: @"-99");
                    NSString *sampleDeviceModel = (sample.device.model ? sample.device.model: @"-99");
                    NSString *sampleUUID = (sample.UUID.UUIDString ? sample.UUID.UUIDString: @"-99");
                    
                    NSCharacterSet *charactersToRemove =
                    [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                    
                    NSString *trimmedReplacementDevicename =
                    [[deviceName componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *trimmedReplacementUserName =
                    [[userName componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *trimmedReplacementSampleSource =
                    [[sampleSource componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *sampleSourceRevisionDescription =
                    [[sampleRevisionSourceDescription componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSLog(@" clean name %@, ugly name %@",trimmedReplacementDevicename, deviceName);
                    NSLog(@" clean name %@, ugly name %@",trimmedReplacementUserName, userName);
                    
                    NSArray *ar = @[trimmedReplacementDevicename,
                                    trimmedReplacementUserName,
                                    sampleStartDateString,
                                    trimmedReplacementSampleSource,
                                    heartRateString,
                                    sampleDeviceName,
                                    sampleDeviceHardwareVersion,
                                    sampleDeviceModel,
                                    sampleUUID,
                                    sampleSourceRevisionDescription
                                    //
                    ];
                    [archive addObject:ar];
                    
                }
                
                NSArray *arHeader = @[@"deviceName",
                                      @"user",
                                      @"sampleStartDate",
                                      @"sampleSource",
                                      @"heartRate",
                                      @"sampleDeviceName",
                                      @"sampleDeviceHardwareVersion",
                                      @"sampleDeviceModel",
                                      @"sampleUUID",
                                      @"sampleSourceRevisionDescription"
                                      ];
                
                //"Weather: Partly Cloudy, temp 94 \U1d52F, feels like 104 \U1d52F, cloud 25%, humidity 50%, pressure 1015, ozone 291, wind speed 2 mph, and altitude 105 m"
                
                [archive insertObject:arHeader atIndex:0];
                self.session = [self session];
                NSArray *archiveArray = [archive copy];
                if (archiveArray.count >0) {
                    
                    NSFileManager *fileManager = [[NSFileManager alloc]     init];
                    NSString *tempDocumentDirectory= NSTemporaryDirectory();
                    NSString *filePath = [tempDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"heartRate-row-%d.csv",arc4random() % 1000]];
                    
                    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
                    CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
                    
                    for (NSArray *line in archiveArray) {
                        [writer writeLineOfFields:line];
                        if (line) {
                            NSLog(@"CSV line %@", line.description);
                            NSLog(@"CSV line description!");
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [self.progressView setHidden:YES];
//                                [self.activityIndicator setHidden:NO];
//                                [self.activityIndicator startAnimating];
//                            });
                        }
                    }
                    NSLog(@"ArchiveArray: %@", archiveArray);
                    
                    [writer closeStream];
                    
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    
                    if (filePath != nil){
                        self.url = [NSURL fileURLWithPath:filePath];
                        //            NSDictionary *fileAttributes = @{
                        //                                             NSFileProtectionKey : NSFileProtectionComplete
                        //                                             };
                        BOOL wrote = [fileManager createFileAtPath:filePath
                                                          contents:data
                                                        attributes:nil];
                        if (wrote){
                            
                            if (_url){
                                NSLog(@"upload from HERE   url path  %@", _url);
                                 [self doUploadCSVWithName:_url fileName:@"heartRate.csv"];
                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    [self.progressView setHidden:NO];
//                                    [self.progressView setProgress:0.0];
                                   
                                    //[self getHKDataRestingHeartRate:startDate endDate:endDate];
                                    //[self getHKDataWalkingHeartRateAverage:startDate endDate:endDate];
                                    //[self getHKDataHeartRateVariability:startDate endDate:endDate];
                                    
                                });
                                //This is use to upload data fro specific dates
                                // [self upload:_url fileName:kwShareFileNameDaily];
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
            } //if (archiveArray.count >0) {
        } //else
    }]; //HKSampleQuery *quer
    
    // TODO: execute the query
    
    [self.healthstore executeQuery:query];
}


-(void) getHKHeartRateVariabilityData:(NSDate *)pickerDate {
    
    self.healthstore = [[HKHealthStore alloc] init];
    
    
    // the interval of the samples to delete (i observed that for a specific value if start and end date are equal the query doesn't return any objects)
    //    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSDate* sourceDate = [calendar startOfDayForDate:pickerDate];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* selectedStartDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSLog(@"Yesterday destination date: %@", selectedStartDate);
    
    //    NSDate *startDate = selectedStartDate;
    //    NSDate *endDate = [selectedStartDate dateByAddingTimeInterval:60*60*24-1];
    
    // the interval of the samples to delete (i observed that for a specific value if start and end date are equal the query doesn't return any objects)
    NSDate *now = [NSDate date];
    int daysToAdd = -1;
    // set up date components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daysToAdd];
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] ;
    NSDate *yesterday = [gregorian dateByAddingComponents:components toDate:now options:0];
    //NSLog(@"Yesterday: %@", yesterday);
    
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *newComponents = [gregorianCalendar components:NSCalendarUnitDay
                                                           fromDate:selectedStartDate
                                                             toDate:now
                                                            options:0];
    
    long  numbeOfDays = [newComponents day];
    //NSLog(@"%ld", [newComponents day]);
    
    //    NSDate *dateOfSampleToDelete = [NSDate date];
    NSDate *startDate = [yesterday dateByAddingTimeInterval:-60*60*24*numbeOfDays];
    NSDate *endDate = [yesterday dateByAddingTimeInterval:60*60*24];
    
    NSLog(@"StartDate %@ -- %@  Pulse endDate", startDate, endDate);
    //****************** Use a function here with start date and enddate for form a query **************//
    
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRateVariabilitySDNN];
    
    // the predicate used to execute the query
    NSPredicate *queryPredicate = [HKSampleQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    // prepare the query //change HKObjectQueryNoLimit to 1000
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:heartRateType predicate:queryPredicate limit:45000 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (error) {
            
            NSLog(@"Error: %@", error.description);
            
        } else {
            
            NSLog(@"Metadata %@", [[results firstObject] metadata]);
            // NSLog(@"Successfully retrieved samples %@ and count %lu",[[[results firstObject] metadata] objectForKey:@"HKDeviceName"], results.count);
            NSMutableArray * archive = [[NSMutableArray alloc] initWithCapacity:1] ; //we will store each array in the archive mutable array
            if (results.count > 0) {
                //   NSLog(@"if (results.count > 0) -- >>>> %lu", results.count);
                //                self.progressView.progress = 0.0;
                //                [self.activityIndicator setHidden:YES];
                
                
                for (HKQuantitySample *sample in results) {
                    //double heartRate = [sample.quantity doubleValueForUnit:[[HKUnit secondUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    double heartRateVariability = [sample.quantity doubleValueForUnit:[HKUnit secondUnit]];
                    NSString *heartRateString = [NSString stringWithFormat:@"%.3f",heartRateVariability*1000];
                    //[arrayHeartRate addObject:[NSNumber numberWithDouble:hbpm]];
                    NSLog(@"Successfully got heart rate %f", heartRateVariability);
                    NSLog(@"heart rate sample metadata \n %@", sample);
                    
                    //                    NSString *HKDevicePropertyKeyFirmwareVersion = HKDevicePropertyKeyFirmwareVersion;
                    //NSLog(@"ambientTemp_C: %@,%@, %0.f ,%@, %@, %@, %@, %@", [sample.metadata objectForKey:@"ambientTemp_C"], sample.startDate,heartRateVariability, sample.UUID.UUIDString, [sample.metadata objectForKey:@"HKDeviceName"],[sample.metadata objectForKey:@"deviceConnection"], [sample.metadata objectForKey:@"RRIntervalData"], [sample.metadata objectForKey:@"bandDistanceToday_km"]);
                    
                    
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
                    NSString * sampleStartDateString = [dateFormatter stringFromDate:sample.startDate];
                    
                    //        NSString * deviceName = ([sample.metadata objectForKey:@"HKDeviceName"] ? [sample.metadata objectForKey:@"HKDeviceName"]: @"-99");
                    NSString * deviceName = ([[UIDevice currentDevice] name] ? [[UIDevice currentDevice] name]: @"-99");
                    NSString * userName = ([self userName] ? [self userName]: @"-99");
                    NSString * sampleSource = (sample.sourceRevision.source.name ? sample.sourceRevision.source.name: @"-99");
                    NSString *sampleRevisionSourceDescription = (sample.sourceRevision.source.description ? sample.sourceRevision.source.description: @"-99");
                    NSString *sampleDeviceName = (sample.device.name ? sample.device.name: @"-99");
                    NSString *sampleDeviceHardwareVersion = (sample.device.hardwareVersion ? sample.device.hardwareVersion: @"-99");
                    NSString *sampleDeviceModel = (sample.device.model ? sample.device.model: @"-99");
                    NSString *sampleUUID = (sample.UUID.UUIDString ? sample.UUID.UUIDString: @"-99");
                    
                    
                    NSCharacterSet *charactersToRemove =
                    [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                    
                    NSString *trimmedReplacementDevicename =
                    [[deviceName componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *trimmedReplacementUserName =
                    [[userName componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *trimmedReplacementSampleSource =
                    [[sampleSource componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *sampleSourceRevisionDescription =
                    [[sampleRevisionSourceDescription componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSLog(@" clean name %@, ugly name %@",trimmedReplacementDevicename, deviceName);
                    NSLog(@" clean name %@, ugly name %@",trimmedReplacementUserName, userName);
                    
                    NSArray *ar = @[trimmedReplacementDevicename,
                                    trimmedReplacementUserName,
                                    sampleStartDateString,
                                    trimmedReplacementSampleSource,
                                    heartRateString,
                                    sampleDeviceName,
                                    sampleDeviceHardwareVersion,
                                    sampleDeviceModel,
                                    sampleUUID,
                                    sampleSourceRevisionDescription
                                    //
                                    ];
                    [archive addObject:ar];
                    
                }
                
                NSArray *arHeader = @[@"deviceName",
                                      @"user",
                                      @"sampleStartDate",
                                      @"sampleSource",
                                      @"heartRateVariability_in_ms",
                                      @"sampleDeviceName",
                                      @"sampleDeviceHardwareVersion",
                                      @"sampleDeviceModel",
                                      @"sampleUUID",
                                      @"sampleSourceRevisionDescription"
                                      ];
                
                //"Weather: Partly Cloudy, temp 94 \U1d52F, feels like 104 \U1d52F, cloud 25%, humidity 50%, pressure 1015, ozone 291, wind speed 2 mph, and altitude 105 m"
                
                [archive insertObject:arHeader atIndex:0];
                self.session = [self session];
                NSArray *archiveArray = [archive copy];
                if (archiveArray.count >0) {
                    
                    NSFileManager *fileManager = [[NSFileManager alloc]     init];
                    NSString *tempDocumentDirectory= NSTemporaryDirectory();
                    NSString *filePath = [tempDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"heartRateVariability-row-%d.csv",arc4random() % 1000]];
                    
                    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
                    CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
                    
                    for (NSArray *line in archiveArray) {
                        [writer writeLineOfFields:line];
                        if (line) {
                            //NSLog(@"CSV line %@", line.description);
                            NSLog(@"CSV line description!");
                            //                            dispatch_async(dispatch_get_main_queue(), ^{
                            //                                [self.progressView setHidden:YES];
                            //                                [self.activityIndicator setHidden:NO];
                            //                                [self.activityIndicator startAnimating];
                            //                            });
                        }
                    }
                    //NSLog(@"ArchiveArray: %@", archiveArray);
                    
                    [writer closeStream];
                    
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    
                    if (filePath != nil){
                        self.url = [NSURL fileURLWithPath:filePath];
                        //            NSDictionary *fileAttributes = @{
                        //                                             NSFileProtectionKey : NSFileProtectionComplete
                        //                                             };
                        BOOL wrote = [fileManager createFileAtPath:filePath
                                                          contents:data
                                                        attributes:nil];
                        if (wrote){
                            
                            if (_url){
                                NSLog(@"upload from HERE   url path  %@", _url);
                                [self doUploadCSVWithName:_url fileName:@"heartRateVariability.csv"];
                                
                                //This is use to upload data fro specific dates
                                // [self upload:_url fileName:kwShareFileNameDaily];
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
            }
        }
    }];
    
    // TODO: execute the query
    
    [self.healthstore executeQuery:query];
}

-(void) getHKStepData:(NSDate *)pickerDate {
    
    self.healthstore = [[HKHealthStore alloc] init];
    
    
    // the interval of the samples to delete (i observed that for a specific value if start and end date are equal the query doesn't return any objects)
    //    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSDate* sourceDate = [calendar startOfDayForDate:pickerDate];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* selectedStartDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSLog(@"Yesterday destination date UploadsVC @line 530: %@", selectedStartDate);
    
    //    NSDate *startDate = selectedStartDate;
    //    NSDate *endDate = [selectedStartDate dateByAddingTimeInterval:60*60*24-1];
    
    // the interval of the samples to delete (i observed that for a specific value if start and end date are equal the query doesn't return any objects)
    NSDate *now = [NSDate date];
    int daysToAdd = -1;
    // set up date components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daysToAdd];
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] ;
    NSDate *yesterday = [gregorian dateByAddingComponents:components toDate:now options:0];
    //NSLog(@"Yesterday: %@", yesterday);
    
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *newComponents = [gregorianCalendar components:NSCalendarUnitDay
                                                           fromDate:selectedStartDate
                                                             toDate:now
                                                            options:0];
    
    long  numbeOfDays = [newComponents day];
    //NSLog(@"%ld", [newComponents day]);
    
    //    NSDate *dateOfSampleToDelete = [NSDate date];
    NSDate *startDate = [yesterday dateByAddingTimeInterval:-60*60*24*numbeOfDays];
    NSDate *endDate = [yesterday dateByAddingTimeInterval:60*60*24];
    
    NSLog(@"StartDate %@ -- %@  endDate", startDate, endDate);
    
    // the type you're trying to delete (this could be heart-beats/steps/water/calories/etc..)
    HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // the predicate used to execute the query
    NSPredicate *queryPredicate = [HKSampleQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    // prepare the query //change HKObjectQueryNoLimit to 1000
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepCountType predicate:queryPredicate limit:45000 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        if (error) {
            
            NSLog(@"Error: %@", error.description);
            
        } else {
            
            NSLog(@"Metadata %@", [[results firstObject] metadata]);
            //            NSLog(@"Successfully retrieved samples %@ and count %lu",[[[results firstObject] metadata] objectForKey:@"HKDeviceName"], results.count);
            NSMutableArray * archive = [[NSMutableArray alloc] initWithCapacity:1] ; //we will store each array in the archive mutable array
            if (results.count > 0) {
                //                NSLog(@"if (results.count > 0) -- >>>> %lu", results.count);
                //                self.progressView.progress = 0.0;
                //                [self.activityIndicator setHidden:YES];
                
                
                for (HKQuantitySample *sample in results) {
                    double stepCount = [sample.quantity doubleValueForUnit:[HKUnit countUnit]];
                    
                    NSString *stepCountString = [NSString stringWithFormat:@"%.f",stepCount];
                    
                    
                    NSLog(@"ambientTemp_C: %@,%@, %0.f ,%@, %@, %@, %@, %@", [sample.metadata objectForKey:@"ambientTemp_C"], sample.startDate, stepCount, sample.UUID.UUIDString, [sample.metadata objectForKey:@"HKDeviceName"],[sample.metadata objectForKey:@"deviceConnection"], [sample.metadata objectForKey:@"RRIntervalData"], [sample.metadata objectForKey:@"bandDistanceToday_km"]);
                    
                    
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
                    NSString * sampleStartDateString = [dateFormatter stringFromDate:sample.startDate];
                    //                    NSString * deviceName = ([sample.metadata objectForKey:@"HKDeviceName"] ? [sample.metadata objectForKey:@"HKDeviceName"]: @"-99");
                    NSString * deviceName = ([[UIDevice currentDevice] name] ? [[UIDevice currentDevice] name]: @"-99");
                    NSString * userName = ([self userName] ? [self userName]: @"-99");
                    NSString * sampleSource = (sample.sourceRevision.source.name ? sample.sourceRevision.source.name: @"-99");
                    //                   https://developer.apple.com/documentation/healthkit/hkactivitysummaryquery
                    NSString *sampleRevisionSourceDescription = (sample.sourceRevision.source.description ? sample.sourceRevision.source.description: @"-99");
                    NSString *sampleDeviceName = (sample.device.name ? sample.device.name: @"-99");
                    NSString *sampleDeviceHardwareVersion = (sample.device.hardwareVersion ? sample.device.hardwareVersion: @"-99");
                    NSString *sampleDeviceModel = (sample.device.model ? sample.device.model: @"-99");
                    NSString *sampleUUID = (sample.UUID.UUIDString ? sample.UUID.UUIDString: @"-99");
                    
                    
                    NSCharacterSet *charactersToRemove =
                    [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                    
                    NSString *trimmedReplacementDevicename =
                    [[deviceName componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *trimmedReplacementUserName =
                    [[userName componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *trimmedReplacementSampleSource =
                    [[sampleSource componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *sampleSourceRevisionDescription =
                    [[sampleRevisionSourceDescription componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSLog(@"STEP clean name %@, ugly name %@",trimmedReplacementDevicename, deviceName);
                    NSLog(@"STEP clean name %@, ugly name %@",trimmedReplacementUserName, userName);
                    
                    
                    NSArray *ar = @[trimmedReplacementDevicename,
                                    trimmedReplacementUserName,
                                    sampleStartDateString,
                                    trimmedReplacementSampleSource,
                                    stepCountString,
                                    sampleDeviceName,
                                    sampleDeviceHardwareVersion,
                                    sampleDeviceModel,
                                    sampleUUID,
                                    sampleSourceRevisionDescription
                                    ];
                    
                    [archive addObject:ar];
                    
                    
                }
                
                NSArray *arHeader = @[@"deviceName",
                                      @"user",
                                      @"sampleStartDate",
                                      @"sampleSource",
                                      @"stepCount",
                                      @"sampleDeviceName",
                                      @"sampleDeviceHardwareVersion",
                                      @"sampleDeviceModel",
                                      @"sampleUUID",
                                      @"sampleSourceRevisionDescription"
                                      ];
                
                //"Weather: Partly Cloudy, temp 94 \U1d52F, feels like 104 \U1d52F, cloud 25%, humidity 50%, pressure 1015, ozone 291, wind speed 2 mph, and altitude 105 m"
                
                [archive insertObject:arHeader atIndex:0];
                self.session = [self session];
                NSArray *archiveArray = [archive copy];
                if (archiveArray.count >0) {
                    
                    NSFileManager *fileManager = [[NSFileManager alloc]     init];
                    NSString *tempDocumentDirectory= NSTemporaryDirectory();
                    NSString *filePath = [tempDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"wearableSingleRow-%d.csv",arc4random() % 1000]];
                    
                    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
                    CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
                    for (NSArray *line in archiveArray) {
                        [writer writeLineOfFields:line];
                        if (line) {
                            
                        }
                    }
                    NSLog(@"ArchiveArray: %@", archiveArray);
                    
                    [writer closeStream];
                    
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    
                    if (filePath != nil){
                        self.url = [NSURL fileURLWithPath:filePath];
                        //            NSDictionary *fileAttributes = @{
                        //                                             NSFileProtectionKey : NSFileProtectionComplete
                        //                                             };
                        BOOL wrote = [fileManager createFileAtPath:filePath
                                                          contents:data
                                                        attributes:nil];
                        if (wrote){
                            
                            if (_url){
                                [self doUploadCSVWithName:_url fileName:@"stepCountWearable.csv"];
                                NSLog(@"upload from STEP COUNT url path  %@", _url);
                            }
                        }
                    }
                }
            }
        }
    }];
    
    // TODO: execute the query
    
    [self.healthstore executeQuery:query];
}


-(void) getHKSleepData:(NSArray *)activityArray {
    NSLog(@"getHKSleepData %@", activityArray);
    
    NSArray *arHeader = @[
                          @"deviceName",
                          @"userName",
                          @"StartDate",
                          @"EndDate",
                          @"inBedOrAsleep",
                          @"AppName",
                          @"DeviceDescription",
                          @"iOSVersion",
                          @"sampleDeviceName",
                          @"sampleDeviceHardwareVersion",
                          @"sampleDeviceModel",
                          @"sampleUUID",
                          @"sampleSourceRevisionDescription"
                          ];
    
    //[activityArray insertObject:arHeader atIndex:0];
    NSMutableArray *tempArray = [activityArray mutableCopy];
    [tempArray insertObject:arHeader atIndex:0];
    
    self.session = [self session];
    NSArray *archiveArray = [tempArray copy];
    if (archiveArray.count >0) {
        
        NSFileManager *fileManager = [[NSFileManager alloc]     init];
        NSString *tempDocumentDirectory= NSTemporaryDirectory();
        NSString *filePath = [tempDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"sleepAnalysis-row-%d.csv",arc4random() % 1000]];
        
        
        NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
        for (NSArray *line in archiveArray) {
            [writer writeLineOfFields:line];
            if (line) {
                NSLog(@"CSV line %@", line.description);
                ////NSLog(@"CSV line description!");
                //                dispatch_async(dispatch_get_main_queue(), ^{
                //                    [self.progressView setHidden:YES];
                //                    [self.activityIndicator setHidden:NO];
                //                    [self.activityIndicator startAnimating];
                //                });
            }
        }
        NSLog(@"ArchiveArray Sleep: %@", archiveArray);
        
        [writer closeStream];
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        
        if (filePath != nil){
            self.url = [NSURL fileURLWithPath:filePath];
            //            NSDictionary *fileAttributes = @{
            //                                             NSFileProtectionKey : NSFileProtectionComplete
            //                                             };
            BOOL wrote = [fileManager createFileAtPath:filePath
                                              contents:data
                                            attributes:nil];
            if (wrote){
                
                if (_url){
                     [self doUploadCSVWithName:_url fileName:@"sleepAnalysis.csv"];
                    NSLog(@"upload from sleep COUNT url path  %@", _url);
                   
                }
            }
        }
    }
}
- (NSURLSession *)backgroundSession {
    static NSURLSession *backgroundSession = nil;
    //iPainStudyXXX@icloud
    //    NSString *username = [SSKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
    //    //auth
    //    NSString *password = [SSKeychain passwordForService:@"comSicklesoftTRUBMT" account:username];
    NSString *username = [self userName];
    NSString *password = [self passWord];
    NSLog(@"Username password %@ %@", username, password);
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
    ////NSLog(@"user pass: %@,%@",_username,password);
    //
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    
    // Session Configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.sicklesoft.DukBMT.Up.BackgroundSession.Wearable"];
    
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
    //    let userCredential = URLCredential(user: user,
    //                                       password: password,
    //                                       persistence: .permanent)
    //
    //    URLCredentialStorage.shared.setDefaultCredential(userCredential, for: protectionSpace)
    //    //auth
    
    
    NSURLProtectionSpace *loginProtectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"scdi.sharefile-webdav.com"
                                                                                       port:443
                                                                                   protocol:@"https"
                                                                                      realm:nil
                                                                       authenticationMethod:NSURLAuthenticationMethodDefault];
    
    
    NSString *username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username_TRU-BLOOD"];
    NSString *password = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"password_TRU-BLOOD"];
    NSURLCredential *userCredential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistencePermanent];
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:userCredential
                                                        forProtectionSpace:loginProtectionSpace];
    
    
    
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
    NSLog(@"NSString *authStr %@", authStr);
    
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
    NSString *participant = [self participant];
    
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", kwShareFileBaseURL, kwShareFileBaseFolder,participant,kwShareFileDataFolder,fileName];
    NSURL *URL = [NSURL URLWithString:urlString];
    //NSLog(@"uploadInBackground to URL: %@ from filepath %@", urlString, filePath);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    
    
    self.uploadTask = [_backgroundSession uploadTaskWithRequest:request fromFile:filePath];
    [self.uploadTask resume];
}

-(void) uploadStreamInBackground:(NSURL *)filePath fileName:(NSString *)fileName {
    NSString *participant = [self participant];
    
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", kwShareFileBaseURL, kwShareFileBaseFolder,participant,kwShareFileDataFolder,fileName];
    NSURL *URL = [NSURL URLWithString:urlString];
    //NSLog(@"uploadInBackground to URL: %@ from filepath %@", urlString, filePath);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    
    
    self.uploadTask = [_backgroundSession uploadTaskWithRequest:request fromFile:filePath];
    [self.uploadTask resume];
}

-(NSString *)participant {
    
    NSString *participant = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username_TRU-BLOOD"];
    NSLog(@"participant  %@",participant);
    
    return participant;
}

-(void) doUploadCSV:(NSURL *)filePath  {
    
    NSString * urlString = [NSString stringWithFormat:@"%@/Dev/SMARTa/%@/Data/log.csv", kwShareFileBaseURL, [self userName]];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSLog(@"upload log.csv in background to URL: %@", URL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    
    self.uploadTaskInBackground = [self.backgroundSession uploadTaskWithRequest:request fromFile:filePath];
    [self.uploadTaskInBackground resume];
    
    
}

-(void) doUploadCSVWithName:(NSURL *)filePath fileName:(NSString *)fileName {
    
    NSString * urlString = [NSString stringWithFormat:@"%@/Dev/SMARTa/%@/Data/%@", kwShareFileBaseURL, [self userName], fileName];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSLog(@"upload log.csv in background to URL: %@", URL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    
    self.uploadTaskInBackground = [self.backgroundSession uploadTaskWithRequest:request fromFile:filePath];
    [self.uploadTaskInBackground resume];
    
    
}

-(NSString *)userName {
    
    
    NSString *username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username_TRU-BLOOD"];
    NSLog(@"user  %@",username);
    
    return username;
}

-(NSString *)passWord {
    
    
    NSString *myPassword = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"password_TRU-BLOOD"];
    //NSLog(@"myPassword %@",myPassword);
//    /comSicklesoftTRUBMT
    return myPassword;
}





//2019-10-08
-(void) getAnchorHKHeartRateData:(NSArray *)results {
    NSLog(@"here are the results from root: %@", results);
    self.healthstore = [[HKHealthStore alloc] init];
     
    NSMutableArray * archive = [[NSMutableArray alloc] initWithCapacity:1] ; //we will store each array in the archive mutable array
            if (results.count > 0) {
                //   NSLog(@"if (results.count > 0) -- >>>> %lu", results.count);
                for (HKQuantitySample *sample in results) {
                    double heartRate = [sample.quantity doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                    NSString *heartRateString = [NSString stringWithFormat:@"%.f",heartRate];
                    //[arrayHeartRate addObject:[NSNumber numberWithDouble:hbpm]];
                    NSLog(@"Successfully got heart rate %@", heartRate);
                    NSLog(@"heart rate sample metadata \n %@", sample);
                    
                    //                    NSString *HKDevicePropertyKeyFirmwareVersion = HKDevicePropertyKeyFirmwareVersion;
                    NSLog(@"ambientTemp_C: %@,%@, %0.f ,%@, %@, %@, %@, %@", [sample.metadata objectForKey:@"ambientTemp_C"], sample.startDate,heartRate, sample.UUID.UUIDString, [sample.metadata objectForKey:@"HKDeviceName"],[sample.metadata objectForKey:@"deviceConnection"], [sample.metadata objectForKey:@"RRIntervalData"], [sample.metadata objectForKey:@"bandDistanceToday_km"]);
                    
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
                    NSString * sampleStartDateString = [dateFormatter stringFromDate:sample.startDate];
                    
                    //        NSString * deviceName = ([sample.metadata objectForKey:@"HKDeviceName"] ? [sample.metadata objectForKey:@"HKDeviceName"]: @"-99");
                    NSString * deviceName = ([[UIDevice currentDevice] name] ? [[UIDevice currentDevice] name]: @"-99");
                    NSString * userName = ([self userName] ? [self userName]: @"-99");
                    NSString * sampleSource = (sample.sourceRevision.source.name ? sample.sourceRevision.source.name: @"-99");
                    NSString *sampleRevisionSourceDescription = (sample.sourceRevision.source.description ? sample.sourceRevision.source.description: @"-99");
                    NSString *sampleDeviceName = (sample.device.name ? sample.device.name: @"-99");
                    NSString *sampleDeviceHardwareVersion = (sample.device.hardwareVersion ? sample.device.hardwareVersion: @"-99");
                    NSString *sampleDeviceModel = (sample.device.model ? sample.device.model: @"-99");
                    NSString *sampleUUID = (sample.UUID.UUIDString ? sample.UUID.UUIDString: @"-99");
                    
                    NSCharacterSet *charactersToRemove =
                    [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                    
                    NSString *trimmedReplacementDevicename =
                    [[deviceName componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *trimmedReplacementUserName =
                    [[userName componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *trimmedReplacementSampleSource =
                    [[sampleSource componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSString *sampleSourceRevisionDescription =
                    [[sampleRevisionSourceDescription componentsSeparatedByCharactersInSet:charactersToRemove]
                     componentsJoinedByString:@""];
                    
                    NSLog(@" clean name %@, ugly name %@",trimmedReplacementDevicename, deviceName);
                    NSLog(@" clean name %@, ugly name %@",trimmedReplacementUserName, userName);
                    
                    NSArray *ar = @[trimmedReplacementDevicename,
                                    trimmedReplacementUserName,
                                    sampleStartDateString,
                                    trimmedReplacementSampleSource,
                                    heartRateString,
                                    sampleDeviceName,
                                    sampleDeviceHardwareVersion,
                                    sampleDeviceModel,
                                    sampleUUID,
                                    sampleSourceRevisionDescription
                                    //
                    ];
                    [archive addObject:ar];
                    
                }
                
                NSArray *arHeader = @[@"deviceName",
                                      @"user",
                                      @"sampleStartDate",
                                      @"sampleSource",
                                      @"heartRate",
                                      @"sampleDeviceName",
                                      @"sampleDeviceHardwareVersion",
                                      @"sampleDeviceModel",
                                      @"sampleUUID",
                                      @"sampleSourceRevisionDescription"
                                      ];
                
                //"Weather: Partly Cloudy, temp 94 \U1d52F, feels like 104 \U1d52F, cloud 25%, humidity 50%, pressure 1015, ozone 291, wind speed 2 mph, and altitude 105 m"
                
                [archive insertObject:arHeader atIndex:0];
                self.session = [self session];
                NSArray *archiveArray = [archive copy];
                if (archiveArray.count >0) {
                    
                    NSFileManager *fileManager = [[NSFileManager alloc]     init];
                    NSString *tempDocumentDirectory= NSTemporaryDirectory();
                    NSString *filePath = [tempDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"heartRate-row-%d.csv",arc4random() % 1000]];
                    
                    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
                    CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
                    
                    for (NSArray *line in archiveArray) {
                        [writer writeLineOfFields:line];
                        if (line) {
                            NSLog(@"CSV line %@", line.description);
                            NSLog(@"CSV line description!");
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [self.progressView setHidden:YES];
//                                [self.activityIndicator setHidden:NO];
//                                [self.activityIndicator startAnimating];
//                            });
                        }
                    }
                    NSLog(@"ArchiveArray: %@", archiveArray);
                    
                    [writer closeStream];
                    
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    
                    if (filePath != nil){
                        self.url = [NSURL fileURLWithPath:filePath];
                        //            NSDictionary *fileAttributes = @{
                        //                                             NSFileProtectionKey : NSFileProtectionComplete
                        //                                             };
                        BOOL wrote = [fileManager createFileAtPath:filePath
                                                          contents:data
                                                        attributes:nil];
                        if (wrote){
                            
                            if (_url){
                                NSLog(@"upload from HERE   url path  %@", _url);
                                 [self doUploadCSVWithName:_url fileName:@"heartRate.csv"];
                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    [self.progressView setHidden:NO];
//                                    [self.progressView setProgress:0.0];
                                   
                                    //[self getHKDataRestingHeartRate:startDate endDate:endDate];
                                    //[self getHKDataWalkingHeartRateAverage:startDate endDate:endDate];
                                    //[self getHKDataHeartRateVariability:startDate endDate:endDate];
                                    
                                });
                                //This is use to upload data fro specific dates
                                // [self upload:_url fileName:kwShareFileNameDaily];
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
            } //if (archiveArray.count >0) {
    

    

}


@end
