//
//  KZLibs.m
//  KZLibs
//
//  Created by 内山和也 on 2019/03/26.
//  Copyright (c) 2019年 内山和也. All rights reserved.
//

#import "KZLibs.h"


@implementation KZLibs
#pragma mark -
#pragma mark array func
+ (NSArray*)distinctArray:(NSArray*)array
{
    NSOrderedSet *orderset = [[NSOrderedSet alloc] initWithArray:array];
    return orderset.array;
}

#pragma mark -
#pragma mark number func
+ (NSString*)getRoundedStr:(double)value digit:(uint8)scale
{
    NSString* retNum;
    NSDecimalNumber *decVal = [[NSDecimalNumber alloc] initWithDouble:value];
    NSDecimalNumberHandler *roundingStyle = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain // 四捨五入
                                                                                                   scale:scale
                                                                                        raiseOnExactness:NO
                                                                                         raiseOnOverflow:NO
                                                                                        raiseOnUnderflow:NO
                                                                                     raiseOnDivideByZero:NO];
    NSDecimalNumber *rouded = [decVal decimalNumberByRoundingAccordingToBehavior:roundingStyle];
    
    NSString *formatString = [[@"\%." stringByAppendingString:[NSString stringWithFormat:@"%d",scale]] stringByAppendingString:@"f"];
    retNum = [NSString stringWithFormat:formatString, [rouded doubleValue]];
    
    return retNum;
}

// 引数の数字(文字列)を先頭に0を入れた数字に変換
+ (NSString*)paddNumber:(int)keta num:(int)num
{
    NSString* str_num = [NSString stringWithFormat:@"%d",num];
    NSUInteger numLength = [str_num length];
    
    if(numLength == keta)
    {
        return str_num;
    }
    
    if(numLength < keta)
    {
        int i = 0;
        while (i < (keta - numLength))
        {
            str_num = [@"0" stringByAppendingString:str_num];
            i++;
        }
        return str_num;
    }
    if (numLength > keta)
    {
        return str_num;
    }
    return @"";
}

#pragma mark -
#pragma mark date func

// 290517の形式は@"yymmdd" 2017/05の形式は @"yyyy/mm"
+ (NSString*)getNowDate:(NSString*)format
{
    // 現在日時（世界標準時）を取得
    NSDate* dt = [NSDate date];
    
    // 時刻書式指定子を設定
    NSDateFormatter* form = [[NSDateFormatter alloc] init];
    NSString* dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy/MM" options:0 locale:[NSLocale currentLocale]];
    [form setDateFormat:dateFormat];
    
    // ロケールを設定
    NSLocale* loc = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    [form setLocale:loc];
    
    // カレンダーを指定
#ifdef MountainLion
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier: NSJapaneseCalendar];
#else
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierJapanese];
#endif

    [form setCalendar: cal];
    
    // 和暦を出力するように書式指定
    [form setDateFormat:@"GGyy年MM月dd日EEEE"];
    
    NSString* date = [form stringFromDate:dt];
    
    // 平成○○を取得
    NSRange searchResult = [date rangeOfString:@"年"];
    
    NSString* year = [date substringWithRange:NSMakeRange(searchResult.location - 2, 2)];
    
    NSString* month = [date substringWithRange:NSMakeRange(searchResult.location + 1, 2)];
    searchResult = [date rangeOfString:@"月"];
    NSString* day = [date substringWithRange:NSMakeRange(searchResult.location + 1, 2)];
    NSString* ret = @"";
    
    if([format compare:@"yymmdd"] == NSOrderedSame)
    {
        ret = [NSString stringWithFormat:@"%@%@%@",year,month,day];
    }
    else if([format compare:@"yyyy/mm"] == NSOrderedSame)
    {
        form = [[NSDateFormatter alloc] init];
        NSString* dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy/MM" options:0 locale:[NSLocale currentLocale]];
        [form setDateFormat:dateFormat];
        ret = [form stringFromDate:dt];
    }
    else if ([format compare:@"yyyymmdd"] == NSOrderedSame)
    {
        form = [[NSDateFormatter alloc] init];
        NSString* dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyMM" options:0 locale:[NSLocale currentLocale]];
        [form setDateFormat:dateFormat];
        ret = [form stringFromDate:dt];
        NSString* y = [ret substringToIndex:4];
        ret = [NSString stringWithFormat:@"%@%@%@",y,month,day];
    }
    return ret;
}

