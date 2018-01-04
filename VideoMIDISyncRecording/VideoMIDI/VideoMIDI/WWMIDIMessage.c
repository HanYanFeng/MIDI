//
//  WWMIDIMessage.c
//  WWMidiPlayer
//
//  Created by GatsWang on 16/7/9.
//  Copyright © 2016年 whj. All rights reserved.
//

#include "WWMIDIMessage.h"

// Define Mask
typedef const UInt8 MIDIByte;

// System Msg Type
MIDIByte kMIDIMsgStatusMin = 0x80;
MIDIByte kMIDIMsgTypeSystemExclusive = 0xF0;
MIDIByte kMIDIMsgTypeSystemCommomMin = 0xF1;
MIDIByte kMIDIMsgTypeSystemRealtimeMin = 0xF8;

// Channel Msg Type
MIDIByte kMIDIMsgFirstBitMask = 0xf0;
MIDIByte kMIDIMsgSecondBitMask = 0x0f;
MIDIByte kMidiMsgTypeNoteOn = 0x90;
MIDIByte kMidiMsgTypeNoteOff = 0x80;
MIDIByte kMidiMsgTypeControl = 0xB0;

void WWMIDIInspectPacket(const MIDIPacket* inPacket, MIDIEventType *outType, UInt8 *outChannel, UInt8 *outValue1, UInt8 *outValue2)
{
    MIDIEventType type = 0;
    UInt8 status = inPacket->data[0];
    if (status < kMIDIMsgStatusMin) {
        type = kMIDIEventType_RunningStatus;
    } else if (status < kMIDIMsgTypeSystemExclusive) {
        UInt8 typeBits = status & kMIDIMsgFirstBitMask;
        switch (typeBits) {
            case kMidiMsgTypeNoteOn:
                type = kMIDIEventType_Note;
                break;
            case kMidiMsgTypeNoteOff:
                type = kMIDIEventType_Note;
                break;
            case kMidiMsgTypeControl:
                type = kMIDIEventType_Control;
                break;
            default:
                type = kMIDIEventType_NotSupported;
                break;
        }
        if (outChannel != NULL) {
            *outChannel = status & kMIDIMsgSecondBitMask;
        }
        if (outValue1 != NULL) {
            *outValue1 = inPacket->data[1];
        }
        if (outValue2 != NULL) {
            *outValue2 = inPacket->data[2];
        }
    } else if (status < kMIDIMsgTypeSystemCommomMin) {
        type = kMIDIEventType_SystemExclusive;
    } else if (status < kMIDIMsgTypeSystemRealtimeMin) {
        type = kMIDIEventType_SystemCommon;
    } else {
        type = kMIDIEventType_SystemRealTime;
    }
    *outType = type;
}

char* WWMIDIDescriptType(MIDIEventType type)
{
    char* result = NULL;
    switch (type) {
        case kMIDIEventType_RunningStatus:
            result = "RunningStatus";
            break;
        case kMIDIEventType_Note:
            result = "NoteOn & NoteOff";
            break;
        case kMIDIEventType_Control:
            result = "Control";
            break;
        default:
            result = "NotSupported";
            break;
    }
    return result;
}

#pragma mark - Show Packet

static void MapByteToChars(Byte byte, char* outchar) {
    for (int i = 0; i < 2 ; i++) {
        Byte hb = !i ? ( (byte & 0xf0) >> 4 ) : ( byte & 0x0f );
        char result;
        switch (hb) {
            case 0x0:
                result = '0';
                break;
            case 0x1:
                result = '1';
                break;
            case 0x2:
                result = '2';
                break;
            case 0x3:
                result = '3';
                break;
            case 0x4:
                result = '4';
                break;
            case 0x5:
                result = '5';
                break;
            case 0x6:
                result = '6';
                break;
            case 0x7:
                result = '7';
                break;
            case 0x8:
                result = '8';
                break;
            case 0x9:
                result = '9';
                break;
            case 0xA:
                result = 'A';
                break;
            case 0xB:
                result = 'B';
                break;
            case 0xC:
                result = 'C';
                break;
            case 0xD:
                result = 'D';
                break;
            case 0xE:
                result = 'E';
                break;
            case 0xF:
                result = 'F';
                break;
            default:
                result = '?';
                break;
        }
        outchar[i] = result;
    }
};

static void MapBytesToChars (Byte* byte, size_t length, char **outChar)
{
    // "0" -> "00 ", so * 3
    char* str = (char*)malloc(length*3*sizeof(char));
    for (int i = 0; i < length; i++) {
        MapByteToChars(byte[i], &str[i*3]);
        if (i != length - 1) {
            // Map a Space
            str[i*3+2] = 32;
        } else {
            // End
            str[i*3+2] = '\0';
        }
    }
    *outChar = str;
}

char* WWMIDIDescriptPacket (MIDIPacket* inPacket)
{
    char* str = "";
    sprintf(str, "Packet Length: %u,   Packet Time: %*llu,   PacketData:", inPacket->length, 15,inPacket->timeStamp);
    if (inPacket->length != 0) {
        char* data = NULL;
        MapBytesToChars(inPacket->data, inPacket->length, &data);
        sprintf(str, "%s %s", str, data);
    } else {
        sprintf(str, "%s null", str);
    }
    return str;
}

char* WWMIDIDescriptData(unsigned char* bytes, size_t length) {
    char* result;
    MapBytesToChars(bytes, length, &result);
    return result;
}
