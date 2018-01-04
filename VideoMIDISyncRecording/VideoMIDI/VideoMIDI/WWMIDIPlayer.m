//
//  WWMIDIPlayer.m
//  WWMidiPlayer
//
//  Created by GatsWang on 16/7/10.
//  Copyright © 2016年 whj. All rights reserved.
// 0303 0308

#import "WWMIDIPlayer.h"
#pragma mark - C
//#import "XMidiSequence.h"
// DataType
static MIDIClientRef _cli;
static AUGraph _graph;
static AUNode _ioNode;
static AUNode _samplerNode;
static AUNode _samplerNode2;
static AUNode _mixerNode;
static AudioUnit _samplerUnit;
static AudioUnit _samplerUnit2;
static AudioUnit _ioUnit;
static AudioUnit _mixerUnit;

// Contants
static NSString* cliName = @"WWMidiPlayerCli";
static NSString* destName = @"WWMidiTrackDest";


static WWMIDIPlayer * player = nil;
// Callback
void MyMIDIReadProc(const MIDIPacketList *pktlist, void * __nullable readProcRefCon, void * __nullable srcConnRefCon)
{
    WWMIDIPlayer* player = (__bridge WWMIDIPlayer*)readProcRefCon;
    [player.delegate midiPacketsReceived:pktlist];
}

#pragma mark - OC
@implementation WWMIDIPlayer {
    // Player
    MusicSequence _seq;
    MusicPlayer _player;
    
    // Midi
    MIDIEndpointRef _endPoint;
    UInt32 _trackNum;
    ///播放进度改变
    NSTimer * timer;
    
    BOOL _isRegistActive;
}

static int _instanceCount;

+ (void)initialize {
    if (self == [WWMIDIPlayer class]) {
        _instanceCount = 0;
        CFStringRef cn = CFBridgingRetain([NSString stringWithFormat:@"%@_%d", cliName, _instanceCount]);
        MIDIClientCreateWithBlock(cn, &_cli, ^(const MIDINotification * _Nonnull message) {
            
        });
        CFRelease(cn);
        
        [self createAUGraph];
    }
}


