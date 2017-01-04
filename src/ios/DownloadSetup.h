//
//  DownloadSetup.h
//  
//
//  Created by way2smile on 02/01/17.
//
//

#import <Foundation/Foundation.h>

@interface DownloadSetup : NSObject

@property (nonatomic, strong) NSString *downloadSource;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSData *taskResumeData;

@property (nonatomic) double downloadProgress;

@property (nonatomic) BOOL isDownloading;

@property (nonatomic) BOOL downloadComplete;

@property (nonatomic) unsigned long taskIdentifier;

@property (nonatomic, strong) NSString * callbackId;

@property (nonatomic, strong) NSString * status;

@property (nonatomic) NSInteger taskIdForDescription;


-(id)initWithFileCallbackId:(NSString *)callbackId andDownloadSource:(NSString *)source;

@end