// 29 の形で入力すると西暦(2017)で返す
+(NSString*)getSeirekiString:(NSString*)wareki
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSDate *date;
    @try {
        [comps setYear:  [wareki integerValue]];    // Year
        [comps setMonth: 1];    // Month
        [comps setDay:   1];    // Day
        [comps setHour:  1];    // Hour
        [comps setMinute:0];    // Minute
        [comps setSecond:0];    // Second
    }
    @catch (NSException *exception) {
        NSLog(@"error was cought at NSDateComponents set values");
    }
#ifdef MountainLion
    NSCalendar *japaneseCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSJapaneseCalendar];
#else
    NSCalendar *japaneseCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierJapanese];
#endif
    date = [japaneseCalendar dateFromComponents:comps];    // NSJapaneseCalendarで実行
    
    NSDateFormatter* form = [[NSDateFormatter alloc] init];
    NSString* dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy" options:0 locale:[NSLocale currentLocale]];
    [form setDateFormat:dateFormat];
    
    NSString* ret = [form stringFromDate:date];
    ret = [ret substringToIndex:[ret length] - 1];
    
    return ret;
}

#pragma mark -
#pragma mark string func



// 指定文字の位置を、文字列から検索
+ (NSArray*)searchCharPosition:(NSString*)str searchChar:(NSString*)ch
{
    NSMutableArray* ret = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i < [str length]; i++)
    {
        NSString* tmp = [str substringWithRange:NSMakeRange(i, 1)];
        if ([tmp compare:ch] == NSOrderedSame)
        {
            [ret addObject:[NSNumber numberWithInt:i]];
        }
    }
    return [ret mutableCopy];
}

