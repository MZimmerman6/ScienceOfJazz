//
//  AppDelegate.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 1/26/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import "AppDelegate.h"
//#import "WelcomeViewController.h"
#import "SOMViewController.h"

#define defaultFFTSize 1024

@implementation AppDelegate

@synthesize window = _window;
@synthesize welcome = _welcome;
@synthesize navigationController = _navigationController;
@synthesize client;
@synthesize server;
@synthesize soundField;
@synthesize somLoaded;
@synthesize takeOver;
@synthesize controlOverlay;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSLog(@"launched");
    somLoaded = NO;
    appSleptAfterSOM = NO;
    takenOver = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        _welcome = [[SOMViewController alloc] initWithNibName:@"SOMViewController_iPhone5" bundle:nil];
    } else {
        _welcome = [[SOMViewController alloc] initWithNibName:@"SOMViewController" bundle:nil];
    }
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_welcome];
    [_navigationController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self.window addSubview:_navigationController.view];
    [self.window makeKeyAndVisible];
    [_navigationController setNavigationBarHidden:YES];
    self.window.rootViewController = _navigationController;
    [application setIdleTimerDisabled:YES];

    NSLog(@"here");
    
    
    
    [self setupMulticast];
    audioIn = [[AudioInput alloc] initWithDelegate:self];
    
    fft = [[AccelFFT alloc] init];
    [fft fftSetSize:defaultFFTSize];
    
    soundFieldUpdating = NO;
    chromaUpdating = NO;
    localizationUpdating = NO;
    spectrumUpdating = NO;
    audioUpdating = NO;
    imageUpdating = NO;
    
    [audioIn start];
    
    fftMag = calloc(ceilf(defaultFFTSize/2), sizeof(float));
    fftPhase = calloc(ceilf(defaultFFTSize/2), sizeof(float));
    complexBuffer = fftMag = calloc(kInputNumSamples*2, sizeof(float));
    
    local = [[Localization alloc] init];
    
    takeOverCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTakeOver) userInfo:nil repeats:YES];
    highlightTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkLocationHighlight) userInfo:nil repeats:YES];
    localizationTakeoverTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkLocalizationTakeover) userInfo:nil repeats:YES];
    
    if (screenBounds.size.height == 568) {
        takeOver = [[TakeOverViewController alloc] initWithNibName:@"TakeOverViewController_iPhone5" bundle:nil];
    } else {
        takeOver = [[TakeOverViewController alloc] initWithNibName:@"TakeOverViewController_iPhone5" bundle:nil];
    }
    userLocation = CGPointMake(320/2.0, 416/2.0);
    
    
    roomDimensions = CGPointMake(516, 779);
    
    buffIndex = 0;
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    NSLog(@"did enter background");
//    if (soundField) {
//        NSLog(@"closing soundfield stuff");
//        [soundField soundFieldAppSleeping];
//    }
    if (somLoaded) {
        //exit the application if the science of music portion has been loaded
        // if not the app will not function properly on restart and may end up crashing
        appSleptAfterSOM = YES;
        [server closeSocket];
        [client closeSocket];
        NSLog(@"SocketsClosed");
    }
////    [client closeSocket];
//    
//    client = [[MulticastClient alloc] init];
//    server = [[MulticastServer alloc] init];
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [self setupMulticast];
    if (soundField) {
        [soundField soundFieldAppUnSleep];
    }
    
    if (appSleptAfterSOM) {
        [self restartMulticastAfterSocketClose];
    }
//    [client closeSocket];
}

-(void)setupMulticast
{
	client = [[MulticastClient alloc] init];
    BOOL clientSuccess = [client startMulticastListenerOnPort:12345 withAddress:@"239.254.254.251"];
	
    if(clientSuccess)
    {
        [client startListen];
        NSLog(@"Client joined multicast group. Fuck Yeah!");
    }
    else
    {
        NSLog(@"Client FAILED to join multicast group");
    }
    
    
    server = [[MulticastServer alloc] init];
	BOOL serverSuccess = [server startMulticastServerOnPort:12345 withAddress:@"239.254.254.251"];
    if(serverSuccess)
    {
        NSLog(@"Server joined multicast group. Fuck Yeah!");
    }
    else
    {
        NSLog(@"Server FAILED to join multicast group");
    }
}

