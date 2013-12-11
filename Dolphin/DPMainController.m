//
//  DPMainController.m
//  Dolphin
//
//  Created by Jiahao Li on 12/10/13.
//  Copyright (c) 2013 Jiahao Li. All rights reserved.
//

#import "DPMainController.h"

@interface DPMainController ()

@property (weak) IBOutlet NSTextField *urlField;
@property (weak) IBOutlet NSTextField *pathField;
@property (weak) IBOutlet NSButton *browseButton;
@property (weak) IBOutlet NSButton *downloadButton;

@end

@implementation DPMainController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[self pathField] setStringValue:[@"~/Music/虾米" stringByExpandingTildeInPath]];
}

- (IBAction)browse:(id)sender {
    NSOpenPanel *saveDlg = [NSOpenPanel openPanel];
    
    
    [saveDlg setDirectoryURL:[NSURL fileURLWithPath:[[self pathField] stringValue]]];
    
    [saveDlg setCanCreateDirectories:YES];
    [saveDlg setCanChooseDirectories:YES];
    
    if ([saveDlg runModal] == NSOKButton)
    {
        NSURL *url = [saveDlg URL];
        BOOL isDir = NO;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDir]
            && isDir) {
            [[self pathField] setStringValue:url.path];
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Dolphin 不高兴"
                                             defaultButton:@"确认"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"路径无效, 再选一个吧.. "];
            
            [alert runModal];
        }
    }
}

- (void)initiateDownloadWithType:(NSString *)type
                              ID:(int)ID
                       Directory:(NSString *)path
{
    NSString *command = [NSString stringWithFormat:@"xiami %@ download %d -o \\\"%@\\\"; open \\\"%@\\\"", type, ID, path, path];
    NSString *s = [NSString stringWithFormat:@"tell application \"Terminal\" to do script \"%@\"", command];
    
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource: s];
    [as executeAndReturnError:nil];
}

- (IBAction)download:(id)sender {
    NSString *url = [[self urlField] stringValue];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"xiami.com/song/([0-9]*)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:url options:0 range:NSMakeRange(0, [url length])];
    
    if (result) {
        NSRange range = [result rangeAtIndex:1];
        int songID = [[url substringWithRange:range] intValue];
        
        [self initiateDownloadWithType:@"single" ID:songID Directory:[[self pathField] stringValue]];
    } else {
        regex = [NSRegularExpression regularExpressionWithPattern:@"xiami.com/album/([0-9]*)"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:nil];
        result = [regex firstMatchInString:url options:0 range:NSMakeRange(0, [url length])];
        
        if (result) {
            NSRange range = [result rangeAtIndex:1];
            int songID = [[url substringWithRange:range] intValue];
            
            [self initiateDownloadWithType:@"album" ID:songID Directory:[[self pathField] stringValue]];
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Dolphin 不高兴"
                                             defaultButton:@"确认"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"哦这不是一个有效的歌曲地址.. "];
            
            [alert runModal];
        }
    }
    
}

@end