+ (BOOL)isExistString:(NSString*)str searchStr:(NSString*)searchStr
{
    NSRange rng = [str rangeOfString:searchStr];
    if(rng.location != NSNotFound)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isEqual:(NSString*)str compare:(NSString*)cmp
{
    if([str compare:cmp] == NSOrderedSame)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isEqualC:(NSString*)str compare:(const char*)cmp
{
    NSString* cmps = [NSString stringWithUTF8String:cmp];
    return [self isEqual:str compare:cmps];
}

+ (BOOL)isOnlyDecimalNumber:(NSString*)str
{
    NSCharacterSet *characters = [NSCharacterSet characterSetWithCharactersInString:str];
    return [[NSCharacterSet decimalDigitCharacterSet] isSupersetOfSet:characters];
}

#pragma mark -
#pragma mark Unit func
// ピクセル→mm
+ (double)pixcelToMm:(double)p dpi:(double)dpi_
{
    return (double)(((p / dpi_)*2.54)*10);
}
// mm→ピクセル
+ (double)mmToPixcel:(double)m dpi:(double)dpi_
{
    return (double)((m * dpi_)/25.4);
}

#pragma mark -
#pragma mark file func
+ (void)makeFolder:(NSString*)root folderName:(NSString*)name
{
    NSFileManager* mng = [NSFileManager defaultManager];
    if (![mng fileExistsAtPath:[root stringByAppendingPathComponent:name]])
        [mng createDirectoryAtPath:[root stringByAppendingPathComponent:name] withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (NSString*)getFileExt:(NSString*)path
{
    NSMutableString *ext = [NSMutableString stringWithString:[[path pathExtension]lowercaseString]];
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    NSString *uti = [ws typeOfFile:path error:nil];
    [ext setString:[ws preferredFilenameExtensionForType:uti]];
    
    return [ext copy];
}

+ (NSString*)getFileName:(NSString*)path
{
    NSString* topStr = [path substringToIndex:1];
    if([topStr isEqualToString:@"\""])
    {
        // nop
    }
    else {
        path = [path stringByAppendingString:@"\""];
        path = [@"\"" stringByAppendingString:path];
    }
    
    NSString* command1 = [[@"fpath=" stringByAppendingString:path] stringByAppendingString:@";fname_ext=\"${fpath##*/}\"; fname=\"${fname_ext%.*}\"; echo $fname"];
    NSArray* command = @[@"-c", command1];
    return [self doShellScript:command];
}

+ (BOOL)isDirectory:(NSString *)path
{
    NSFileManager* myFile = [NSFileManager defaultManager];
    NSDictionary* attr = [myFile attributesOfItemAtPath:path error:nil];
    NSString* a = [attr valueForKey:NSFileType];
    if([a compare:@"NSFileTypeDirectory"] == NSOrderedSame)
        return YES;
    else
        return FALSE;
}

+ (BOOL)isFile:(NSString *)path
{
    NSFileManager* myFile = [NSFileManager defaultManager];
    NSDictionary* attr = [myFile attributesOfItemAtPath:path error:nil];
    NSString* a = [attr valueForKey:NSFileType];
    if([a compare:@"NSFileTypeRegular"] == NSOrderedSame)
        return YES;
    else
        return FALSE;
}

// 指定階層までのファイルリストを作成(指定フォルダの階層以降の階層を設定)
+ (NSArray*)getFileList:(NSString *)path dirClass:(NSUInteger)dirClass onlyDir:(BOOL)onD
{
    NSString*       file;
    NSMutableArray*    ret         = [NSMutableArray array];
    
    NSDirectoryEnumerator* dirEnum;
    dirEnum = [[NSFileManager defaultManager]
               enumeratorAtPath:path];
    
    while(file = [dirEnum nextObject]) {
        if([file characterAtIndex:0] == '.') continue;
        if(dirClass == [[file componentsSeparatedByString:@"/"] count] -1)
        {
            if (onD)
            {
                if([self isFile:[path stringByAppendingPathComponent:file]]) continue;
                [ret addObject:[path stringByAppendingPathComponent:file]];
            }
            else
            {
                if([self isDirectory:[path stringByAppendingPathComponent:file]]) continue;
                [ret addObject:[path stringByAppendingPathComponent:file]];
            }
        }
    }
    
    return ret;
}

+ (NSArray*)getFileList:(NSString *)atPath searchName:(NSString*)name onlyDir:(BOOL)onD onlyFile:(BOOL)onF
{
    NSMutableArray *arList = [@[] mutableCopy];
    __block NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    query.searchScopes = @[[NSURL fileURLWithPath:atPath]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", NSMetadataItemFSNameKey, name];
    query.predicate = pred;
    
    __block NSArray<NSMetadataItem*> *arFiles = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [NSNotificationCenter.defaultCenter addObserverForName:NSMetadataQueryDidFinishGatheringNotification object:query queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSMetadataQuery *q = [note object];
        [q disableUpdates];
        [q stopQuery];
        arFiles = [q results];
        query = nil;
        dispatch_semaphore_signal(semaphore);
    }];
    [query startQuery];
    
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    
    for (NSMetadataItem* item in arFiles) {
        NSString *thePath = [item valueForAttribute:NSMetadataItemPathKey];
        if (onD && !onF) {
            if ([self isDirectory:thePath])
                [arList addObject:thePath];
        }
        else if (onF && !onD) {
            if (![self isDirectory:thePath])
                [arList addObject:thePath];
        }
        else {
            [arList addObject:thePath];
        }
    }
    
    return [arList copy];
}

// ファイルリスト取得
+ (NSArray*)getFileList:(NSString *)path deep:(BOOL)deep onlyDir:(BOOL)onD onlyFile:(BOOL)onF isAllFullPath:(BOOL)isFullPath
{
    if(path != nil)
    {
        if([self isDirectory:path])
        {
            NSString* lastc = [path substringFromIndex:path.length - 1];
            if([lastc compare:@"/"] != NSOrderedSame)
            {
                path = [path stringByAppendingString:@"/"];
            }
        }
        NSFileManager*    myFile   = [NSFileManager defaultManager];
        NSArray*        fileList;
        NSMutableArray*    ret         = [[NSMutableArray alloc]initWithCapacity:0];
        if (deep)
        {
#ifdef MountainLion
            fileList = [myFile subpathsOfDirectoryAtPath:path error:nil];
#else
            fileList = [myFile subpathsAtPath:path];
#endif
        }
        else
        {
            fileList = [myFile contentsOfDirectoryAtPath:path error:nil];
        }
        
        for(int i=0; i<[fileList count]; i++) {
            NSString* file = [fileList objectAtIndex:i];
            
            if([file length] != 0) {
                if([file characterAtIndex:0] == '.') continue;
                if (onD && onF) {
                    // nop
                }
                else if (onD) {
                    if([self isFile:[path stringByAppendingPathComponent:file]]) continue;
                }
                else if (onF) {
                    if([self isDirectory:[path stringByAppendingPathComponent:file]]) continue;
                }
                
                if(isFullPath)
                    [ret addObject:[path stringByAppendingPathComponent:[fileList objectAtIndex:i]]];
                else
                    [ret addObject:[fileList objectAtIndex:i]];
            }
        }
        return ret;
    }
    return nil;
}

// 現在のディレクトリを取得
+ (NSString*)getCurDir:(NSString*)path
{
    NSString* topStr = [path substringToIndex:1];
    if([topStr compare:@"\""] == NSOrderedSame)
    {
        // nop
    }
    else {
        path = [path stringByAppendingString:@"\""];
        path = [@"\"" stringByAppendingString:path];
    }
    
    NSString* command1 = [[@"fpath=" stringByAppendingString:path] stringByAppendingString:@";fdir=\"${fpath%/*}\"; echo $fdir"];
    NSArray* command = @[@"-c", command1];
    return [self doShellScript:command];
}

// 最終更新日を取得
+ (NSString*)getFileModificateDate:(NSString*)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attribute = [fm attributesOfItemAtPath:path error:nil];
    NSDate *modificationDate = [attribute objectForKey:NSFileModificationDate];
    NSDateFormatter *df =[[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    return [df stringFromDate:modificationDate];
}

// ファイルのアイコン取得
+ (NSImage*)getIcon:(NSString*)path isFileTypeIcon:(BOOL)isFType
{
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    if(isFType)
    {
        NSMutableString *ext = [NSMutableString stringWithString:[[path pathExtension]lowercaseString]];
        if ([ext isEqualToString:@""]) {
            NSString *uti = [ws typeOfFile:path error:nil];
            [ext setString:uti];
        }
        return [ws iconForFileType:ext];
    }else{
        return [ws iconForFile:path];
    }
}

+ (NSString*)getFileSize:(NSString*)path
{
    NSString *fileSize;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:path])
    {
        return nil;
    }
    NSError *err;
    NSDictionary *fileInfo = [fm attributesOfItemAtPath:path error:&err];
    if(err)
    {
        Log(err.description);
        return nil;
    }
    NSNumber *fs = [fileInfo objectForKey:NSFileSize]; // Byte
    double dFileSize = [fs doubleValue];
    
    if(dFileSize < 1000){
        fileSize = [NSString stringWithFormat:@"%@ B",[KZLibs getRoundedStr:dFileSize digit:0]];
    }
    else if (dFileSize >= 1000){
        dFileSize /= 1000;
        if(dFileSize < 1000){
            fileSize = [NSString stringWithFormat:@"%@ KB",[KZLibs getRoundedStr:dFileSize digit:0]];
        }else{
            dFileSize /= 1000;
            if(dFileSize < 1000){
                fileSize = [NSString stringWithFormat:@"%@ MB",[KZLibs getRoundedStr:dFileSize digit:1]];
            }else{
                dFileSize /= 1000;
                if(dFileSize < 1000){
                    fileSize = [NSString stringWithFormat:@"%@ GB",[KZLibs getRoundedStr:dFileSize digit:1]];
                }else{
                    dFileSize /= 1000;
                    fileSize = [NSString stringWithFormat:@"%@ TB",[KZLibs getRoundedStr:dFileSize digit:1]];
                }
            }
        }
    }
    return fileSize;
}

+ (BOOL)forceDeleteFile:(NSString*)path
{
    NSError *err;
    [NSFileManager.defaultManager removeItemAtPath:path error:&err];
    
    if (err) {
        NSString *ngfol = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"削除"];
        
        if (![NSFileManager.defaultManager fileExistsAtPath:ngfol])
            [NSFileManager.defaultManager createDirectoryAtPath:ngfol withIntermediateDirectories:YES attributes:nil error:nil];
        
        [NSFileManager.defaultManager moveItemAtPath:path toPath:[ngfol stringByAppendingPathComponent:[path lastPathComponent]] error:nil];
    }
    return YES;
}

+ (BOOL)forceMoveFile:(NSString*)atPath toPath:(NSString*)toPath
{
    [NSFileManager.defaultManager removeItemAtPath:toPath error:nil];
    [NSFileManager.defaultManager copyItemAtPath:atPath toPath:toPath error:nil];
    return [KZLibs forceDeleteFile:atPath];
}

#pragma mark -
#pragma mark script func
+ (NSString*)doShellScript:(NSArray*)command
{
    NSPipe* pipe = [NSPipe pipe];
    NSFileHandle* file = pipe.fileHandleForReading;
    
    NSTask* task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = command;
    task.standardOutput = pipe;
    
    [task launch];
    
    NSData* data = [file readDataToEndOfFile];
    [file closeFile];
    NSString* output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    output = [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return output;
}

+ (NSString*)doShellScriptWithEnv:(NSArray*)command envs:(NSDictionary*)dicEnv
{
    NSPipe* pipe = [NSPipe pipe];
    NSFileHandle* file = pipe.fileHandleForReading;
    
    NSTask* task = [[NSTask alloc] init];
    [task setEnvironment:dicEnv];
    NSLog(@"%@", [[task environment] description]);
    task.launchPath = @"/bin/bash";
    task.arguments = command;
    task.standardOutput = pipe;
    
    [task launch];
    
    NSData* data = [file readDataToEndOfFile];
    [file closeFile];
    NSString* output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    output = [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return output;
}

#pragma mark -
#pragma mark dialog func
+ (BOOL)alertMessage:(NSString*)message info:(NSString*)info isOnlyAlert:(BOOL)isOnlyAlert window:(NSWindow*)window okTitle:(NSString*)okTitle ngTitle:(NSString*)ngTitle
{
    __block BOOL isContinue = NO;
    NSAlert* alt = [[NSAlert alloc] init];
    alt.messageText = message;
    alt.informativeText = info;
    alt.alertStyle = NSAlertStyleWarning;
    if (isOnlyAlert) {
        [alt addButtonWithTitle:ngTitle];
    }
    else {
        [alt addButtonWithTitle:okTitle];
        [alt addButtonWithTitle:ngTitle];
    }
    
    alt.alertStyle = NSAlertStyleWarning;
    [alt beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if ( returnCode == NSAlertFirstButtonReturn ) {
            isContinue = (isOnlyAlert)? NO : YES;
        }
        else if ( returnCode == NSAlertSecondButtonReturn ) {
            isContinue = NO;
        }
        
        // Get the button pressed - see NSAlert's Button Return Values.
        [NSApp stopModalWithCode:returnCode];
    }];
    [NSApp runModalForWindow:alt.window];
    return isContinue;
}

+ (BOOL)alertMessage:(NSString*)message info:(NSString*)info isOnlyAlert:(BOOL)isOnlyAlert window:(NSWindow*)window
{
    __block BOOL isContinue = NO;
    NSAlert* alt = [[NSAlert alloc] init];
    alt.messageText = message;
    alt.informativeText = info;
    alt.alertStyle = NSAlertStyleWarning;
    if (isOnlyAlert) {
        [alt addButtonWithTitle:@"終了"];
    }
    else {
        [alt addButtonWithTitle:@"続行"];
        [alt addButtonWithTitle:@"終了"];
    }
    
    alt.alertStyle = NSAlertStyleWarning;
    [alt beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if ( returnCode == NSAlertFirstButtonReturn ) {
            isContinue = (isOnlyAlert)? NO : YES;
        }
        else if ( returnCode == NSAlertSecondButtonReturn ) {
            isContinue = NO;
        }
        
        // Get the button pressed - see NSAlert's Button Return Values.
        [NSApp stopModalWithCode:returnCode];
    }];
    [NSApp runModalForWindow:alt.window];
    return isContinue;
}

// 返値は選択したファイル/フォルダのパス
+(NSArray*)openFileDialog:(NSString*)title multiple:(BOOL)mp selectFile:(BOOL)selectFile selectDir:(BOOL)selectDir
{
    NSArray* folderPaths = nil;
    NSMutableArray* retPath = [NSMutableArray array];
    NSOpenPanel* opnPanel = [NSOpenPanel openPanel];
    opnPanel.message = title;
    opnPanel.canChooseDirectories = selectDir;
    opnPanel.canChooseFiles = selectFile;
    opnPanel.canCreateDirectories = YES;
    opnPanel.allowsMultipleSelection = mp;
    NSUInteger ret = [opnPanel runModal];
    
    if (ret == NSFileHandlingPanelOKButton) {
        folderPaths = [opnPanel URLs];
        for (NSURL* url in folderPaths) {
            [retPath addObject:[url path]];
        }
    }
    else {
        retPath = nil;
    }

    
    return retPath;

}

+(NSArray*)openFileDialog:(NSString*)title multiple:(BOOL)mp selectFile:(BOOL)selectFile selectDir:(BOOL)selectDir window:(NSWindow*)parent
{
    __block NSArray* folderPaths = nil;
    __block NSMutableArray* retPath = [NSMutableArray array];
    NSOpenPanel* opnPanel = [NSOpenPanel openPanel];
    opnPanel.message = title;
    opnPanel.canChooseDirectories = selectDir;
    opnPanel.canChooseFiles = selectFile;
    opnPanel.canCreateDirectories = YES;
    opnPanel.allowsMultipleSelection = mp;
    
    [parent beginSheet:opnPanel completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSFileHandlingPanelOKButton) {
            folderPaths = [opnPanel URLs];
            for (NSURL* url in folderPaths) {
                [retPath addObject:[url path]];
            }
        }
        else {
            retPath = nil;
        }
    }];
    
    return retPath;
}

