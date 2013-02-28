//
//  ViewController.m
//  OSCApp
//
//  Created by Brandon Millman on 2/27/13.
//  Copyright (c) 2013 Equinox. All rights reserved.
//

#import "ViewController.h"
#import "VVOSC.h"

@interface ViewController () <OSCDelegateProtocol, UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *addressField;
@property (nonatomic, weak) IBOutlet UITextField *portField;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) OSCManager *manager;
@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isPlaying = NO;
    self.manager = [[OSCManager alloc] init];
    self.manager.delegate = self;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark - Private Methods

- (IBAction)startStopButtonPressed:(UIButton *)button {
    OSCOutPort *outPort = [self.manager createNewOutputToAddress:self.addressField.text atPort:[self.portField.text integerValue]];
    OSCMessage *message = [OSCMessage createWithAddress:@"/FromIPhoneStartStop"];
    [message addBOOL:YES];
    [outPort sendThisMessage:message];
    
    if (self.isPlaying) {
        [button setTitle:@"Start" forState:UIControlStateNormal];
    } else {
        [button setTitle:@"Stop" forState:UIControlStateNormal];
    }
    self.isPlaying = !self.isPlaying;
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    OSCOutPort *outPort = [self.manager createNewOutputToAddress:self.addressField.text atPort:[self.portField.text integerValue]];
    OSCMessage *message = [OSCMessage createWithAddress:@"/FromIPhoneVolume"];
    [message addFloat:slider.value];
    [outPort sendThisMessage:message];
}

- (void)hideKeyboard {
    [self.addressField resignFirstResponder];
    [self.portField resignFirstResponder];
}
    
#pragma mark - UITextFieldDelegate

#pragma mark - OSCDelegateProtocol

- (void) receivedOSCMessage:(OSCMessage *)m {
    NSLog(@"Message Received");
}

@end
