//
//  UploadApi.m
//  TRU-Pain
//
//  Created by scdi on 10/25/16.
//  Copyright © 2016 Jude Jonassaint. All rights reserved.
//

#import "UploadApi.h"
#import "SAMKeychain.h"
#import "CHCSVParser.h"
#import "AppDelegate.h"

static NSString * const kShareFileBaseFolder = @"Dev/SMARTa";
static NSString * const kShareFileBaseURL = @"https://scdi.sharefile-webdav.com:443";
static NSString * const kShareFileDataFolder = @"Data";
static NSString * const kShareFileName = @"chartsData.json";
static NSString * const kShareProfileFileName = @"profile.json";
static NSString * const kShareFileSymptomFocus = @"symptomFocus.csv";


@implementation UploadApi

 

-(void) uploadJSONDictionary:(NSDictionary *)dictionary {
    NSLog(@"uploadJSONDictionary in UploadApi.m");
    
   _session = [self session];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"json string %@", jsonString);
        NSFileManager *fileManager = [[NSFileManager alloc]     init];
        NSString *tempDocumentDirectory= NSTemporaryDirectory();
        NSString *filePath = [tempDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"charts-%d.csv",arc4random() % 1000]];
        
        if (filePath != nil){
            NSURL *url = [NSURL fileURLWithPath:filePath];
            NSDictionary *fileAttributes = @{
                                             NSFileProtectionKey : NSFileProtectionComplete
                                             };
            BOOL wrote = [fileManager createFileAtPath:filePath
                                              contents:jsonData
                                            attributes:fileAttributes];
            if (wrote){
                NSLog(@"Successfully and securely stored the file in MTView controller");
                
                if (url){
                    NSLog(@"upload in foreground from url in MTView controller %@", url);
                    //Upload CSV file
                    [self upload:url fileName:kShareFileName];
                }
                
            } else {
                NSLog(@"Failed to write the file");
                
            }
        }
    }
}
-(void) upload:(NSURL *)filePath fileName:(NSString *)fileName {
    
    NSLog(@"fileName %@ to be uploaded",fileName);
    if (!_session) {
        _session = [self session];
    }
    
    self.username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", kShareFileBaseURL, kShareFileBaseFolder,_username,kShareFileDataFolder,fileName];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSLog(@"upload movie to URL from -(void) upload:(NSURL *)filePath fileName:(NSString *)fileName: %@ from filepath %@", URL, filePath);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    self.uploadTask  = [_session uploadTaskWithRequest:request fromFile:filePath completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error==nil) {
            NSLog(@"Yeah, file in Upload API %@ uploaded from thank you view controller to URL:%@", URL, fileName);
            // Invalidate Session
            //[self webData];
            [_session finishTasksAndInvalidate];
        } else {
            NSLog(@"response from server: %@", response);
            _backgroundSession = [self backgroundSession];
            [self uploadInBackground:filePath fileName:fileName];
        }
    }];
    //[self performSegueWithIdentifsavePreier:@"MoodHome" sender:self];
    
    [self.uploadTask resume];
    
}

-(void) uploadJSON:(NSURL *)filePath fileName:(NSString *)fileName {
    NSLog(@"fileName %@ to be uploaded",fileName);
    self.username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", kShareFileBaseURL, kShareFileBaseFolder,_username,kShareFileDataFolder,fileName];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSLog(@"upload movie to URL from thanksViewController: %@ from filepath %@", URL, filePath);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    self.uploadTask  = [_session uploadTaskWithRequest:request fromFile:filePath completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error==nil) {
            NSLog(@"Yeah, file in Upload API %@ uploaded from thank you view controller to URL:%@", URL, fileName);
            // Invalidate Session
            // [self webDataJSON];
            [_session finishTasksAndInvalidate];
        } else {
            NSLog(@"response from server: %@", response);
            _backgroundSession = [self backgroundSession];
            [self uploadInBackground:filePath fileName:fileName];
        }
    }];
    //[self performSegueWithIdentifsavePreier:@"MoodHome" sender:self];
    
    [self.uploadTask resume];
    
}


//an upload in background session mode
-(void) uploadInBackground:(NSURL *)filePath fileName:(NSString *)fileName {
    self.username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", kShareFileBaseURL, kShareFileBaseFolder,_username,kShareFileDataFolder,fileName];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSLog(@"uploadInBackground to URL: %@ from filepath %@", urlString, filePath);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    
    self.uploadTask = [_backgroundSession uploadTaskWithRequest:request fromFile:filePath];
    [self.uploadTask resume];
}