#pragma mark -
#pragma mark NetFS func
+ (NSString*)getIfExistLocalVolumes:(NSString*)folderName
{
    NSString* foundPath = nil;
    NSArray* localVols = [NSFileManager.defaultManager mountedVolumeURLsIncludingResourceValuesForKeys:@[NSURLVolumeNameKey] options:NSVolumeEnumerationSkipHiddenVolumes];
    for (NSURL* path in localVols) {
        NSString* localFolder = [path lastPathComponent];
        if ([KZLibs isExistString:localFolder searchStr:folderName]) {
            foundPath = [path relativePath];
            break;
        }
    }
    return foundPath;
}

+ (BOOL)mountSetver:(NSString*)serverAddress mountFolder:(NSString*)mountFolder user:(NSString*)user pass:(NSString*)pass
{
#ifdef MountainLion
    NSString* escaped = [mountFolder stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else
    NSString* escaped = [mountFolder stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
#endif
    NSString* mountPath = [[serverAddress stringByAppendingString:@"/"] stringByAppendingString:escaped];
    
    NSURL *url = [NSURL URLWithString:mountPath];
    NSURL *mountpathLocal = [NSURL fileURLWithPath:@"/Volumes/" isDirectory:YES];
    Log(mountPath);
    int result = NetFSMountURLSync((__bridge CFURLRef)url, (__bridge CFURLRef)mountpathLocal, (__bridge CFStringRef)user, (__bridge CFStringRef)pass, NULL, NULL, NULL);
    if(result < 0)
        return NO;
    
    return YES;
}


+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request error:(NSError **)error
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData *receivedData = nil;
#ifndef MountainLion
    __block NSError* er;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"did finish download.\n%@", response.URL);
        if (error) {
            NSLog(@"%@", error);
            er = error;
            dispatch_semaphore_signal(semaphore);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            dispatch_semaphore_signal(semaphore);
            return;
        }
        receivedData = data;
        dispatch_semaphore_signal(semaphore);
        
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    *error = er;
    return receivedData;
#else
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   if (error.code == -1003) {
                                       NSLog(@"not found hostname. targetURL=%@", request.URL);
                                   } else if (error.code == -1019) {
                                       NSLog(@"auth error. reason=%@", error);
                                   } else {
                                       NSLog(@"unknown error occurred. reason = %@", error);
                                   }
                                   dispatch_semaphore_signal(semaphore);
                                   return;
                               }
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               if (httpResponse.statusCode != 200) {
                                   NSLog(@"404 NOT FOUND ERROR. targetURL=%@", request.URL);
                                   dispatch_semaphore_signal(semaphore);
                                   return;
                               }
                               receivedData = data;
                               dispatch_semaphore_signal(semaphore);
                           }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
