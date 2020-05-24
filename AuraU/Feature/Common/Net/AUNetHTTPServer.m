//
//  AUNetHTTPServer.m
//  AuraU
//
//  Created by Army on 15-2-28.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUNetHTTPServer.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "AUNetHTTPConnection.h"

@implementation AUNetHTTPServer

+ (AUNetHTTPServer *)sharedHttpServerEngine
{
    static AUNetHTTPServer *serverEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serverEngine = [[AUNetHTTPServer alloc]init];
    });
    return serverEngine;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // HTTP server
        _httpServer = [[HTTPServer alloc] init];
        [_httpServer setType:@"_http._tcp."];
        [_httpServer setPort:kHTTPServerPort];


        NSString *strFilePath = [AUSerialization getFileDocument];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:strFilePath]) {
            [fm createDirectoryAtPath:strFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSLog(@"Setting document root: %@", strFilePath);
        [_httpServer setDocumentRoot:strFilePath];
        [_httpServer setConnectionClass:[AUNetHTTPConnection class]];

    }
    return self;
}

#pragma mark - HTTP Server Methods

- (NSString *)localServerURI
{

    NSString *uri = [NSString stringWithFormat:@"http://%@:%d", [self getIPAddress], kHTTPServerPort];
    return uri;
}

- (BOOL)startHTTPServer:(NSError *)error
{
    if ( [_httpServer start:&error] ) {
        NSLog(@"Started HTTP server on port %hu", [_httpServer listeningPort]);
        return YES;
    } else {
        NSLog(@"Error: %@", error);
        return NO;
    }
}

- (void)stopHTTPServer
{
    [_httpServer stop:YES];
}

#pragma mark - Utility Methods

- (NSString *)getIPAddress
{
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



@end