+ (BOOL) createAUGraph
{
    NewAUGraph(&_graph);
    // create the sampler
    // for now, just have it play the default sine tone
    AudioComponentDescription cd = {};
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_Sampler;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    AUGraphAddNode(_graph, &cd, &_samplerNode);
    AUGraphAddNode(_graph, &cd, &_samplerNode2);
    
    // Mixer Unit
    AudioComponentDescription mixerd = {};
    mixerd.componentType = kAudioUnitType_Mixer;
    mixerd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixerd.componentManufacturer  = kAudioUnitManufacturer_Apple;
    mixerd.componentFlags         = 0;
    mixerd.componentFlagsMask     = 0;
    AUGraphAddNode(_graph, &mixerd, &_mixerNode);
    
    // I/O unit
    AudioComponentDescription iOUnitDescription = {};
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    AUGraphAddNode(_graph, &iOUnitDescription, &_ioNode);
    
    // now do the wiring. The graph needs to be open before you call AUGraphNodeInfo
    AUGraphOpen(_graph);
    
    AUGraphNodeInfo(_graph, _mixerNode, NULL, &_mixerUnit);
    AUGraphNodeInfo(_graph, _samplerNode, NULL, &_samplerUnit);
    AUGraphNodeInfo(_graph, _samplerNode2, NULL, &_samplerUnit2);
    AUGraphNodeInfo(_graph, _ioNode, NULL, &_ioUnit);
    
    UInt32 iv = 2;
    UInt32 ov = 1;
    AudioUnitSetProperty(_mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &iv, sizeof(UInt32));
    AudioUnitSetProperty(_mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &ov, sizeof(UInt32));
    
//#warning Silencing warning "kAudioUnitProperty_MaximumFramesPerSlice", may be a problem.
    UInt32 maxFPS = 4096;
    AudioUnitSetProperty(_samplerUnit,
                         kAudioUnitProperty_MaximumFramesPerSlice,
                         kAudioUnitScope_Global,
                         0,
                         &maxFPS,
                         sizeof(maxFPS));
    AudioUnitSetProperty(_samplerUnit2,
                         kAudioUnitProperty_MaximumFramesPerSlice,
                         kAudioUnitScope_Global,
                         0,
                         &maxFPS,
                         sizeof(maxFPS));
    AudioUnitSetProperty(_ioUnit,
                         kAudioUnitProperty_MaximumFramesPerSlice,
                         kAudioUnitScope_Global,
                         0,
                         &maxFPS,
                         sizeof(maxFPS));
    AudioUnitSetProperty(_mixerUnit,
                         kAudioUnitProperty_MaximumFramesPerSlice,
                         kAudioUnitScope_Global,
                         0,
                         &maxFPS,
                         sizeof(maxFPS));
    
    AUGraphConnectNodeInput(_graph,
                            _samplerNode, 0,
                            _mixerNode, 0);
    AUGraphConnectNodeInput(_graph,
                            _samplerNode2, 0,
                            _mixerNode, 1);
    AUGraphConnectNodeInput(_graph,
                            _mixerNode, 0,
                            _ioNode, 0);
    
    Boolean outIsInitialized;
    AUGraphIsInitialized(_graph, &outIsInitialized);
    if(!outIsInitialized) {AUGraphInitialize(_graph);}
    
    // propagates stream formats across the connections
    NSURL *bankURL;
    bankURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle]
                                                  pathForResource:@"TimGM6mb" ofType:@"sf2"]];
    // fill out a bank preset data structure
    AUSamplerInstrumentData bpdata;
    bpdata.fileURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = 0;
    bpdata.instrumentType = kInstrumentType_DLSPreset;
    AudioUnitSetProperty(_samplerUnit,
                         kAUSamplerProperty_LoadInstrument,
                         kAudioUnitScope_Global,
                         0,
                         &bpdata,
                         sizeof(bpdata));
    
    
    bpdata.presetID = 115;
    AudioUnitSetProperty(_samplerUnit2,
                         kAUSamplerProperty_LoadInstrument,
                         kAudioUnitScope_Global,
                         0,
                         &bpdata,
                         sizeof(bpdata));
    
    AUGraphStart(_graph);
    return YES;
}


- (instancetype)init {
    if (self = [super init]) {
        _sendToDelegate = NO;
        // Create Midi Client

        // Seq
        NewMusicPlayer(&_player);
        
        NSString* name = [NSString stringWithFormat:@"%@", destName];
        CFStringRef dn = (__bridge CFStringRef)name;
        OSStatus status = MIDIDestinationCreate(_cli, dn, MyMIDIReadProc, (__bridge void * _Nullable)(self), &_endPoint);
         
        if (status == -10844) {
            _error = [NSError errorWithDomain:@"WWMIDIPlayer" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey:@"MIDI Not Permitted, set related key in uiinfo"}];
            //        Beginning in iOS 6, apps need to have the audio key in their UIBackgroundModes in order to use CoreMIDI’s MIDISourceCreate and MIDIDestinationCreate functions. Without the key set, these functions will return kMIDINotPermitted (-10844).
        }
        
    }
    return self;
}

- (void)dealloc {
    [self freeMemory];
    for (int i = 0; i < 8; i++) {
        MIDIEndpointDispose(_endPoint);
    }
}

- (void)freeMemory {
    _midiData = nil;
    
    // Stop
    [self stop];
    
    // Free
    DisposeMusicPlayer(_player); _player = NULL;
    DisposeMusicSequence(_seq); _seq = NULL;
}

#pragma mark - Event

