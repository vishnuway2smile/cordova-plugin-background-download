//
//  BackgroundDownload.h
//
//
//  Created by way2smile
//
//  Multiple background download plugin
//
#import <Cordova/CDV.h>

@interface BackgroundDownload : CDVPlugin <NSURLSessionDelegate>


@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

/*!
 * @brief declaration initiate download in this method by call from Java Script
 * @param CDVInvokedUrlCommand from Cordova
 */
- (void) startDownload:(CDVInvokedUrlCommand*)command;

@end
