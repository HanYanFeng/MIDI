//
//  OCFunction.h
//  MIdi-parsing
//
//  Created by 韩艳锋 on 2017/12/6.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface OCFunction : NSObject
+ (MIDINoteMessage)getNoteMessage:(NSData*)data;
+ (ExtendedNoteOnEvent)kMusicEventType_ExtendedNote:(NSData*)data;
+ (ExtendedTempoEvent)kMusicEventType_ExtendedTempo:(NSData*)data;
+ (MusicEventUserData)kMusicEventType_User:(NSData*)data;
+ (MIDIMetaEvent)kMusicEventType_Meta:(NSData*)data;
+ (MIDINoteMessage)kMusicEventType_MIDINoteMessage:(NSData*)data;
+ (MIDIChannelMessage)kMusicEventType_MIDIChannelMessage:(NSData*)data;
+ (MIDIRawData)kMusicEventType_MIDIRawData:(NSData*)data;
+ (ParameterEvent)kMusicEventType_Parameter:(NSData*)data;
+ (AUPresetEvent)kMusicEventType_AUPreset:(NSData*)data;

@end
