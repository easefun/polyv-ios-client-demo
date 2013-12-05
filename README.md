polyv-ios-client-demo
=====================
An iOS resumable uploading client demo for Polyv Video Cloud.


```code
#import "PLVKit.h"
PLVAssetData* uploadData = [[PLVAssetData alloc] initWithAsset:asset];

PLVResumableUpload *upload = [[PLVResumableUpload alloc] initWithURL:[self endpoint] data:uploadData fingerprint:fingerprint writeToken:@""];

...


[upload start];


```