#endif
    return receivedData;
}

+ (BOOL)unmountVolumeAtURL:(NSURL *)url
{
    BOOL returnValue = NO;
    DASessionRef session = DASessionCreate(kCFAllocatorDefault);
    if (session) {
        DADiskRef disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, (__bridge CFURLRef)url);
        if (disk) {
            DADiskUnmount(disk, kDADiskUnmountOptionForce, NULL , NULL);
            returnValue = YES;
            CFRelease(disk);
        } else {
            NSLog(@"Could't create disk reference from %@", url.path);
        }
    } else {
        NSLog(@"Could't create DiskArbritation session");
    }
    if (session) CFRelease(session);
    return returnValue;
}

+ (void)unMountDisk:(NSString*)name
{
    NSString *volumePath = [KZLibs getIfExistLocalVolumes:name];
    if(![self unmountVolumeAtURL:[NSURL fileURLWithPath:volumePath]]) {
        NSLog(@"error unmount");
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while(1) {
            __block NSString *fp = @"";
            if (![NSThread isMainThread]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    fp = [KZLibs getIfExistLocalVolumes:name];
                });
            }
            else {
                fp = [KZLibs getIfExistLocalVolumes:name];
            }
            if (!fp)
                break;
        }
        dispatch_semaphore_signal(semaphore);
    });
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
}

