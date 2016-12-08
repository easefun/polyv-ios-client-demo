//
//  PLVDemoViewController.m
//  PLV-ios-client-demo
//
//  Copyright (c) 2013 Polyv Inc. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/ALAsset.h>
#import "PLVKit.h"
#import "UploadDemoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SkinVideoViewController.h"
#import "PolyvSettings.h"
#import "PvVideo.h"

#define PLVRemoteURLDefaultsKey @"PLVRemoteURL"

@interface UploadDemoViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
    @property (strong, nonatomic) ALAssetsLibrary* assetsLibrary;
    @property (nonatomic, strong) SkinVideoViewController *videoPlayer;
    @property NSString*vid;
@end

@implementation UploadDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    [self.imageOverlay setHidden:YES];
    [self.progressBar setProgress:.0];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{PLVRemoteURLDefaultsKey: @"https://upload.polyv.net:1081/files/"}];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    
    [singleTap setNumberOfTapsRequired:1];
    [self.urlTextView addGestureRecognizer:singleTap];
    
    NSLog(@"新版本上传SDK(https://github.com/easefun/polyv-ios-upload),通过CDN服务器中转提高稳定能和上传速度");
    
}

-(void)handleSingleTap{
    if (!self.videoPlayer) {
        PvVideo *video = [PolyvSettings getVideo:self.vid];
        if([video available]){
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(0, 0, width, width*(9.0/16.0))];
            __weak typeof(self)weakSelf = self;
            [self.videoPlayer setDimissCompleteBlock:^{
                [weakSelf.videoPlayer stop];
                weakSelf.videoPlayer = nil;
            }];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"视频还没准备好"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
        
    }
    [self.videoPlayer showInWindow];
    [self.videoPlayer setVid:self.vid level:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //NSString* text = [NSString stringWithFormat:NSLocalizedString(@"for upload to:\n%@",nil), [self endpoint]];
    //[self.urlTextView setText:text];
}
- (IBAction)closeButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - IBAction Methods
- (IBAction)chooseFile:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    //imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];

    
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSURL *outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"]];
    //compress tip
    UIView*_hudView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 170, 170)];
    _hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _hudView.clipsToBounds = YES;
    _hudView.layer.cornerRadius = 10.0;
    
    UIActivityIndicatorView*_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.frame = CGRectMake(65, 40, _activityIndicatorView.bounds.size.width, _activityIndicatorView.bounds.size.height);
    [_hudView addSubview:_activityIndicatorView];
    [_activityIndicatorView startAnimating];
    
    UILabel*_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.adjustsFontSizeToFitWidth = YES;
    _captionLabel.textAlignment = NSTextAlignmentCenter;
    _captionLabel.text = @"正在压缩视频...";
    [_hudView addSubview:_captionLabel];
    
    [picker.view addSubview:_hudView];
    
    
    [self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [_hudView removeFromSuperview];
         });
         
         if (exportSession.status == AVAssetExportSessionStatusCompleted)
         {
             [self.urlTextView setText:nil];
             [self.imageView setImage:nil];
             [self.progressBar setProgress:.0];
             [self dismissViewControllerAnimated:YES
                                      completion:^{
                                          
                                          NSString* type = [info valueForKey:UIImagePickerControllerMediaType];
                                          CFStringRef typeDescription = (UTTypeCopyDescription((__bridge CFStringRef)(type)));
                                          NSString* text = [NSString stringWithFormat:NSLocalizedString(@"Uploading %@…", nil), typeDescription];
                                          CFRelease(typeDescription);
                                          [self.statusLabel setText:text];
                                          [self.imageOverlay setHidden:NO];
                                          [self.chooseFileButton setEnabled:NO];
                                          
                                          [self uploadVideoFromURL:outputURL];
                                          
                                          
                                      }];

         }
         else
         {
             printf("error\n");
             
         }
     }];
    
    }
/**压缩视频大小*/
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}

/**使用文件地址上传*/