//Sessions and Sessions' Delegates
- (NSURLSession *)session {
    static NSURLSession *session = nil;
    self.username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
    //auth
    NSString *password = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:_username];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.username, password];
    //
    
    //NSLog(@"user pass: %@,%@",_username,password);
    
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    
    // Session Configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //set additional header for auth
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Authorization": authValue}];
    
    // Initialize Session
    session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    return session;
}
- (NSURLSession *)backgroundSession {
    static NSURLSession *backgroundSession = nil;
    
    self.username = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:@"username"];
    //auth
    
    NSString *password = [SAMKeychain passwordForService:@"comSicklesoftTRUBMT" account:_username];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.username, password];
    NSLog(@"user pass: %@,%@",_username,password);
    //
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    
    // Session Configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.sicklesoft.ITP.BackgroundSession"];
    
    //set additional header for auth
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Authorization": authValue}];
    
    // Initialize Session
    backgroundSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    
    return backgroundSession;
}
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSLog(@"session did receive challenge");
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    NSLog(@"All tasks are finished");
    
}

- (void)invokeBackgroundSessionCompletionHandler {
    [_backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
        NSLog(@"pre lastCount %ld", (long)count);
        if (!count) {
            AppDelegate *applicationDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            void (^backgroundSessionCompletionHandler)() = [applicationDelegate backgroundSessionCompletionHandler];
            
            if (backgroundSessionCompletionHandler) {
                NSLog(@"LASTcount post %ld", (long)count);
                [applicationDelegate setBackgroundSessionCompletionHandler:nil];
                backgroundSessionCompletionHandler();
            }
        }
    }];
}

//delegate method for UPLOAD TASK
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"bytes sent %lld", bytesSent);
    NSLog(@"expected bytes %lld", totalBytesExpectedToSend);
    NSLog(@"total bytes sent %lld", totalBytesSent);
    [self invokeBackgroundSessionCompletionHandler]; //in appDelegate
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error




{

}

/*
-(void)uploadProfileJSONDictionary:(NSDictionary *)dictionary {
    
    self.currentlyUploading = @"profile.json";
    NSLog(@"uploadProfileJSONDictionary in UploadApi.m");
    _session = [self session];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"json string %@", jsonString);
        NSFileManager *fileManager = [[NSFileManager alloc]     init];
        NSString *tempDocumentDirectory= NSTemporaryDirectory();
        NSString *filePath = [tempDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"charts-%d.csv",arc4random() % 1000]];
        
        if (filePath != nil){
            NSURL *url = [NSURL fileURLWithPath:filePath];
            NSDictionary *fileAttributes = @{
                                             NSFileProtectionKey : NSFileProtectionComplete
                                             };
            BOOL wrote = [fileManager createFileAtPath:filePath
                                              contents:jsonData
                                            attributes:fileAttributes];
            if (wrote){
                NSLog(@"Successfully and securely stored the file in MTView controller");
                
                if (url){
                    NSLog(@"upload in foreground from url in MTView controller %@", url);
                    //Upload CSV file
                    [self uploadJSON:url fileName:kShareProfileFileName];
                    
                }
                
            } else {
                NSLog(@"Failed to write the file");
                
            }
            
        }
        
    }
    
}
 */
 

 
- (void) writeAndUploadCSVToSharefileForSymptomFocus:(NSArray *)dataToUpload :(NSString *)fileName {
    NSLog(@"Write CSV line.");
    
    NSArray *archiveArray = [dataToUpload copy];
    if (archiveArray) {
 
        NSFileManager *fileManager = [[NSFileManager alloc]     init];
        NSString *tempDocumentDirectory= NSTemporaryDirectory();
        NSString *filePath = [tempDocumentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"symptomFocus-%d.csv",arc4random() % 1000]];
        
        NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
        for (NSArray *line in archiveArray) {
            [writer writeLineOfFields:line];
            if (line) {
                ////NSLog(@"CSV line %@", line.description);
                ////NSLog(@"CSV line description!");
            }
        }
        //NSLog(@"CSV line description!");
        [writer closeStream];
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        
        if (filePath != nil){
            NSURL *url = [NSURL fileURLWithPath:filePath];
            //            NSDictionary *fileAttributes = @{
            //                                             NSFileProtectionKey : NSFileProtectionComplete
            //                                             };
            BOOL wrote = [fileManager createFileAtPath:filePath
                                              contents:data
                                            attributes:nil];
            if (wrote){
                NSLog(@"Successfully and securely stored the file");
                
                if (url){
                    NSLog(@"upload to url  %@", url);
                    //Upload CSV file
                    [self upload:url fileName:fileName];
                
                   
                }
                
            } else {
                NSLog(@"Failed to write the file");
                
 
            }
            
        }
        
    }
}

@end
