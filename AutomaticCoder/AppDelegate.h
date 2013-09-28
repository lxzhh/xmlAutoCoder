//
//  AppDelegate.h
//  AutomaticCoder
//
//  Created by 张 玺 on 12-8-20.
//  Copyright (c) 2012年 me.zhangxi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSONWindowController.h"
#import "XMLWindowController.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    JSONWindowController *json;
    XMLWindowController *xmlvc;
}
@property (assign) IBOutlet NSWindow *window;


- (IBAction)json:(id)sender;

- (IBAction)xmlParse:(id)sender;

@end
