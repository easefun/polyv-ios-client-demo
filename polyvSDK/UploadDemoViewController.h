//
//  PLVDemoViewController.h
//  PLV-ios-client-demo
//
//  Copyright (c) 2013 Polyv Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadDemoViewController : UIViewController <UIImagePickerControllerDelegate>

@property (strong,nonatomic) IBOutlet UIButton* chooseFileButton;
@property (strong,nonatomic) IBOutlet UIProgressView* progressBar;
@property (strong,nonatomic) IBOutlet UILabel* statusLabel;
@property (strong,nonatomic) IBOutlet UITextView* urlTextView;
@property (strong,nonatomic) IBOutlet UIImageView* imageView;
@property (strong,nonatomic) IBOutlet UIView* imageOverlay;

- (IBAction)chooseFile:(id)sender;
@end
