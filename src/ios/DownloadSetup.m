//
//  DownloadSetup.m
//  
//
//  Created by way2smile on 02/01/17.
//
//

#import "DownloadSetup.h"

@implementation DownloadSetup

/*!
 * @brief set default values for download task
 * @param call back id and Url
 */
-(id)initWithFileCallbackId:(NSString *)callbackId andDownloadSource:(NSString *)source{
    if (self == [super init]) {
        
        self.callbackId = callbackId;
        self.downloadSource = source;
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
        self.taskIdForDescription = 0;
        self.status = @"Start";
    }
    
    return self;
}

@end

