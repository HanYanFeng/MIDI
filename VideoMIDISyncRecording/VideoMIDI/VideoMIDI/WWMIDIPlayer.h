//
//  WWMIDIPlayer.h
//  WWMidiPlayer
//
//  Created by GatsWang on 16/7/10.
//  Copyright © 2016年 whj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMIDI/CoreMIDI.h>
#import <AudioToolbox/AudioToolbox.h>
#import "WWMIDIMessage.h"

@class WWMIDIPlayer;

@protocol WWMIDIPlayerDelegate <NSObject>

- (void)midiPacketsReceived:(const MIDIPacketList *)pktlist;

@end

@protocol WWMIDIPlayerTimeChangeDelegete <NSObject>

-(void)WWMIDIPlayer:(WWMIDIPlayer*)player currentRate:(float)rate;
-(void)WWMIDIPlayer:(WWMIDIPlayer*)player registActive:(BOOL)registactive;
@end
@interface WWMIDIPlayer : NSObject<WWMIDIPlayerDelegate>

@property (nonatomic) NSData* midiData;
@property (nonatomic, assign) double rate;
@property (nonatomic, assign) double currentBeat;
@property (nonatomic, assign) double currentTime;
@property (nonatomic, assign) double allTime;

@property (nonatomic, readonly) NSError* error;
@property (nonatomic, assign) BOOL sendToDelegate;


- (void)play;
- (void)stop;
- (void)playNoteOn:(UInt8)i velocity:(UInt8)v channel:(UInt8)c preset:(uint)p;
- (void)playMIDIEventType:(UInt8)type Channel:(UInt8)c v1:(UInt8)v1 v2:(UInt8)v2 preset:(uint)p;


-(void)playWith:(void(^)(double))pressBack;
-(void)stopPlay;
@property (nonatomic,weak) id<WWMIDIPlayerDelegate> delegate;

//@property (nonatomic,weak) id<WWMIDIPlayerTimeChangeDelegete>rateDelegate;
-(int)get_endPoint;

-(BOOL)isPlaying;

//+(instancetype)shard;
+(instancetype)creatPlayerwithData:(NSData*)data;

-(float)getScale;
-(void)setProgressScale:(float)progressScale;

+(void)appRegistActive;
+(void)appActive;

+(void)midiPacketsReceived:(const MIDIPacketList *)packetList sendToble:(BOOL)_sendToBluetooth midiEngine:(WWMIDIPlayer*)_midiEngine oneNoteData:(void(^)(NSData*,int))oneNoteData;
@end
