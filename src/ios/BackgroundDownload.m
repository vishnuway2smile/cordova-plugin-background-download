//
//  BackgroundDownload.m
//
//
//  Created by way2smile
//
//  Multiple background download plugin
//

#import "BackgroundDownload.h"
#import "DownloadSetup.h"

@interface BackgroundDownload (){
    
    
    /*!
     * @brief download session
     */
    NSURLSession *session;
    
    /*!
     * @brief Download tasks in an array
     */
    NSMutableArray * downloadArray;
}

@end

@implementation BackgroundDownload

- (void) awakeFromNib{
    [super awakeFromNib];
     self.backgroundTask = UIBackgroundTaskInvalid;
}

/*!
 * @brief initiate download process method definition
 * @param CDVInvokedUrlCommand from Cordova
 */
- (void)startDownload:(CDVInvokedUrlCommand*)command
{
    
    // allocate download tasks array when it has no object
    if (downloadArray.count == 0 || downloadArray == nil || downloadArray == (id)[NSNull null]){
        downloadArray = [NSMutableArray new];
    }
    
    // initiate DownloadSetup object with url and callback id
    DownloadSetup * downloadSetup = [[DownloadSetup alloc] initWithFileCallbackId:command.callbackId andDownloadSource:[[command arguments] objectAtIndex:0]];
    
    // add download set up object to download task array
    [downloadArray addObject: downloadSetup];
    
    NSLog(@"callback id %@",command.callbackId);
    
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    // call download url with download object
    [self downloadByURL:downloadSetup];
}



/*!
 * @brief find required download set up object
 * @param task identifier for get a require download setup object
 */
-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier{
   
    int index = 0;
    
    for (int i=0; i<[downloadArray count]; i++) {
        
        DownloadSetup *downloadSetup = [downloadArray objectAtIndex:i];
        
        if ([downloadSetup.downloadTask.taskDescription integerValue] == taskIdentifier) {
            
            index = i;
            break;
        }
    }
    
    return index;
}

/*!
 * @brief start donwload by url
 * @param download set up object is used as parameter
 */
- (void) downloadByURL: (DownloadSetup *)downloadSetup{
    
    // Session queue
    NSOperationQueue* sessionQueue = [[NSOperationQueue alloc] init];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // call delegate method with session configuration and session queue
    session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:sessionQueue];
    
    // session initiate download task by url
    downloadSetup.downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:downloadSetup.downloadSource]];
    
    downloadSetup.taskIdentifier = downloadSetup.downloadTask.taskIdentifier;
    
    downloadSetup.downloadTask.taskDescription = [NSString stringWithFormat:@"%ld",(unsigned long)downloadArray.count];
    
    downloadSetup.taskIdForDescription = downloadArray.count;
    
    // start download task
    [downloadSetup.downloadTask resume];
    
    // Change the isDownloading property value.
    downloadSetup.isDownloading = !downloadSetup.isDownloading;
    
    
    // return call back id as a dictionary object to Java Script by cordova
    NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
    [progressObj setObject:downloadSetup.callbackId forKey:@"id"];
    NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
    [resObj setObject:progressObj forKey:@"callback"];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
    result.keepCallback = [NSNumber numberWithInteger: TRUE];
    [self.commandDelegate sendPluginResult:result callbackId:downloadSetup.callbackId];
}

/*!
 * @brief Suspend Method
 * @param CDVInvokedUrlCommand from Cordova for get call back id
 */
