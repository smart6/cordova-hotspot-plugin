//
//  HotSpot.m
//  
//
//  Created by Mohankumar Balakrishnan on 2/19/18.
//
#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <Cordova/CDV.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "getgateway.h"

#import "HotSpot.h"

@implementation HotSpot
- (NSString *) getSSID {
    NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef) @"en0");
    return [info valueForKey:@"SSID"];
}
- (NSString *) getWiFiAddress {
    NSString *address = @"0.0.0.0";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 1;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
                
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}
- (NSString *) getWiFiRouterAddress {
    NSString *address = @"0.0.0.0";
    struct in_addr gatewayaddr;
    int r = getdefaultgateway(&(gatewayaddr.s_addr));
    if(r>=0){
        address = [NSString stringWithFormat: @"%s",inet_ntoa(gatewayaddr)];
    }
    return address;
}
- (void)getConnectionInfo:(CDVInvokedUrlCommand*)command{
    NSString *ssid = [NSString stringWithFormat:@"\"%@\"",[self getSSID]];
    NSString *wifiAddress = [NSString stringWithFormat:@"\"%@\"",[self getWiFiAddress]];
    NSDictionary *connectionInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             ssid, @"SSID",
                             wifiAddress, @"IPAddress",
                             nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:connectionInfo];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}
- (void)getNetConfig:(CDVInvokedUrlCommand*)command{
    NSString *wifiAddress = [NSString stringWithFormat:@"\"%@\"",[self getWiFiAddress]];
    NSString *dnsAddress = [NSString stringWithFormat:@"\"%@\"",[self getWiFiRouterAddress]];
    NSDictionary *netConfig = [NSDictionary dictionaryWithObjectsAndKeys:
                                    wifiAddress, @"deviceIPAddress",
                                    dnsAddress, @"gatewayIPAddress",
                                    nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:netConfig];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