- (void)uploadVideoFromURL:(NSURL*)url
{
    PLVData*uploadData = [[PLVData alloc] initWithData:[NSData dataWithContentsOfURL:url]];

    PLVResumableUpload *upload = [[PLVResumableUpload alloc] initWithURL:[self endpoint] data:uploadData fingerprint:[url absoluteString]];
    NSString * ext = @"mov";
    NSMutableDictionary* extraInfo = [[NSMutableDictionary alloc]init];
    [extraInfo setValue:ext forKey:@"ext"];
    [extraInfo setValue:@"1357359024647" forKey:@"cataid"];
    [extraInfo setValue:@"polyvsdk" forKey:@"title"];
    [extraInfo setValue:@"polyvsdk upload demo video" forKey:@"desc"];
    [upload setExtraInfo:extraInfo];
    upload.progressBlock = [self progressBlock];
    upload.resultBlock = [self resultBlock];
    upload.failureBlock = [self failureBlock];
    [upload start];
}
/**Asset上传**/
- (void)uploadVideoFromAsset:(NSDictionary*)info
{
    NSURL *assetUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    NSString *fingerprint = [assetUrl absoluteString];

    [[self assetsLibrary] assetForURL:assetUrl
                          resultBlock:^(ALAsset* asset) {
                              self.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
                              self.imageView.alpha = .5;
                              PLVAssetData* uploadData = [[PLVAssetData alloc] initWithAsset:asset];
                              //PLVResumableUpload *upload = [[PLVResumableUpload alloc] initWithURL:[self endpoint] data:uploadData fingerprint:fingerprint writeToken:@"Y07Q4yopIVXN83n-MPoIlirBKmrMPJu0"];
                              
                              PLVResumableUpload *upload = [[PLVResumableUpload alloc] initWithURL:[self endpoint] data:uploadData fingerprint:fingerprint];
                              NSString * surl = [assetUrl absoluteString];
                              NSString * ext = [surl substringFromIndex:[surl rangeOfString:@"ext="].location + 4];
                              NSMutableDictionary* extraInfo = [[NSMutableDictionary alloc]init];
                              [extraInfo setValue:ext forKey:@"ext"];
                              [extraInfo setValue:@"polyvsdk" forKey:@"title"];
                              [extraInfo setValue:@"polyvsdk upload demo video" forKey:@"desc"];
                              [upload setExtraInfo:extraInfo];
                              upload.progressBlock = [self progressBlock];
                              upload.resultBlock = [self resultBlock];
                              upload.failureBlock = [self failureBlock];
                              [upload start];
                          }
                         failureBlock:^(NSError* error) {
                             NSLog(@"Unable to load asset due to: %@", error);
                         }];
}

- (void(^)(NSInteger bytesWritten, NSInteger bytesTotal))progressBlock
{
    return ^(NSInteger bytesWritten, NSInteger bytesTotal) {
        float progress = (float)bytesWritten / (float)bytesTotal;
        if (isnan(progress)) {
            progress = .0;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressBar setProgress:progress];
        });
        
        
    };
}

- (void(^)(NSError* error))failureBlock
{
    return ^(NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Failed to upload file due to: %@", error);
            [self.chooseFileButton setEnabled:YES];
            NSString* text = self.urlTextView.text;
            text = [text stringByAppendingFormat:@"\n%@", [error localizedDescription]];
            [self.urlTextView setText:text];
            [self.statusLabel setText:NSLocalizedString(@"Failed!", nil)];
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil)
                                        message:[error localizedDescription]
                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
        });

        
    };
}

- (void(^)(NSString* vid))resultBlock
{
    return ^(NSString* vid) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.chooseFileButton setEnabled:YES];
             [self.imageOverlay setHidden:YES];
             self.imageView.alpha = 1;

             [self.urlTextView setText:[NSString stringWithFormat:@"点击播放 %@",vid]];
             self.vid = vid;

         });
       

        
       
        
        
        
        
    };
}

- (NSString*)endpoint
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:PLVRemoteURLDefaultsKey];
}

@end