- (void) suspendDownloadTask :(CDVInvokedUrlCommand*)command{
    
    NSLog(@"suspendDownloadTask id %@",[[command arguments] objectAtIndex:0]);
    
    
    // Get Call back id
    NSString * argument =  [[command arguments] objectAtIndex:0];
    
    // Predicate call back Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"callbackId CONTAINS[c] %@", argument ];

    // filter download task array by pridicate
    NSArray * sampleArray = [downloadArray filteredArrayUsingPredicate:predicate];
    
    NSLog(@"sample array %@ id %@",sampleArray,[[command arguments] objectAtIndex:0]);
    
    
    if (sampleArray.count){
        
        
        // get download set up object from filtered array
        DownloadSetup * downloadSetup = [sampleArray objectAtIndex:0];
        
        // cancel download task and get downloaded data as a resume data
        [downloadSetup.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            if (resumeData != nil) {
                downloadSetup.taskResumeData = [[NSData alloc] initWithData:resumeData];
            }
        }];
        
        // set downloas status as a Suspend
        downloadSetup.status = @"Suspend";
        
        NSLog(@"suspend task id %@",downloadSetup.downloadTask.taskDescription);
        downloadSetup.isDownloading = !downloadSetup.isDownloading;
        
        
        // return call back id and Status by below cordova CDVPluginResult
        
        NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [progressObj setObject:downloadSetup.callbackId forKey:@"callbackId"];
        [progressObj setObject:@"pause" forKey:@"type"];
        NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [resObj setObject:progressObj forKey:@"data"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    else{
        
        // if Call back id is not match, the error alert send by below cordova CDVPluginResult
        
        NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [progressObj setObject:[[command arguments] objectAtIndex:0] forKey:@"callbackId"];
        [progressObj setObject:@"Error" forKey:@"Status"];
        NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [resObj setObject:progressObj forKey:@"data"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

/*!
 * @brief Resume Method
 * @param CDVInvokedUrlCommand from Cordova for get call back id
 */
- (void) resumeDownloadTask :(CDVInvokedUrlCommand*)command{
    
    NSLog(@"resumeDownloadTask id %@",[[command arguments] objectAtIndex:0]);
    
    // Get Call back id
    NSString * argument =  [[command arguments] objectAtIndex:0];
    
    // Predicate call back Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"callbackId CONTAINS[c] %@", argument ];

    // filter download task array by pridicate
    NSArray * sampleArray = [downloadArray filteredArrayUsingPredicate:predicate];
    
    NSLog(@"sample array %@ id %@",sampleArray,[[command arguments] objectAtIndex:0]);
    
    if (sampleArray.count){
        
        // get download set up object from filtered array
        DownloadSetup * downloadSetup = [sampleArray objectAtIndex:0];
        
        NSLog(@"data length %ld  id %@",(unsigned long)downloadSetup.taskResumeData.length,downloadSetup.callbackId);

        // check download status
        if ([downloadSetup.status isEqualToString: @"Suspend"]){
            
            // check resume data is available or not
            if (downloadSetup.taskResumeData){
                
                // resume download with resume data
                downloadSetup.downloadTask = [session downloadTaskWithResumeData:downloadSetup.taskResumeData];
                [downloadSetup.downloadTask resume];
            }
            else{
                
                // restart download with Url
                downloadSetup.downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:downloadSetup.downloadSource]];
                [downloadSetup.downloadTask resume];
            }
            
            // Set download status as a Start
            downloadSetup.status = @"Start";
            
            // Keep the new download task identifier.
            downloadSetup.taskIdentifier = downloadSetup.downloadTask.taskIdentifier;
            
            downloadSetup.downloadTask.taskDescription = [NSString stringWithFormat:@"%ld",(unsigned long)downloadSetup.taskIdForDescription];
            
            NSLog(@"resume task id %@",downloadSetup.downloadTask.taskDescription);
            downloadSetup.isDownloading = !downloadSetup.isDownloading;
            
            // return call back id and Status by below cordova CDVPluginResult
            NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
            [progressObj setObject:downloadSetup.callbackId forKey:@"callbackId"];
            [progressObj setObject:@"resume" forKey:@"type"];
            NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
            [resObj setObject:progressObj forKey:@"data"];
            
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
            
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
        else{
            
            // Send download has been canceled by below cordova CDVPluginResult
            NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
            [progressObj setObject:[[command arguments] objectAtIndex:0] forKey:@"callbackId"];
            [progressObj setObject:@"Download cancel" forKey:@"Status"];
            NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
            [resObj setObject:progressObj forKey:@"data"];
            
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
            
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            
        }

    }
    else{
        
        // if Call back id is not match, the error alert send by below cordova CDVPluginResult
        
        NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [progressObj setObject:[[command arguments] objectAtIndex:0] forKey:@"callbackId"];
        [progressObj setObject:@"Error" forKey:@"Status"];
        NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [resObj setObject:progressObj forKey:@"data"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    
}

/*!
 * @brief Cancel Method
 * @param CDVInvokedUrlCommand from Cordova for get call back id
 */
- (void) cancelDownloadTask :(CDVInvokedUrlCommand*)command{
    
    NSLog(@"cancelDownloadTask id %@",[[command arguments] objectAtIndex:0]);
    
    // Get Call back id
    NSString * argument =  [[command arguments] objectAtIndex:0];
    
    // Predicate call back Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"callbackId CONTAINS[c] %@", argument ];
    
    // filter download task array by pridicate
    NSArray * sampleArray = [downloadArray filteredArrayUsingPredicate:predicate];
    
    NSLog(@"sample array %@ id %@",sampleArray,[[command arguments] objectAtIndex:0]);
    
    if (sampleArray.count){
        
        // get download set up object from filtered array
        DownloadSetup * downloadSetup = [sampleArray objectAtIndex:0];
        
        // Keep the new download task identifier.
        [downloadSetup.downloadTask cancel];
        
        // Change all related properties.
        downloadSetup.isDownloading = NO;
        downloadSetup.taskIdentifier = -1;
        downloadSetup.downloadProgress = 0.0;
        
        NSLog(@"cancel");
        
        // set download starus as cancel
        downloadSetup.status = @"Cancel";
        
        
        // return call back id and Status by below cordova CDVPluginResult
        NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [progressObj setObject:downloadSetup.callbackId forKey:@"callbackId"];
         [progressObj setObject:@"cancel" forKey:@"type"];
        NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [resObj setObject:progressObj forKey:@"data"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    else{
        
        // if Call back id is not match, the error alert send by below cordova CDVPluginResult
        
        NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [progressObj setObject:[[command arguments] objectAtIndex:0] forKey:@"callbackId"];
        [progressObj setObject:@"Error" forKey:@"Status"];
        NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [resObj setObject:progressObj forKey:@"data"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    
}

/*!
 * @brief get download status
 * @param CDVInvokedUrlCommand from Cordova for get call back id
 */
- (void) downloadStatus :(CDVInvokedUrlCommand*)command{
    
    NSLog(@"id %@",[[command arguments] objectAtIndex:0]);

    // Get Call back id
    NSString * argument =  [[command arguments] objectAtIndex:0];
    
    // Predicate call back Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"callbackId CONTAINS[c] %@", argument ];
    
    // filter download task array by pridicate
    NSArray * sampleArray = [downloadArray filteredArrayUsingPredicate:predicate];
    
    NSLog(@"sample array %@ id %@",sampleArray,[[command arguments] objectAtIndex:0]);
    
    if (sampleArray.count){
        
        // get download set up object from filtered array
        DownloadSetup * downloadSetup = [sampleArray objectAtIndex:0];
        
        // calculate download progress
        NSString * progressString = [NSString stringWithFormat:@"%0.2f %%",downloadSetup.downloadProgress*100];
        
        
        // return call back id and Progress by below cordova CDVPluginResult
        NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [progressObj setObject:[[command arguments] objectAtIndex:0] forKey:@"callbackId"];
        [progressObj setObject:progressString forKey:@"progress"];
         [progressObj setObject:@"status" forKey:@"type"];
        NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [resObj setObject:progressObj forKey:@"data"];

        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    else{
        
        // if Call back id is not match, the error alert send by below cordova CDVPluginResult
        
        NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [progressObj setObject:[[command arguments] objectAtIndex:0] forKey:@"callbackId"];
        [progressObj setObject:@"Error" forKey:@"Status"];
        NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [resObj setObject:progressObj forKey:@"data"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

#pragma mark - NSURLSession delegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSError *error;
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *newURL = [NSURL URLWithString:@""];
    NSLog(@"downloadTask id %@ download url %@",downloadTask.taskDescription, downloadTask.originalRequest.URL);
    
    // check download url available or not
    if (!downloadTask.originalRequest.URL){
        
        // If not having download url, get it from DownloadSetup by using taskIdForDescription
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskIdForDescription == %ld", [downloadTask.taskDescription integerValue]];
        
        NSArray * sampleArray = [downloadArray filteredArrayUsingPredicate:predicate];
        
        if (sampleArray.count){
            
            // get Download url from DownloadSetuo
            DownloadSetup * downloadSetup = [sampleArray objectAtIndex:0];
            
            NSURL * source = [NSURL URLWithString:downloadSetup.downloadSource];
            
            // reasign url
            newURL = [[NSURL alloc] initWithScheme:[source scheme]
                                              host:[source host]
                                              path:[source path]];
        }
    }
    else{
        
        // reasign url
        newURL = [[NSURL alloc] initWithScheme:[downloadTask.originalRequest.URL scheme]
                                          host:[downloadTask.originalRequest.URL host]
                                          path:[downloadTask.originalRequest.URL path]];
    }
    
    
    // create local directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentString = [[paths objectAtIndex:0] stringByAppendingString:@"/LocalDatabase/"];
    
    NSLog(@"local path %@",newURL);

    // get last path component from source url
    NSString * lastComponent = newURL.lastPathComponent;

    lastComponent = [lastComponent stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    lastComponent = [lastComponent stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];
    
    // attached source url last component to local path directort
    documentString = [documentString stringByAppendingString:lastComponent];
    
    NSString * filePath = [NSString stringWithFormat:@"file://%@",documentString];
    
    NSURL * docDirectoryURL = [NSURL URLWithString:filePath];
    
    // Check directory is availabel or not, if not having directory created that directory path
    BOOL isDir;
    BOOL exists = [fileManager fileExistsAtPath:documentString isDirectory:&isDir];
    if (exists) {
        if (!isDir) {
            if(![fileManager createDirectoryAtPath:documentString withIntermediateDirectories:YES attributes:nil error:&error]) {
                // An error has occurred, do something to handle it
                NSLog(@"Failed to create directory \"%@\". Error: %@", documentString, error);
            }
        }
    }
    else {
        if(![fileManager createDirectoryAtPath:documentString withIntermediateDirectories:YES attributes:nil error:&error]) {
            // An error has occurred, do something to handle it
            NSLog(@"Failed to create directory \"%@\". Error: %@", documentString, error);
        }
    }
    
    NSLog(@"local path %@",docDirectoryURL);
    
    // if file path url exists remove and create that path url
    if ([fileManager fileExistsAtPath:[docDirectoryURL path]]) {
        [fileManager removeItemAtURL:docDirectoryURL error:nil];
    }
    
    
    error = nil;
    
    // get bool value for moving the download data temprory to created file path
    BOOL success = [fileManager copyItemAtURL:location
                                        toURL:docDirectoryURL
                                        error:&error];
    
    if (success) {
        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"File save at" message:filePath preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
//        [alertController addAction:ok];
//        
//        [self.viewController presentViewController:alertController animated:YES completion:nil];
        
        // Change the flag values of the respective FileDownloadInfo object.
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:[downloadTask.taskDescription integerValue]];
        DownloadSetup *downloadSetup = [downloadArray objectAtIndex:index];
        
        downloadSetup.isDownloading = NO;
        downloadSetup.downloadComplete = YES;
        
        // Set the initial value to the taskIdentifier property of the fdi object,
        // so when the start button gets tapped again to start over the file download.
        downloadSetup.taskIdentifier = -1;
        
        // In case there is any resume data stored in the fdi object, just make it nil.
        downloadSetup.taskResumeData = nil;
        
        
        // send success message and local path by below cordova CDVPluginResult
        NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [progressObj setObject:[docDirectoryURL absoluteString] forKey:@"path"];
        [progressObj setObject:@"done" forKey:@"status"];
        [progressObj setObject:downloadSetup.callbackId forKey:@"callbackId"];
        NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [resObj setObject:progressObj forKey:@"complete"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
        
        [self.commandDelegate sendPluginResult:result callbackId:downloadSetup.callbackId];
        
        NSLog(@"success");
        
    }
    else{
        
        // send failure message of save local path by below cordova CDVPluginResult
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:[downloadTask.taskDescription integerValue]];
        DownloadSetup *downloadSetup = [downloadArray objectAtIndex:index];
        
        NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Not saved"];
        
        [self.commandDelegate sendPluginResult:result callbackId:downloadSetup.callbackId];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    });
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    // calculate persentage of downloading file
    
    int index = [self getFileDownloadInfoIndexWithTaskIdentifier:[downloadTask.taskDescription integerValue]];
    
    DownloadSetup *downloadSetup = [downloadArray objectAtIndex:index];
    
//    NSLog(@"log %d",index);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // Calculate the progress.
        downloadSetup.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        
//        NSLog(@"download progress %0.2f %% Call back Id  %@ ",downloadSetup.downloadProgress*100,downloadSetup.callbackId);

        // send callback id and progress by below cordova CDVPluginResult
        NSMutableDictionary* progressObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [progressObj setObject:[NSNumber numberWithInteger:totalBytesWritten] forKey:@"bytesReceived"];
        [progressObj setObject:[NSNumber numberWithInteger:totalBytesExpectedToWrite] forKey:@"totalBytesToReceive"];
        [progressObj setObject:downloadSetup.callbackId forKey:@"callbackId"];
        NSMutableDictionary* resObj = [NSMutableDictionary dictionaryWithCapacity:1];
        [resObj setObject:progressObj forKey:@"progress"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resObj];
        result.keepCallback = [NSNumber numberWithInteger: TRUE];
        [self.commandDelegate sendPluginResult:result callbackId:downloadSetup.callbackId];
    }];
    
}


@end