-(void)restartMulticastAfterSocketClose
{
	//client = [[MulticastClient alloc] init];
    BOOL clientSuccess = [client startMulticastListenerOnPort:12345 withAddress:@"239.254.254.251"];
	
    if(clientSuccess)
    {
        [client startListen];
        NSLog(@"Client joined multicast group. Fuck Yeah!");
    }
    else
    {
        NSLog(@"Client FAILED to join multicast group");
    }
    
    
    //server = [[MulticastServer alloc] init];
	BOOL serverSuccess = [server startMulticastServerOnPort:12345 withAddress:@"239.254.254.251"];
    if(serverSuccess)
    {
        NSLog(@"Server joined multicast group. Fuck Yeah!");
    }
    else
    {
        NSLog(@"Server FAILED to join multicast group");
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (connection == chromaConnection) {
        chromaUpdating = NO;
        NSLog(@"Chroma connection failed");
    } else if (connection == spectrumConnection) {
        spectrumUpdating = NO;
        NSLog(@"Spectrum connection failed");
    } else if (connection == audioConnection) {
        audioUpdating = NO;
        NSLog(@"audio connection failed");
    } else if (connection == localizationConnection) {
        localizationUpdating = NO;
        NSLog(@"localization connection failed");
    } else if (connection == soundFieldConnection) {
        soundFieldUpdating = NO;
        NSLog(@"sound field connection failed");
    } else if (connection == imageConnection) {
        imageUpdating = NO;
        NSLog(@"image connection failed");
    }
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == chromaConnection) {
        [chromaData appendData:data];
    } else if (connection == spectrumConnection) {
        [spectrumData appendData:data];
    } else if (connection == audioConnection) {
        [audioData appendData:data];
    } else if (connection == localizationConnection) {
        [localizationData appendData:data];
    } else  if (connection == soundFieldConnection) {
        [soundFieldData appendData:data];
    } else if (connection == imageConnection) {
        [imageData appendData:data];
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection == chromaConnection) {
        chromaUpdating = NO;
        [self processAndUpdateChroma];
        NSLog(@"Chroma Connection Successful");
    } else if (connection == spectrumConnection) {
        spectrumUpdating = NO;
        [self processAndUpdateSpectrum];
        NSLog(@"Spectrum Connection Successful");
    } else if (connection == audioConnection) {
        audioUpdating = NO;
        [self processAndUpdateAudio];
        NSLog(@"Audio Connection Successful");
    } else if (connection == localizationConnection) {
        localizationUpdating = NO;
        [self processAndUpdateLocalization];
        NSLog(@"Localization Connection Successful");
    } else if (connection == soundFieldConnection) {
        soundFieldUpdating = NO;
        [self processAndUpdateSoundField];
        NSLog(@"SoundField Connection Successful");
    } else if (connection ==  imageConnection) {
        imageUpdating = NO;
        [self processAndUpdateSoundFieldBackground];
        NSLog(@"SoundField Image Connection Successful");
    }
}

