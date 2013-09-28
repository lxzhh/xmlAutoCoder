//
//  AppDelegate.m
//  AutomaticCoder
//
//  Created by 张 玺 on 12-8-20.
//  Copyright (c) 2012年 me.zhangxi. All rights reserved.
//

#import "AppDelegate.h"
#import "JsonObject.h"


@implementation AppDelegate

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if(flag == NO)
    {
        [self.window makeKeyAndOrderFront:nil];
    }
    return YES;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}

- (IBAction)json:(id)sender {

    json = [[JSONWindowController alloc] initWithWindowNibName:@"JSONWindowController"];
    [[json window] makeKeyAndOrderFront:nil];
}

- (IBAction)xmlParse:(id)sender{
    xmlvc = [[XMLWindowController alloc] initWithWindowNibName:@"XMLWindowController"];
    [[xmlvc window] makeKeyAndOrderFront:nil];
}
@end
