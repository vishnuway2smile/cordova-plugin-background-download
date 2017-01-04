//
//  DownloadSetup.h
//  
//
//  Created by way2smile on 02/01/17.
//
//  Downloadtask defined as a DownloadSetup Object, It maitains downloadtask, it's status and its properties
//

#import <Foundation/Foundation.h>

@interface DownloadSetup : NSObject

/*!
 * @brief It contains Download Url as String
 */
@property (nonatomic, strong) NSString *downloadSource;

/*!
 * @brief It contains Download Task
 */
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

/*!
 * @brief Has the task resume data
 */
@property (nonatomic, strong) NSData *taskResumeData;

/*!
 * @brief calculates the download progress in percentage
 */
@property (nonatomic) double downloadProgress;

/*!
 * @brief bool value about downloading status
 */
@property (nonatomic) BOOL isDownloading;

/*!
 * @brief bool value about download complete
 */
@property (nonatomic) BOOL downloadComplete;


@property (nonatomic) unsigned long taskIdentifier;

/*!
 * @brief cantains call back id for connect main thread
 */
@property (nonatomic, strong) NSString * callbackId;


/*!
 * @brief download status as string
 */
@property (nonatomic, strong) NSString * status;


/*!
 * @brief cantains for download local Id
 */
@property (nonatomic) NSInteger taskIdForDescription;


/*!
 * @brief declaration init with callbackid and url
 * @param call back id and Url
 */
-(id)initWithFileCallbackId:(NSString *)callbackId andDownloadSource:(NSString *)source;

@end
