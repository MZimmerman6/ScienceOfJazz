//
//  MulticastClient.m
//  MultiTest
//
//  Created by Matthew Prockup on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MulticastClient.h"

@implementation MulticastClient

@synthesize data;

-(BOOL)startMulticastListenerOnPort:(int)p withAddress:(NSString*)a
{
    soundFieldAdd = 0;
    soundFieldMult = 1;
    
    signal(SIGPIPE, SIG_IGN);
    
    fuckyeah = [[NSMutableArray alloc] init];
    address = [[NSString alloc] initWithString:a];
    kMulticastAddress = [address UTF8String];
    kPortNumber = p;
    //[super init];
    // Create socket
    sock_fd = socket(AF_INET, SOCK_DGRAM, 0);
    if ( sock_fd == -1 ) {
        // Error occurred
        return false;
    }
    
    // Create address from which we want to receive, and bind it
    
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons(kPortNumber);
    if ( bind(sock_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0 ) {
        // Error occurred
        return false;
    }
    
    // Obtain list of all network interfaces
    struct ifaddrs *addrs;
    if ( getifaddrs(&addrs) < 0 ) {
        // Error occurred
        return false;
    }
    
    // Loop through interfaces, selecting those AF_INET devices that support multicast, but aren't loopback or point-to-point
    const struct ifaddrs *cursor = addrs;
    while ( cursor != NULL ) {
        if ( cursor->ifa_addr->sa_family == AF_INET 
            && !(cursor->ifa_flags & IFF_LOOPBACK) 
            && !(cursor->ifa_flags & IFF_POINTOPOINT) 
            &&  (cursor->ifa_flags & IFF_MULTICAST) ) 
        {
            
            // Prepare multicast group join request
            struct ip_mreq multicast_req;
            memset(&multicast_req, 0, sizeof(multicast_req));
            multicast_req.imr_multiaddr.s_addr = inet_addr(kMulticastAddress);
            multicast_req.imr_interface = ((struct sockaddr_in *)cursor->ifa_addr)->sin_addr;
            multicast_request = multicast_req;
            // Workaround for some odd join behaviour: It's perfectly legal to join the same group on more than one interface,
            // and up to 20 memberships may be added to the same socket (see ip(4)), but for some reason, OS X spews 
            // 'Address already in use' errors when we actually attempt it.  As a workaround, we can 'drop' the membership
            // first, which would normally have no effect, as we have not yet joined on this interface.  However, it enables
            // us to perform the subsequent join, without dropping prior memberships.
            setsockopt(sock_fd, IPPROTO_IP, IP_DROP_MEMBERSHIP, &multicast_req, sizeof(multicast_req));
            
            // Join multicast group on this interface
            if ( setsockopt(sock_fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &multicast_req, sizeof(multicast_req)) < 0 ) {
                // Error occurred
                return false;
            }
        }
        cursor = cursor->ifa_next;
    }
    NSLog(@"ready.");
    data = [[NSMutableData alloc] init];
    socketOpen = true;
    //[super init];
    return true;
}
-(void)startListen
{
    [NSThread detachNewThreadSelector:@selector(listenLoop:) toTarget:self withObject:nil];
}

-(void)listenLoop:(id)param
{
    
//    NSDate *start = [NSDate date];
    socklen_t addr_len = sizeof(addr);
    int cnt = 0;
    
    float buffer [kBufferSize];
    //char buffer[kBufferSize];   
    BOOL error = false;
//    NSMutableArray* jawnArray = [[NSMutableArray alloc] init];
//    NSMutableArray* jawnDataArray = [[NSMutableArray alloc] init];
//    NSTimeInterval timeInterval;
    while(!error&&socketOpen)
    {
        
        // Receive a message, waiting if there's nothing there yet
        int bytes_received = recvfrom(sock_fd, buffer, sizeof(float)*kBufferSize, 0, (struct sockaddr*)&addr, &addr_len);
        //NSLog(@"BUFFER JAWN: %f",buffer[1]);
        if ( bytes_received < 0 ) {
            NSLog(@"error receiving");
            error=true;
            
        }
       // NSLog(@"GOT BYTES %f%f%f%f",buffer[0],buffer[2],buffer[3],buffer[4]);
        
        if(buffer[0]==1 && buffer[1]==2 && buffer[2]==3 && buffer[3]==4)
        {
            [data setLength:0];
            data = [NSMutableData dataWithBytes:(const void *)buffer length:sizeof(float)*kBufferSize];
//            data = [NSMutableData dataWithBytesNoCopy:( void *)buffer length:sizeof(float)*kBufferSize];
            takeOverLocalize = buffer[239];
            soundFieldAdd = buffer[240];
            soundFieldMult = buffer[241];
            takeOverVU = buffer[242];
            band1 = buffer[243];
            band2 = buffer[244];
            band3 = buffer[245];
            band4 = buffer[246];
            blobHighlight = buffer[247];
        }
        
        if(buffer[0]==4 && buffer[1]==3 && buffer[2]==2 && buffer[3]==1)
        {
            [fuckyeah addObject:[NSData dataWithBytes:(const void *)buffer length:sizeof(float)*16]];
        }
        cnt++;
    }
     close(sock_fd);
    
}

-(NSData*)getCurrentData
{
    NSData* copy = [[NSData alloc] initWithData:data];
    return copy;
}

-(NSMutableArray*)getCurrentLocations
{
    NSMutableArray* copy = [[NSMutableArray alloc]initWithArray:fuckyeah];
    [fuckyeah removeAllObjects];
    return copy;
}
-(float)getSoundFieldAdd
{
    return soundFieldAdd;
}
-(float)getSoundFieldMult
{
    return soundFieldMult;
}
-(bool)getTakeOverVU{
    if(takeOverVU == 1)
        return true;
    else
        return false;
}

-(bool)getTakeOverLocalize{
    if(takeOverLocalize == 1)
        return true;
    else
        return false;
}
-(float)getBand1{
    return band1;
}
-(float)getBand2{
    return band2;
}
-(float)getBand3{
    return band3;
}
-(float)getband4{
    return band4;
}
-(float)getBlobHighlight{
    return blobHighlight;
}

-(void)closeSocket
{
    socketOpen = false;
    listenStarted = false;
}

-(BOOL)isSocketOpen{
    return socketOpen;
}



@end
