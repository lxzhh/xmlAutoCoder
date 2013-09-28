//
//  XMLWindowController.h
//  AutomaticCoder
//
//  Created by zheng honghonghao on 12-8-21.
//  Copyright (c) 2012年 chopsticks. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface XMLWindowController : NSWindowController
{
  
}
@property(nonatomic, unsafe_unretained)IBOutlet NSTextField *classNameField;
@property(nonatomic, unsafe_unretained)IBOutlet NSTextField *superClassField;
@property(nonatomic, unsafe_unretained)IBOutlet NSTextField *boolkeyField;
@property(nonatomic, unsafe_unretained)IBOutlet NSTextField *startPathField;
@property(nonatomic, unsafe_unretained)IBOutlet NSMatrix *radioButton;
@property(nonatomic, unsafe_unretained)IBOutlet NSTextView *xmlContent;

-(IBAction)generatorClass:(id)sender;
-(IBAction)changeSelect:(id)sender;


@end
