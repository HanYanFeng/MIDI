//
//  NativeDBModel.m
//  PianoApp
//
//  Created by 袁银花 on 2017/5/15.
//  Copyright © 2017年 whj. All rights reserved.
//

#import "NativeDBModel.h"
#import "OCFunction.h"
@implementation NoteOnMessage
-(instancetype)initWith:(sqlite3_stmt*)stmt;
{
    self = [super init];
    if (self) {
        _id_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)];
        _tick = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
        _name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
        _mea_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 3)];
        _staff_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 4)];
        _voice_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 5)];
        _note_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 6)];
        _value = [NSNumber numberWithInt:sqlite3_column_int(stmt, 7)];
        _x = [NSNumber numberWithInt:sqlite3_column_int(stmt, 8)];
        _y = [NSNumber numberWithInt:sqlite3_column_int(stmt, 9)];
        _hand = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 10)];
    }
    return self;
}

@end
@implementation WindowOpenAndClose
-(instancetype)initWith:(sqlite3_stmt*)stmt;
{
    self = [super init];
    if (self) {
        _id_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)];
        _instrument_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
        _tick = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
    }
    return self;
}

@end
@implementation XmlMessage
-(instancetype)initWith:(sqlite3_stmt*)stmt;
{
    self = [super init];
    if (self) {
        //  NSString * this_name =[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
        _name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
        _instrument_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
        _measure_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 2)];
        _staff_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 3)];
        _voice_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 4)];
        _slot_num = [NSNumber numberWithInt:sqlite3_column_int(stmt, 5)];
        _status = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
        _describe = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)];
    }
    return self;
}

@end

@implementation NativeDBModel
-(instancetype)initWithPath:(NSString*)dbfilePath;
{
    self = [super init];
    if (self) {
        _xmlMessage = [NSMutableArray array];
        _noteOnMessage = [NSMutableArray array];
        _windowOpenAndClose = [NSMutableArray array];
        [self initialize:dbfilePath];
    }
    return self;
}
-(void)initialize:(NSString*)dbfilePath;
{
    NSData * data = [NSData dataWithContentsOfFile:dbfilePath];
    [data writeToFile:@"/Users/hanyanfeng/Desktop/未命名文件夹/qinjia.db" atomically:true];
    sqlite3_stmt * stmt;
    NSString  * query = @"SELECT * from XMLMessage";
    int ret = 0;
    sqlite3* my_current_SqliteDB;
    ret = sqlite3_open_v2(
                          [dbfilePath UTF8String],
                          &my_current_SqliteDB,
                          SQLITE_OPEN_READONLY,
                          NULL
                          );
    int rc=0;
    rc = sqlite3_prepare_v2(my_current_SqliteDB, [query UTF8String], -1, &stmt, NULL);
    if(rc == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            XmlMessage * xmlMessage = [[XmlMessage alloc]initWith:stmt];
            [(NSMutableArray*)self.xmlMessage addObject:xmlMessage];
        }
        sqlite3_finalize(stmt);
    }
    else
    {
        NSLog(@"db 错误1");
    }
    
    query = @"SELECT * from NoteOnMessage";
    rc = sqlite3_prepare_v2(my_current_SqliteDB, [query UTF8String], -1, &stmt, NULL);
    if(rc == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            NoteOnMessage * noteOnMessage = [[NoteOnMessage alloc]initWith:stmt];
            [(NSMutableArray*)self.noteOnMessage addObject:noteOnMessage];
        }
        sqlite3_finalize(stmt);
    }
    else
    {
        NSLog(@"db 错误2");
    }
    
    query = @"SELECT * from WindowOpenAndClose";
    rc = sqlite3_prepare_v2(my_current_SqliteDB, [query UTF8String], -1, &stmt, NULL);
    if(rc == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            WindowOpenAndClose * windowOpenAndClose = [[WindowOpenAndClose alloc]initWith:stmt];
            [(NSMutableArray*)self.windowOpenAndClose addObject:windowOpenAndClose];
        }
        sqlite3_finalize(stmt);
    }else{
        NSLog(@"db 错误3");
    }
}
@end
