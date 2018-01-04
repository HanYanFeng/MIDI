//
//  WWMIDIMessage.h
//  WWMidiPlayer
//
//  Created by GatsWang on 16/7/9.
//  Copyright © 2016年 whj. All rights reserved.
//

#ifndef WWMIDIMessage_h
#define WWMIDIMessage_h
#include <stdio.h>
#include <CoreMIDI/CoreMIDI.h>


typedef enum MIDIEventType {
    kMIDIEventType_NULL,
    kMIDIEventType_Note,
    kMIDIEventType_Control,
    kMIDIEventType_Program,
    kMIDIEventType_PitchBend,
    kMIDIEventType_ChannelMode,
    kMIDIEventType_SystemCommon,
    kMIDIEventType_SystemRealTime,
    kMIDIEventType_SystemExclusive,
    kMIDIEventType_RunningStatus,
    kMIDIEventType_NotSupported,
} MIDIEventType;

void WWMIDIInspectPacket(const MIDIPacket *inPacket, MIDIEventType *outType, UInt8 *outChannel, UInt8 *outValue1, UInt8 *outValue2);
void WWMIDIInspectData(unsigned char *bytes, size_t length, MIDIEventType *outType, UInt8 *outChannel, UInt8 *outValue1, UInt8 *outValue2);

char* WWMIDIDescriptPacket(MIDIPacket *inPacket);
char* WWMIDIDescriptType(MIDIEventType);
char* WWMIDIDescriptData(unsigned char* bytes, size_t length);

#endif /* WWMIDIMessage_h */
