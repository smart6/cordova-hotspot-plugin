//
//  HotSpot.h
//  
//
//  Created by Mohankumar Balakrishnan on 2/19/18.
//

#import <Cordova/CDV.h>

@interface HotSpot : CDVPlugin

- (void)getConnectionInfo:(CDVInvokedUrlCommand*)command;
- (void)getNetConfig:(CDVInvokedUrlCommand*)command;

@end
