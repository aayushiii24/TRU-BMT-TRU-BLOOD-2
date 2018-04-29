//
//  UploadApi.h
//  TRU-Pain
//
//  Created by scdi on 10/25/16.
//  Copyright © 2016 Jude Jonassaint. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadApi : NSObject <NSURLSessionDataDelegate, NSURLSessionDelegate,  NSURLSessionDataDelegate> {
    NSURLSession *_session;
    NSURLSession *_backgroundSession;
}
@property (nonatomic, strong) NSString *username;
@property (strong, nonatomic) NSURLSessionUploadTask *uploadTask;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *currentlyUploading;

-(void)uploadJSONDictionary:(NSDictionary *)dictionaryToImport;
//-(void)uploadProfileJSONDictionary:(NSDictionary *)dictionaryToImport;

- (void) writeAndUploadCSVToSharefileForSymptomFocus:(NSArray *)dataToUpload :(NSString *)fileName;

@end
