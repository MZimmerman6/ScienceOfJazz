//
//  MulticastClient.h
//  MultiTest
//
//  Created by Matthew Prockup on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


//////////////
//          //
//  Usage   //
//          //
/////////////////////////////////////////////////////////////////////////////////////////////
//
//  Create the client:
//      MulticastClient* client = [[MulticastClient alloc] init];
//
//  Setup the multicast parameters
//      [client startMulticastListenerOnPort:12345 withAddress:@"239.254.254.251"];
//
//  Start the listener thread
//      [client startListen];
//
//  Poll for most recent reveived data
//      NSData* buffer = [client getCurrentData];
//
////////////////////////////////////////////////////////////////////////////////////////////




#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
//#define kMulticastAddress "239.255.255.251"
//#define kPortNumber 1234
#define kBufferSize 250
#define kMaxSockets 16

@interface MulticastClient : NSObject
{
    int sock_fd;
    struct sockaddr_in addr;
    NSMutableData* data;
    NSString* address;
    const char* kMulticastAddress;
    int kPortNumber;
    NSMutableArray* fuckyeah;
    struct ip_mreq multicast_request;
    float soundFieldAdd;
    float soundFieldMult;
    float takeOverLocalize;
    float takeOverVU;
    float band1;
    float band2;
    float band3;
    float band4;
    float blobHighlight;
    BOOL socketOpen;
    BOOL listenStarted;
}
-(BOOL)startMulticastListenerOnPort:(int)p withAddress:(NSString*)a; //setup the multicast session
-(void)startListen; //spawns a listener thread inside the object.  
-(NSData*)getCurrentData; //returns the latest data
-(NSMutableArray*)getCurrentLocations;
-(float)getSoundFieldMult;
-(float)getSoundFieldAdd;
-(bool)getTakeOverLocalize;
-(bool)getTakeOverVU;
-(float)getBand1;
-(float)getBand2;
-(float)getBand3;
-(float)getband4;
-(float)getBlobHighlight;
-(void)closeSocket;
-(BOOL)isSocketOpen;
@property (retain) NSData* data;

@end
