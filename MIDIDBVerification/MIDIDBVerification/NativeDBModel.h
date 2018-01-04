//
//  NativeDBModel.h
//  PianoApp
//
//  Created by 袁银花 on 2017/5/15.
//  Copyright © 2017年 whj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface NoteOnMessage : NSObject
@property (copy ,readonly ,nonatomic) NSNumber * id_num;
@property (copy ,readonly ,nonatomic) NSNumber * tick;
@property (copy ,readonly ,nonatomic) NSString * name;
@property (copy ,readonly ,nonatomic) NSNumber * mea_num;
@property (copy ,readonly ,nonatomic) NSNumber * staff_num;
@property (copy ,readonly ,nonatomic) NSNumber * voice_num;
@property (copy ,readonly ,nonatomic) NSNumber * note_num;
@property (copy ,readonly ,nonatomic) NSNumber * value;
@property (copy ,readonly ,nonatomic) NSNumber * x;
@property (copy ,readonly ,nonatomic) NSNumber * y;
@property (copy ,readonly ,nonatomic) NSString * hand;
-(instancetype)initWith:(sqlite3_stmt*)stmt;
@end

@interface WindowOpenAndClose : NSObject
@property (copy ,readonly ,nonatomic) NSNumber * id_num;
@property (copy ,readonly ,nonatomic) NSNumber * instrument_num;
@property (copy ,readonly ,nonatomic) NSString * tick;
-(instancetype)initWith:(sqlite3_stmt*)stmt;

@end
@interface XmlMessage : NSObject
@property (copy ,readonly ,nonatomic) NSNumber * instrument_num;
@property (copy ,readonly ,nonatomic) NSNumber * measure_num;
@property (copy ,readonly ,nonatomic) NSNumber * staff_num;
@property (copy ,readonly ,nonatomic) NSNumber * voice_num;
@property (copy ,readonly ,nonatomic) NSNumber * slot_num;
@property (copy ,readonly ,nonatomic) NSString * name;
@property (copy ,readonly ,nonatomic) NSString * status;
@property (copy ,readonly ,nonatomic) NSString * describe;
-(instancetype)initWith:(sqlite3_stmt*)stmt;

@end

@interface NativeDBModel : NSObject
@property (strong ,nonatomic) NSArray <NoteOnMessage*>* noteOnMessage;
@property (strong ,nonatomic,readonly) NSArray <WindowOpenAndClose*>* windowOpenAndClose;
@property (strong ,nonatomic) NSArray <XmlMessage *>* xmlMessage;
-(instancetype)initWithPath:(NSString*)dbfilePath;
@end
