//
//  UploadsViewController.h
//  TRU-BMT
//
//  Created by Jude on 4/21/19.
//  Copyright © 2019 scdi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UploadsViewController : UIViewController <NSURLSessionDataDelegate, NSURLSessionDelegate,  NSURLSessionDataDelegate>
-(void) getHKHeartRateData:(NSDate *)pickerDate;
-(void) getHKHeartRateVariabilityData:(NSDate *)pickerDate;
-(void) getHKStepData:(NSDate *)pickerDate;
//-(void) getHKActivityData:(NSDate *)pickerDate;
-(NSString *)userName;
-(void) getHKActivityData:(NSDate *)pickerDate  activityArray:(NSArray *)activityArray sharefileName:(NSString *)sharefileName;
-(void) getActiveEnergyData:(NSDate *)pickerDate  activityArray:(NSMutableArray *)activityArray sharefileName:(NSString *)sharefileName;
-(void) getHKSleepData:(NSArray *)activityArray;
-(void) doUploadCSV:(NSURL *)filePath;
-(NSString *)removeSpecialCharacters:(NSString *)cleanString;
@end


NS_ASSUME_NONNULL_END
