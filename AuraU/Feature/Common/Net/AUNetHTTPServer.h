//
//  AUNetHTTPServer.h
//  AuraU
//
//  Created by Army on 15-2-28.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"
@interface AUNetHTTPServer : NSObject
{
    HTTPServer *_httpServer;
}

+ (AUNetHTTPServer *)sharedHttpServerEngine;

// HTTP server
@property (nonatomic, readonly) NSString *localServerURI;
- (BOOL)startHTTPServer:(NSError *)error;
- (void)stopHTTPServer;

@end