#pragma mark -
#pragma mark Image Funcs
// 使わなくなった
+ (NSString*)getImageColor:(NSString*)path
{
    NSString *retColor = @"";
    /*if([path hasSuffix:@"pdf"]){
     return @"";
     }
     
     NSString *command1 = [NSString stringWithFormat:@"magick identify -format \"%%[colorspace],%%[depth]\n\" \"%@\" | head -n 1",path];
     //NSString *command1 = [NSString stringWithFormat:@"gs -o - -sDEVICE=inkcov %@",path];
     NSArray *command = @[@"--login", @"-c", command1];
     NSString *retInfo = [self doShellScriptWithEnv:command];
     NSArray *sptInfo = [retInfo componentsSeparatedByString:@","];
     if([sptInfo[0] compare:@"Gray"] == NSOrderedSame){
     if([sptInfo[1] intValue] == 1){
     retColor = @"Mono";
     }
     else{
     retColor = @"Gray";
     }
     }else{
     retColor = sptInfo[0];
     }
     */
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
    CGImageRef imageRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    NSLog(@" components=%zu", CGColorSpaceGetNumberOfComponents(colorSpace));
    NSLog(@" colorTableCount=%zu", CGColorSpaceGetColorTableCount(colorSpace));
    NSLog(@" baseSpace=%@", CGColorSpaceGetBaseColorSpace(colorSpace));
    NSLog(@" colorSpace=%@", CGColorSpaceCopyName(colorSpace));
    NSString *colorSpaceName = CFBridgingRelease(CGColorSpaceCopyName(colorSpace));
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    if(colorSpaceModel == 1){
        retColor = @"RGB";
    }else if (colorSpaceModel == 2){
        retColor = @"CMYK";
    }else if([@"kCGColorSpaceGenericGray" compare:colorSpaceName] == NSOrderedSame ||
             [@"kCGColorSpaceGenericGrayGamma2_2" compare:colorSpaceName] == NSOrderedSame ||
             [@"k​CGColor​Space​Extended​Gray" compare:colorSpaceName] == NSOrderedSame){
        retColor = @"Mono";
    }else if (colorSpaceModel == 0){
        retColor = @"Gray";
    }else{
        retColor = @"other";
    }
    return retColor;
}