-(void) updateFromServers {
    
    
    NSLog(@"getting Updates");
    spectrumURL = [[NSURL alloc] initWithString:@"http://jazz.ece.drexel.edu/ScienceOfJazz/Updates/getSpectrumData.php"];
    spectrumRequest = [[NSURLRequest alloc] initWithURL:spectrumURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
    chromaURL = [[NSURL alloc] initWithString:@"http://jazz.ece.drexel.edu/ScienceOfJazz/Updates/getChromaData.php"];
    chromaRequest = [[NSURLRequest alloc] initWithURL:chromaURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
    localizationURL = [[NSURL alloc] initWithString:@"http://jazz.ece.drexel.edu/ScienceOfJazz/Updates/getLocalData.php"];
    localizationRequest = [[NSURLRequest alloc] initWithURL:localizationURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
    audioURL = [[NSURL alloc] initWithString:@"http://jazz.ece.drexel.edu/ScienceOfJazz/Updates/getAudioData.php"];
    audioRequest = [[NSURLRequest alloc] initWithURL:audioURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
    soundFieldURL = [[NSURL alloc] initWithString:@"http://jazz.ece.drexel.edu/ScienceOfJazz/Updates/getSoundFieldData.php"];
    soundFieldRequest = [[NSURLRequest alloc] initWithURL:soundFieldURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    if (bounds.size.height == 568) {
        imageURL = [[NSURL alloc] initWithString:@"http://jazz.ece.drexel.edu/ScienceOfJazz/Images/mandell_iphone5.png"];
    } else {
        imageURL = [[NSURL alloc] initWithString:@"http://jazz.ece.drexel.edu/ScienceOfJazz/Images/mandell_iphone.png"];
    }
    imageRequest = [[NSURLRequest alloc] initWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    
    
    if (!chromaUpdating) {
        chromaData = [[NSMutableData alloc] init];
        chromaInfo = [[NSMutableDictionary alloc] init];
        chromaUpdating = YES;
        chromaConnection = [[NSURLConnection alloc] initWithRequest:chromaRequest delegate:self];
    }
    
    if (!spectrumUpdating) {
        spectrumData = [[NSMutableData alloc] init];
        spectrumInfo = [[NSMutableDictionary alloc] init];
        spectrumUpdating = YES;
        spectrumConnection = [[NSURLConnection alloc] initWithRequest:spectrumRequest delegate:self];
    }
    
    if (!localizationUpdating) {
        localizationData = [[NSMutableData alloc] init];
        localizationInfo = [[NSMutableDictionary alloc] init];
        localizationUpdating = YES;
        localizationConnection = [[NSURLConnection alloc] initWithRequest:localizationRequest delegate:self];
    }
    
    if (!audioUpdating) {
        audioData = [[NSMutableData alloc] init];
        audioInfo = [[NSMutableDictionary alloc] init];
        audioUpdating = YES;
        audioConnection = [[NSURLConnection alloc] initWithRequest:audioRequest delegate:self];
    }
    
    if (!soundFieldUpdating) {
        soundFieldData = [[NSMutableData alloc] init];
        soundFieldInfo = [[NSMutableDictionary alloc] init];
        soundFieldUpdating = YES;
        soundFieldConnection = [[NSURLConnection alloc] initWithRequest:soundFieldRequest delegate:self];
    }
    
    if (!imageUpdating) {
        imageData = [[NSMutableData alloc] init];
        imageUpdating = YES;
        imageConnection = [[NSURLConnection alloc] initWithRequest:imageRequest delegate:self];
    }
    
    
}

-(void) processAndUpdateAudio {
    
//    NSString *audioString = [[NSString alloc] initWithData:audioData encoding:NSUTF8StringEncoding];
    NSError *error;
    audioInfo = [NSJSONSerialization JSONObjectWithData:audioData options:NSJSONReadingAllowFragments error:&error];
    audioInfo = [audioInfo objectForKey:@"AudioInput"];
}

-(void) processAndUpdateChroma {
    NSError *error;
    chromaInfo = [[NSMutableDictionary alloc] init];
    chromaInfo = [NSJSONSerialization JSONObjectWithData:chromaData options:NSJSONReadingAllowFragments error:&error];
    [_welcome updateChromaViewController:chromaInfo];
    
    NSLog(@"%@",chromaInfo);
}

-(void) processAndUpdateSpectrum {
    
    NSError *error;
    spectrumInfo = [NSJSONSerialization JSONObjectWithData:spectrumData options:NSJSONReadingAllowFragments error:&error];
    [_welcome updateSpectrumViewController:spectrumInfo];
    

}


-(void) processAndUpdateLocalization {
//    NSString *audioString = [[NSString alloc] initWithData:localizationData encoding:NSUTF8StringEncoding];
    
    NSError *error;
    localizationInfo = [NSJSONSerialization JSONObjectWithData:localizationData options:NSJSONReadingAllowFragments error:&error];
//    NSLog(@"%@",localizationInfo);
    localizationInfo = [localizationInfo objectForKey:@"Localization"];
    [audioIn stop];
    [local updateLocalizationInformation:localizationInfo];
}

-(void) processAndUpdateSoundField {
    
    NSError *error;
    soundFieldInfo = [NSJSONSerialization JSONObjectWithData:soundFieldData options:NSJSONReadingAllowFragments error:&error];
    soundFieldInfo = [soundFieldInfo objectForKey:@"SoundField"];
    int shift = [[soundFieldInfo objectForKey:@"overlayShift"] intValue];
    int scaleFactor = [[soundFieldInfo objectForKey:@"scaleFactor"] intValue];
    [_welcome updateSoundFieldOverlayShift:shift andScaling:scaleFactor];
    
}

-(void) processAndUpdateSoundFieldBackground {
    soundFieldBackground = [UIImage imageWithData:imageData];
    [_welcome updateSoundFieldBackground:soundFieldBackground];
}

-(void) checkTakeOver {
    
    if ([client getTakeOverVU]) {
        if (!takenOver) {
            takenOver = YES;
            takeOverUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTakeOverView) userInfo:nil repeats:YES];
            [_welcome pushTakeOverController];
        }
    } else {
        if (takenOver) {
            [_welcome removeTakeOverController];
            [takeOverUpdateTimer invalidate];
            takenOver = NO;
        }
    }
    
}


-(void) removeControlView {
    takenOver = NO;
    [takeOverUpdateTimer invalidate];
    controlOverlay.backgroundColor  = [UIColor greenColor];
    [controlOverlay removeFromSuperview];
    NSLog(@"trying to remove");
}
-(void) setLocation:(CGPoint)point {
    
    NSLog(@"user selected location %f,%f",point.x,point.y);
    userLocation = point;
    
}

-(void) updateTakeOverView {
    NSLog(@"should update takeover view");

    float vuValue;
    
    float percX = userLocation.x/320.0;
    float percY = userLocation.y/416.0;
    
    NSLog(@"%f,%f",percX,percY);
    UIColor *screenColor;
    if (percX >= 0 && percX < 0.25) {
        vuValue = [client getBand1];
        NSLog(@"band 1");
    } else if (percX >= 0.25 && percX < 0.5) {
        vuValue = [client getBand2];
        NSLog(@"band 2");
    } else if (percX >= 0.5 && percX < 0.75) {
        vuValue = [client getBand3];
        NSLog(@"band 3");
    } else {
        vuValue = [client getband4];
        NSLog(@"band 4");
    }
    
    int binNum = (int)ceilf(percY*8)-1;
    float lowerBound = 0.01;
    float percStep = (1-lowerBound)/6.0;
    float percVal = lowerBound;
    int *active = (int*)calloc(8, sizeof(int));
    for (int i = 0; i<7; i++) {
        if (vuValue > percVal) {
            active[i] = 1;
        } else {
            active[i] = 0;
        }
        percVal += percStep;
    }
    if (vuValue > 1) {
        active[7] = 1;
    }
    
    if (active[binNum] == 1 && binNum == 7) {
        screenColor = [UIColor redColor];
        NSLog(@"red");
    } else if (active[binNum] == 1 && (binNum == 5 || binNum == 6)) {
        screenColor = [UIColor yellowColor];
        NSLog(@"yellow");
    } else if (active[binNum] == 1) {
        screenColor = [UIColor greenColor];
        NSLog(@"green");
    } else {
        screenColor = [UIColor blackColor];
        NSLog(@"black");
    }
    
    NSLog(@"Bin = %i",binNum);
    NSLog(@"Active = %i",active[binNum]);
    [_welcome updateTakeoverScreenWithColor:screenColor];
    free(active);
}

-(void) updateRoomDimensions:(CGPoint)dimensions {
    roomDimensions = dimensions;
}


-(void) updateUserLocation:(CGPoint)location {
    userLocation = location;
    [_welcome updateSoundFieldUserLocation:userLocation];
}

-(void) startAudioInput {
    [audioIn start];
}

-(void) processInputBuffer:(float *)buffer numSamples:(int)numSamples {
    
    //    NSLog(@"buffer - %i",numSamples);
    
    signalPower = 0;
    for (int i = 0;i<numSamples;i++) {
        signalPower += powf(buffer[i],2.0);
    }
    
    [_welcome updateSoundFieldPower:signalPower];
    if (localTakeoverActive) {
        [local analyzeBuffer:buffer startSample:numSamples bufferLength:numSamples];
    }
    buffIndex += numSamples;
}

-(float) checkLocationHighlight {
    
    float highlight = [client getBlobHighlight];
    if (highlight == 1) {
        NSLog(@"highlight active");
    }
    return highlight;
}

-(void) checkLocalizationTakeover {
    
    if ([client getTakeOverLocalize] == 1) {
        localTakeoverActive = YES;
//        NSLog(@"localization takeover active");
    } else {
//        NSLog(@"localization takeover not active");
        localTakeoverActive = NO;
    }
}

@end
