//
//  MulticastServer.h
//  MultiClientClassTest
//
//  Created by Matthew Prockup on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//////////////
//          //
//  Usage   //
//          //
/////////////////////////////////////////////////////////////////////////////////////////////
//
//  Create the server:
//      MulticastServer* server = [[MulticastServer alloc] init];
//
//  Setup the multicast parameters:
//      [client startMulticastServerOnPort:12345 withAddress:@"239.254.254.251"];
//
//  Send data:
//      BOOL success = [server sendMulticast:(float*)data withLength:(int)lengthBytes];
//      
//
////////////////////////////////////////////////////////////////////////////////////////////



#import <Foundation/Foundation.h>
//Network
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <time.h>
#define kMaxSockets 16

@interface MulticastServer : NSObject
{
    NSString* address;
    const char* kMulticastAddress;
    int kPortNumber;
    BOOL networkPrepared;
    int sock_fds[kMaxSockets];
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    struct sockaddr_in addr;
    int number_sockets;
    BOOL socketOpen;
}
-(BOOL)startMulticastServerOnPort:(int)p withAddress:(NSString*)a;
-(BOOL)sendMulticast:(float*)data withLength:(int)length;
-(void)closeSocket;


@end