+ (NSUInteger)getPDFPageCount:(NSString*)path
{
    PDFDocument *doc = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:path]];
    return doc.pageCount;
}

+ (NSSize)getPDFSizeMm:(NSString*)path
{
    PDFDocument *doc = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:path]];
    PDFPage *page = [doc pageAtIndex: 0];
    NSRect rc = [page boundsForBox:kPDFDisplayBoxMediaBox];
    return NSMakeSize([self pixcelToMm:rc.size.width dpi:72.0], [self pixcelToMm:rc.size.height dpi:72.0]);
}

+ (NSUInteger)getTIFFPageCount:(NSString*)path
{
    NSData *tifdata = [NSData dataWithContentsOfFile:path];
    int len = 0;
    //unsigned char src[len];
    UInt32 byte4 = 0;
    UInt16 byte2 = 0;
    UInt byte1 = 0;
    int8_t ifd[4] = {0,0,0,0};
    
    uint page = 0;
    // ヘッダー「4D 4D」なら上位から下位バイトへ読み、「49 49」なら下位から上位バイトで読む
    [tifdata getBytes:&byte1 length:1];
    BOOL flg = (byte1 == 0x49)? YES : NO;
    
    [tifdata getBytes:&byte4 range:NSMakeRange(4, 4)];
    len = (int)(flg)? byte4 : CFSwapInt32BigToHost(byte4);
    
    while(len != 0){
        [tifdata getBytes:&byte2 range:NSMakeRange(len, 2)];
        len+=2;
        int tagnum = (int)(flg)? byte2 : CFSwapInt16BigToHost(byte2);
        len += tagnum * 12;
        [tifdata getBytes:&byte4 range:NSMakeRange(len, 4)];
        [tifdata getBytes:&ifd range:NSMakeRange(len, 4)];
        len = (int)(flg)? byte4 : CFSwapInt32BigToHost(byte4);
        page++;
    }
    
    
    return page;
}

+ (NSData*)cvtCGImage2Data:(CGImageRef)rep
{
    NSBitmapImageRep* bmp_rep = [[NSBitmapImageRep alloc] initWithCGImage:rep];
    [bmp_rep setProperty:NSImageColorSyncProfileData withValue:nil];
    NSDictionary* prop = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:NSImageInterlaced];
    NSData *data = [bmp_rep representationUsingType:NSPNGFileType properties:prop];
    return data;
}

