var exec = require('cordova/exec');

//  start download
exports.startDownload = function(success, error,url) {

    exec(success, error, "BackgroundDownload", "startDownload",[url]);
};

// cancel download
exports.cancelDownload = function(success, error,callbackid)  {

   exec(success, error, "BackgroundDownload", "cancelDownloadTask",[callbackid]);
};

// resume download
exports.resumeDownload = function(success, error,callbackid)  {

    exec(success, error, "BackgroundDownload", "resumeDownloadTask",[callbackid]);
};

// suspend download
exports.pauseDownload = function(success, error,callbackid)  {

	exec(success, error, "BackgroundDownload", "suspendDownloadTask",[callbackid]);
};

// return download status
exports.statusOfDownload = function(success, error,callbackid) {


 exec(success, error, "BackgroundDownload", "downloadStatus",[callbackid]);

};