- (void)setMidiData:(NSData *)midiData {
    
//    XMidiSequence * ddd = [[XMidiSequence alloc]initWithData:midiData];
//    self.allTime = ddd.musicTotalTime / 20 * 23;
    self.allTime = [WWMIDIPlayer allTime:midiData];
    if (midiData == _midiData) {
        return;
    }

    if (_midiData) {
        [self freeMemory];
    }
    
    // Set
    _midiData = midiData;

    // Malloc Track & Player
    if (_midiData) {
        CFDataRef data = (__bridge CFDataRef)_midiData;
        OSStatus status = 0;
        
        NewMusicPlayer(&_player);
        NewMusicSequence(&_seq);
        MusicPlayerSetSequence(_player, _seq);
        status = MusicSequenceFileLoadData(_seq, data, kMusicSequenceFile_MIDIType, 0);
        if (status != 0) {
            NSString* error = [NSString stringWithFormat:@"Load Data Error, status %u", (int)status];
            [self error:[NSError errorWithDomain:@"MIDI Load Data" code:0 userInfo:@{NSLocalizedDescriptionKey: error}]];
            return;
        }
        MusicSequenceGetTrackCount(_seq, &_trackNum);
        _trackNum = _trackNum <= 8 ? _trackNum : 8;

        if (_sendToDelegate) {
            MusicSequenceSetMIDIEndpoint(_seq, _endPoint);
        } else {
            MusicSequenceSetAUGraph(_seq, _graph);
        }
    }
    MusicPlayerPreroll(_player);
}

- (void)play{
    Boolean isplaying = 0;
    MusicPlayerIsPlaying(_player, &isplaying);
    if (!isplaying) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            MusicPlayerStart(_player);
        });
    }
}

- (void)stop {
    Boolean isPlaying;
    MusicPlayerIsPlaying(_player, &isPlaying);
    if (isPlaying) {
        MusicPlayerStop(_player);

    }
    
}

- (void)setCurrentBeat:(double)currentBeat {
    MusicPlayerSetTime(_player, currentBeat);
}

- (double)currentBeat {
    double beat = .0;
    MusicPlayerGetTime(_player, &beat);
    return beat;
}

- (void)setCurrentTime:(double)currentTime {
    MusicTimeStamp beat = 0;
    double rate = .0;
    MusicPlayerGetPlayRateScalar(_player, &rate);
//    MusicSequenceGetBeatsForSeconds(_seq, currentTime * rate, &beat);
    MusicSequenceGetBeatsForSeconds(_seq, currentTime, &beat);
    MusicPlayerSetTime(_player, beat);
}

- (double)currentTime {
    double beat = .0, time = .0, rate = .0;
    MusicPlayerGetTime(_player, &beat);
    MusicSequenceGetSecondsForBeats(_seq, beat, &time);
    MusicPlayerGetPlayRateScalar(_player, &rate);
    return time * rate;
}

- (void)setRate:(double)rate {
    MusicPlayerSetPlayRateScalar(_player, rate);
}

- (double)rate {
    double rate = .0;
    MusicPlayerGetPlayRateScalar(_player, &rate);
    return rate;
}

- (void)setSendToDelegate:(BOOL)sendToDelegate {
    if (sendToDelegate == _sendToDelegate) {
        return;
    }
    _sendToDelegate = sendToDelegate;
    if (_sendToDelegate) {
        MusicSequenceSetMIDIEndpoint(_seq, _endPoint);
    } else {
        MusicSequenceSetAUGraph(_seq, _graph);
    }
}

- (void)playNoteOn:(UInt8)i velocity:(UInt8)v channel:(UInt8)c preset:(uint)p {
    static const UInt8 noteCommand = 0x90;
    if (p) {
        MusicDeviceMIDIEvent(_samplerUnit2, noteCommand + c, i, v, 0);
    } else {
        MusicDeviceMIDIEvent(_samplerUnit, noteCommand + c, i, v, 0);
    }
}

- (void)playMIDIEventType:(UInt8)type Channel:(UInt8)c v1:(UInt8)v1 v2:(UInt8)v2 preset:(uint)p {
    if (p) {
        MusicDeviceMIDIEvent(_samplerUnit2, type + c, v1, v2, 0);
    } else {
        MusicDeviceMIDIEvent(_samplerUnit, type + c, v1, v2, 0);
    }
}
-(void)playWith:(void(^)(double))pressBack{
    __weak WWMIDIPlayer * this = self;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [this timerAction:pressBack];
    }];
    [self play];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_HIGH), ^{
        [timer fire];
    });
}
-(void)timerAction:(void(^)(double))pressBack{
    if (self.getScale == 1) {
        [self stopPlay];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        pressBack(self.getScale);
    });
}
-(void)stopPlay;
{
    [self stop];
    [timer invalidate];
}
-(int)get_endPoint{
    return _endPoint;
}
-(BOOL)isPlaying{
    Boolean is;
    MusicPlayerIsPlaying(_player,&is);
    if (is) {
        return YES;
    }else{
        return NO;
    }
}
-(void)registActive{
    [self stop];
    if (self.isPlaying) {
        _isRegistActive = YES;
    }
}
-(void)beComeActive{
    
    [WWMIDIPlayer createAUGraph];
    if (_isRegistActive) {
        [self play];
        _isRegistActive = NO;
    }
}
+(instancetype)creatPlayerwithData:(NSData*)data;
{
    
    WWMIDIPlayer * _player = [[WWMIDIPlayer alloc] init];
    _player.delegate = _player;
    _player.midiData = data;
    player = _player;
    return _player;
}

