//
//  ViewController.m
//  OSCApp
//
//  Created by Brandon Millman on 2/27/13.
//  Copyright (c) 2013 Equinox. All rights reserved.
//

#import "ViewController.h"
#import "VVOSC.h"
#import <AudioToolbox/AudioToolbox.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

#define kPortNum 57121

@interface ViewController () <OSCDelegateProtocol, UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UIView *startView;
@property (nonatomic, strong) IBOutlet UIView *settingsView;
@property (nonatomic, weak) IBOutlet UITextField *addressField;
@property (nonatomic, weak) IBOutlet UITextField *portField;
@property (nonatomic, strong) OSCManager *manager;
@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.manager = [[OSCManager alloc] init];
    self.manager.delegate = self;
    [self.manager createNewInputForPort:kPortNum];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark - Private Methods

- (IBAction)startButtonPressed:(UIButton *)button {
    OSCMessage *message = [OSCMessage createWithAddress:@"/FromIPhoneRegister"];
    [message addString:[self getIPAddress]];
    [message addInt:kPortNum];
    [self sendMessage:message];
    
}

- (IBAction)settingsButtonPressed:(UIButton *)button {
    [UIView transitionFromView:self.startView
                        toView:self.settingsView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:nil
     ];
}

- (IBAction)backButtonPressed:(UIButton *)button {
    [UIView transitionFromView:self.settingsView
                        toView:self.startView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:nil
     ];
}

- (void)hideKeyboard {
    [self.addressField resignFirstResponder];
    [self.portField resignFirstResponder];
}

- (void)sendMessage:(OSCMessage *)message {
    OSCOutPort *outPort = [self.manager createNewOutputToAddress:self.addressField.text atPort:[self.portField.text integerValue]];
    [outPort sendThisMessage:message];
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

#pragma mark - OSCDelegateProtocol

- (void) receivedOSCMessage:(OSCMessage *)m {
    NSLog(@"Message Received");
    if ([m.address isEqualToString:@"/FromServerTreasureFound"]) {
    } else if ([m.address isEqualToString:@"/FromServerGameOver"]) {
    }
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

#pragma mark - UITextFieldDelegate

@end