+ (NSImage *)resizeImage:(NSImage *)sourceImage width:(float)resizeWidth height:(float)resizeHeight
{
    
    NSImage *resizedImage = [[NSImage alloc] initWithSize: NSMakeSize(resizeWidth, resizeHeight)];
    
    NSSize   originalSize = [sourceImage size];
    
    [resizedImage lockFocus];
    
    [sourceImage drawInRect: NSMakeRect(0, 0, resizeWidth, resizeHeight) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
    
    [resizedImage unlockFocus];
    
    return resizedImage;
    
}

+ (BOOL)pdf2jpg:(NSData*)page path:(NSString*)savePath x:(int)x y:(int)y w:(int)w h:(int)h ratio:(double)ratio
{
    NSImage* img;
    
    NSPDFImageRep* pdfImageRep = [[NSPDFImageRep alloc] initWithData:page];
    if(!pdfImageRep)
    {
        return NO;
    }
    NSSize size;
    size.width = w*ratio;//[self mmToPixcel:w*ratio dpi:72];
    size.height = h*ratio;//[self mmToPixcel:h*ratio dpi:72];
    
    img = [[NSImage alloc] initWithSize:size];
    
    if (!img)
    {
        return NO;
    }
    [img lockFocus];
    [pdfImageRep drawInRect:NSMakeRect(-1*[self mmToPixcel:x*ratio dpi:72], -1*[self mmToPixcel:y*ratio dpi:72], [pdfImageRep size].width * ratio, [pdfImageRep size].height * ratio)];
    [img unlockFocus];
    
    NSData* tiffRep = [img TIFFRepresentation];
    NSBitmapImageRep* imgRep = [[NSBitmapImageRep alloc] initWithData:tiffRep];
    
    if(!imgRep)
    {
        return NO;
    }
    
    // Jpg出力
    NSDictionary* propJPG;
    propJPG = [NSDictionary dictionaryWithObjectsAndKeys:
               [NSNumber numberWithInt:1.0],
               NSImageCompressionFactor,
               nil];
    NSData* jpgData;
    BOOL  bResult = YES;
    jpgData = [imgRep representationUsingType:NSJPEGFileType properties:propJPG];
    //NSString* fname = [NSString stringWithFormat:@"%s/%s.jpg", [savePath UTF8String],[filename UTF8String]];
    bResult = [jpgData writeToFile:savePath atomically:YES];
    if (!bResult) {
        NSLog(@"Err");
    }
    
    return bResult;
}

// 画面キャプチャ
+ (void)captScreen:(NSRect)rect savePath:(NSString*)savePath
{
    if ([savePath isEqualToString:@""]) {
        NSLog(@"保存パスが未指定です captScreen");
        return;
    }
    CGWindowID windowID = 0;
    CGImageRef screen;
    
    if ([self checkRectIsZero:rect]) {
        screen = CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionOnScreenBelowWindow, windowID, kCGWindowImageDefault);
    }else {
        screen = CGWindowListCreateImage(CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height), kCGWindowListOptionOnScreenBelowWindow, windowID, kCGWindowImageDefault);
    }
    
    [[self cvtCGImage2Data:screen] writeToFile:savePath atomically:YES];
    CFRelease(screen);
}

+ (NSSize)getImageSize:(NSString*)src
{
    NSImage* img = [[NSImage alloc] initWithContentsOfFile:src];
    NSBitmapImageRep* rep = [NSBitmapImageRep imageRepWithData:[img TIFFRepresentation]];
    return NSMakeSize(rep.pixelsWide,
                      rep.pixelsHigh);
}

#pragma mark -
#pragma mark Other Funcs
+ (BOOL)checkRectIsZero:(NSRect)src
{
    if (src.size.width == 0 && src.size.height == 0) {
        return YES;
    }
    return NO;
}
+ (BOOL)isEqualToSize:(NSSize)src destination:(NSSize)dest
{
    if((src.width == dest.width) && (src.height == dest.height)){
        return YES;
    }else{
        return NO;
    }
}

+ (NSWindow*)getMainWindow
{
    NSWindow *retWindow = nil;
    CFArrayRef arList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
    NSArray *arWindowList = (__bridge NSArray*)arList;
    NSInteger winNum = 0;
    for (NSDictionary* tblInfo in arWindowList) {
        if (tblInfo[(__bridge __strong id)(kCGWindowIsOnscreen)]) {
            NSString *ownerName = [NSBundle mainBundle].infoDictionary[(__bridge __strong id)kCFBundleNameKey];
            NSString *winOwner = tblInfo[(__bridge __strong id)(kCGWindowOwnerName)];
            if ([KZLibs isEqual:ownerName compare:winOwner]) {
                winNum = [tblInfo[(__bridge __strong id)(kCGWindowNumber)] integerValue];
                break;
            }
        }
    }
    CFRelease(arList);
    retWindow = [NSApp windowWithWindowNumber:winNum];
    return retWindow;
}
@end
