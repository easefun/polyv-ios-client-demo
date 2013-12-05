//
//  PLVDemoSettingsViewController.h
//  PLV-ios-client-demo
//
//  Copyright (c) 2013 Polyv Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PLVRemoteURLDefaultsKey @"PLVRemoteURL"

@interface PLVDemoSettingsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField* remoteURLField;

- (IBAction)flipUI:(id)sender;

@end
