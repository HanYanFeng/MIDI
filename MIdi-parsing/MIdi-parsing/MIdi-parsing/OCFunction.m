//
//  OCFunction.m
//  MIdi-parsing
//
//  Created by 韩艳锋 on 2017/12/6.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

#import "OCFunction.h"

@implementation OCFunction
+ (MIDINoteMessage)getNoteMessage:(NSData*)data;
{
    MIDINoteMessage * dd = (MIDINoteMessage*)data.bytes;
    return  *dd;
}

+ (ExtendedNoteOnEvent)kMusicEventType_ExtendedNote:(NSData*)data{
    ExtendedNoteOnEvent * dd = (ExtendedNoteOnEvent*)data.bytes;
    return *dd;
}

+ (ExtendedTempoEvent)kMusicEventType_ExtendedTempo:(NSData*)data;{
    ExtendedTempoEvent * dd = (ExtendedTempoEvent*)data.bytes;
    return *dd;
}

+ (MusicEventUserData)kMusicEventType_User:(NSData*)data;{
    MusicEventUserData * dd = (MusicEventUserData*)data.bytes;
    return *dd;
}

+ (MIDIMetaEvent)kMusicEventType_Meta:(NSData*)data;{
    MIDIMetaEvent * dd = (MIDIMetaEvent*)data.bytes;
    if ((*dd).metaEventType == 88) {
        NSLog(@"拍号变为分子:%d,分母为%d",(*dd).data[0],(int)pow(2, (*dd).data[1]));
    }
    return *dd;
}

+ (MIDINoteMessage)kMusicEventType_MIDINoteMessage:(NSData*)data;{
    MIDINoteMessage * dd = (MIDINoteMessage*)data.bytes;
    return *dd;
}

+ (MIDIChannelMessage)kMusicEventType_MIDIChannelMessage:(NSData*)data;{
    MIDIChannelMessage * dd = (MIDIChannelMessage*)data.bytes;
    return *dd;
}

+ (MIDIRawData)kMusicEventType_MIDIRawData:(NSData*)data;{
    MIDIRawData * dd = (MIDIRawData*)data.bytes;
    return *dd;
}

+ (ParameterEvent)kMusicEventType_Parameter:(NSData*)data;{
    ParameterEvent * dd = (ParameterEvent*)data.bytes;
    return *dd;
}

+ (AUPresetEvent)kMusicEventType_AUPreset:(NSData*)data;{
    AUPresetEvent * dd = (AUPresetEvent*)data.bytes;
    return *dd;
}

@end
