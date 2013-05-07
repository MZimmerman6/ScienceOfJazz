//
//  MulticastServer.m
//  MultiClientClassTest
//
//  Created by Matthew Prockup on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MulticastServer.h"

@implementation MulticastServer

-(BOOL)startMulticastServerOnPort:(int)p withAddress:(NSString*)a
{
    address = [[NSString alloc] initWithString:a];
    kMulticastAddress = [address UTF8String];
    kPortNumber = p;
    
    if(networkPrepared)
        return true;
    
    // Obtain list of all network interfaces
    
    if ( getifaddrs(&addrs) < 0 ) {
        // Error occurred
        return 0;
    }
    
    // Loop through interfaces, selecting those AF_INET devices that support multicast, but aren't loopback or point-to-point
    cursor = addrs;
    number_sockets = 0;
    
    while ( cursor != NULL && number_sockets < kMaxSockets ) {
        if ( cursor->ifa_addr->sa_family == AF_INET 
            && !(cursor->ifa_flags & IFF_LOOPBACK) 
            && !(cursor->ifa_flags & IFF_POINTOPOINT) 
            &&  (cursor->ifa_flags & IFF_BROADCAST) ) {
            
            // Create socket
            sock_fds[number_sockets] = socket(AF_INET, SOCK_DGRAM, 0);
            if ( sock_fds[number_sockets] == -1 ) {
                // Error occurred
                return 0;
            }
            if ( setsockopt(sock_fds[number_sockets], IPPROTO_IP, IP_MULTICAST_IF, &((struct sockaddr_in *)cursor->ifa_addr)->sin_addr, sizeof(struct in_addr)) != 0  ) {
                // Error occurred
                return 0;
            }
            // We're not interested in receiving our own messages, so we can disable loopback (don't rely solely on this - in some cases you can still receive your own messages)
            u_char loop = 0;
            if ( setsockopt(sock_fds[number_sockets], IPPROTO_IP, IP_MULTICAST_LOOP, &loop, sizeof(loop)) != 0 ) {
                // Error occurred
                return 0;
            }
            
            number_sockets++;
        }
        cursor = cursor->ifa_next;
    }
    
    // Initialise multicast address
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr(kMulticastAddress);
    addr.sin_port = htons(kPortNumber);
    
    networkPrepared = true;
    socketOpen = true;
    return true;
    
    
}
-(BOOL)sendMulticast:(float*)data withLength:(int)lengthBytes
{
    
    /* output */
    if(!networkPrepared)
        return false;
    
    if(!socketOpen)
        return false;
    
    int i;
    int succ = 1;
    for ( i=0; i<number_sockets; i++ ) {
        
        //int num =  sendto(sock_fds[i], status, sizeof(status), 0, (struct sockaddr*)&addr, sizeof(addr));
        int num =  sendto(sock_fds[i], data, lengthBytes, 0, (struct sockaddr*)&addr, sizeof(addr));
        // printf("Sent through %d STATUS: %d\t", i, num);
        if ( num < 0 ) {
            succ = 0;
        }
    }
    // NSLog(@"Send Attempt SUCC:%d",succ);
    
    if (succ == 1) {
        NSLog(@"sent info");
        return true;
    }
    else
    {
        NSLog(@"failed to send info");
        return false;
    }
}


-(void)closeSocket
{
    for (int i=0; i<number_sockets; i++ ) {
        close(sock_fds[i]);
    }
    socketOpen = false;
    networkPrepared = false;
}




@end