#pragma mark - Error

- (void)error:(NSError*)error {
    NSLog(@"MIDIPlayer: %@", error);
}
- (void)midiPacketsReceived:(const MIDIPacketList *)pktlist;
{
    
}
-(float)getScale{
    float scale = self.currentTime / self.allTime ;
    if (scale >= 1) {
        return 1;
    }else{
        return scale;
    }
}
-(void)setProgressScale:(float)progressScale{
    if (progressScale >= 0 && progressScale <= 1) {
        self.currentTime = self.allTime * progressScale ;
    }else{
        NSAssert(NO, @"progressScale 0～1");
    }
}

+(void)appRegistActive{
    if (player.isPlaying) {
        [player registActive];
    }
}
+(void)appActive{
    [player beComeActive];
    
}
+(double)allTime:(NSData*)midiData{
    MusicSequence _seq;
    NewMusicSequence(&_seq);
    CFDataRef cfdata = (__bridge CFDataRef)midiData;
    MusicSequenceFileLoadData(_seq , cfdata, kMusicSequenceFile_MIDIType, kMusicSequenceLoadSMF_PreserveTracks);
    UInt32 tc;
    MusicSequenceGetTrackCount(_seq, &tc);
    double time = 0;
    for (int index = 0; index != tc; index++) {
        MusicEventIterator _iterator = NULL;
        DisposeMusicEventIterator(_iterator);
        
        MusicTrack track;
        MusicSequenceGetIndTrack(_seq, index, &track);
        NewMusicEventIterator(track, &_iterator);
        Boolean hasCurrentEvent = NO;
        MusicEventType type;
        const Byte* data;
        UInt32 size;
        MusicTimeStamp timeInBeat;
        double endTimeInSecond = 0;
        do {
            MusicEventIteratorGetEventInfo(_iterator, &timeInBeat, &type, (const void **)&data, &size);
            if (type == kMusicEventType_MIDINoteMessage) {
                MIDINoteMessage* msg = (MIDINoteMessage*)data;
                MusicSequenceGetSecondsForBeats(_seq, timeInBeat + msg->duration, &endTimeInSecond);
                if (endTimeInSecond > time) {
                    time = endTimeInSecond;
                }
            }
            MusicEventIteratorNextEvent(_iterator);
            MusicEventIteratorHasCurrentEvent(_iterator, &hasCurrentEvent);
        } while (hasCurrentEvent);
        
    }
    return time;
}
+(void)midiPacketsReceived:(const MIDIPacketList *)packetList sendToble:(BOOL)_sendToBluetooth midiEngine:(WWMIDIPlayer*)_midiEngine oneNoteData:(void(^)(NSData*,int))oneNoteData;
{
    const MIDIPacket *packet = &packetList->packet[0];
    //    NSLog(@"-------------");
    for (int i = 0; i < packetList->numPackets; ++i) {
        const Byte *msg = packet->data;
        int channel = msg[0] & 0x0f;
        int trackNo = channel + 1;
        
        
        
        if (!_sendToBluetooth) {
            [_midiEngine playMIDIEventType:msg[0]
                                   Channel:channel
                                        v1:msg[1]
                                        v2:packet->length == 3 ? msg[2] : 0
                                    preset:0];
        }else{
            oneNoteData([NSMutableData dataWithBytes:packet->data length:packet->length],trackNo);
        }
        packet = MIDIPacketNext(packet);
    }
}
@end
