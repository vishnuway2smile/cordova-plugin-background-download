Cordova Background Download Plug-in
===================================

Cordova plugin to download files in app background.

### Plugin's Purpose
This cordova plug-in can be used for applications, who rely on continuous network communication independent of from direct user interactions and remote downloads.

## Overview
1. [Supported Platforms](#supported-platforms)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Examples](#examples)

## Supported Platforms
- __iOS__


## Installation
The plugin can either be installed from git repository, from local file system through the [Command-line Interface][CLI]. Or cloud based through [PhoneGap Build][PGB].

### Local development environment
From master:
```bash
# ~~ from master branch ~~
cordova plugin add https://github.com/vishnuway2smile/cordova-plugin-background-download.git
```
from a local folder:
```bash
# ~~ local folder ~~
cordova plugin add <local path>
```

To remove the plug-in, run the following command:
```bash
cordova plugin remove cordova-plugin-background-download
```


## Usage
The plugin creates the object `BackgroundDownload` with  the following methods:

```javascript
1. startDownload(successcallback, errorcallback,url)
2. cancelDownload(successcallback, errorcallback,callbackId)
3. pauseDownload(successcallback, errorcallback,callbackId)
4. resumeDownload(successcallback, errorcallback,callbackId)
5. statusOfDownload(successcallback, errorcallback,callbackId)
```
### Plugin initialization
The plugin and its methods are not available before the *deviceready* event has been fired.

```javascript
document.addEventListener('deviceready', function () {
    // BackgroundDownload is now available
}, false);
```

### Start the download

 `BackgroundDownload.startDownload(successcallback, errorcallback,url)`, this method initialize the download using background thread. And also It returns thread id and progress percentage. Have to save callbackId for other download actions 
 
The method works as a function and gets the following arguments:
 - url: file url to download
 - successcallback: method to get callback of the download complete & progress
 - errorcallback: method to get callback of plugin failure or native errors
  
```javascript
    BackgroundDownload.startDownload(successcallback, errorcallback,url);
```

successcallback returns three objects one by one 

-First Call back Object : its Contains the Callbackid of the background thread 

```json
{
  data : {

  callback : {
        
        id : '<contains the call backid >'   
  }

  }  
}

```
-Second Call back Object : its Contains the Data Stream Progress of the background thread 

```json
{
  data : {

  progress : {
        
        bytesReceived : '<contains the bytes to receive >',
        totalBytesToReceive : '<contains the total bytes to receive>',
  }

  }  
}

```

-Third Call back Object : its Contains the Download file location 

```json
{
  data : {

  complete : {
        
        path : '<File Path>',
     
  }

  }  
}

```

Refer the Sample App to Handle the Callbacks


### Stop the download

 `BackgroundDownload.cancelDownload(successcallback, errorcallback,callbackId)`, this method stop the download and kills the background thread by callbackId.

```javascript
    BackgroundDownload.cancelDownload(successcallback, errorcallback,callbackId);
```


### Pause the download

 `BackgroundDownload.pauseDownload(successcallback, errorcallback,callbackId)`, this method Pause the download and makes the  background thread in suspend mode by callbackId.

```javascript
    BackgroundDownload.pauseDownload(successcallback, errorcallback,callbackId);
```

### Resume the download

 `BackgroundDownload.resumeDownload(successcallback, errorcallback,callbackId)`, this method Resume the download and makes the background thread in download mode by callbackId.

```javascript
    BackgroundDownload.resumeDownload(successcallback, errorcallback,callbackId);
```

### Status of the download

 `BackgroundDownload.statusOfDownload(successcallback, errorcallback,callbackId)`, this method get's the status of the download by callbackId.
 
 The method works as a function and gets the following arguments:
 - successcallback: method to get callback of the download progress
 - errorcallback: method to get callback of plugin failure or native errors
  
```javascript
    BackgroundDownload.statusOfDownload(successcallback, errorcallback,callbackId);
```    
## Examples 

[Cordova Background Download Example App](https://github.com/vishnuway2smile/backgroundDownloadPlugin)
   




