//
//  PLVDemoSettingsViewController.m
//  PLV-ios-client-demo
//
//  Copyright (c) 2013 Polyv Inc. All rights reserved.
//

#import "PLVDemoViewController.h"
#import "PLVDemoSettingsViewController.h"

@interface PLVDemoSettingsViewController ()

@end

@implementation PLVDemoSettingsViewController

- (void)viewDidLoad
{
    self.remoteURLField.text = [[NSUserDefaults standardUserDefaults] valueForKey:PLVRemoteURLDefaultsKey];
    [self.remoteURLField becomeFirstResponder];
}

#pragma mark - IBActions
- (IBAction)flipUI:(id)sender
{
    NSURL* remoteURL = [NSURL URLWithString:_remoteURLField.text];
    if (!(remoteURL && [[remoteURL scheme] hasPrefix:@"http"])) {
        _remoteURLField.textColor = [UIColor redColor];
        return;
    }

    [[NSUserDefaults standardUserDefaults] setValue:_remoteURLField.text
                                             forKey:PLVRemoteURLDefaultsKey];
    [_remoteURLField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    _remoteURLField.textColor = [UIColor blackColor];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self flipUI:self];
    return YES;
}

@end
