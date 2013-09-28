//
//  XMLWindowController.m
//  AutomaticCoder
//
//  Created by zheng honghonghao on 12-8-21.
//  Copyright (c) 2012年 chopsticks. All rights reserved.
//

#import "XMLWindowController.h"
#import "GDataXMLNode.h"

@interface NSMutableString (AutoMaticCoder)

-(void)appendChildArray:(NSString*)elementName  rootEleName:(NSString*)enode propertyName:(NSString*)pName;

//-(void)appendSelfArray:(NSString*)elementName   rootEleName:(NSString*)enode propertyName:(NSString*)pName;

-(void)changeToZPlanFormatter;
@end




@interface XMLWindowController ()

@end

@implementation XMLWindowController
@synthesize classNameField ;
@synthesize xmlContent ;
@synthesize superClassField;
@synthesize boolkeyField;
@synthesize startPathField;
@synthesize radioButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.window.title = @"XML解析生成器";
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//RadioButton改变选择的触发
-(IBAction)changeSelect:(id)sender{
    //NSLog(@"changeSelect");
    
    NSMatrix *_radioButton = (NSMatrix*)sender;
    //NSLog(@"_radioButton column :%ld",_radioButton.selectedColumn);
    if (_radioButton.selectedColumn == 0) {
        //show
        for (int i = 100; i<=103; i++) {
            NSView *view = [self.window.contentView viewWithTag:i];
            [view setHidden:NO];
        }
    }else if(_radioButton.selectedColumn == 1){
        //hide
        for (int i = 100; i<=103; i++) {
            NSView *view = [self.window.contentView viewWithTag:i];
            [view setHidden:YES];
        }
    }
}

//判断数据类型
-(parseValueType)type:(GDataXMLElement*)element
{
    if ([self hasSameChild:element]) {
        return kChildrenArray;
    }else if([self hasDifferentChildren:element]){
        return kNode;
    }else{
        NSString *stringValue = [element stringValue];
        if([stringValue isEqualToString:@"100"])
            return kNumber;
        else if([stringValue isEqualToString:@"1"] || [stringValue isEqualToString:@"0"])
            return kBool;
        else if([stringValue isEqualToString:@"data"])
            return kData;
        else if([stringValue isEqualToString:@""]&&[[element attributes] count]>0)
        {
            //NSLog(@"attributes!!");
            return kAttribute;
        }
        else return kString;
    }
}


// 类型名
-(NSString *)typeName:(parseValueType)type
{
    switch (type) {
        case kAttribute:
        case kString:
            return @"NSString";
            break;
        case kNumber:
            return @"NSNumber";
            break;
        case kBool:
            return @"BOOL";
            break;
        case kChildrenArray:
        case kSelfArray:
            return @"NSArray";
            break;
        case kData:
            return @"NSData";
            break;
        case kNode:
            return @"id";
            break;

        default:
            break;
    }
    return @"";
}



//判断是否还有下一层
-(BOOL)elementsHasChild:(NSArray*)elements{
    
    for (GDataXMLElement* ele in elements) {
        if ([ele childCount]>0 ) {
            return YES;
        }
    }
    return NO;
}

//判断是否text内容
-(BOOL)isTextKind:(GDataXMLNode*)element{
    return [element.name isEqualToString:@"text"];
}


//判断是否为列表
-(BOOL)hasSameChild:(GDataXMLElement*)element{
    
    
    if ([element childCount]==0) {
        return NO;
    }
    
    for (int i = 0; i< [element childCount]; i++) {
       
        if (![self isTextKind:[[element children] objectAtIndex:i ] ]) {
            NSString *name = [[[element children] objectAtIndex:i ] name];
            NSLog(@"element children name:%@",name);
            NSArray *chilEle = [element elementsForName:name];
            if ([chilEle count]>1) {
                NSLog(@"[chilEle count]:%ld",[chilEle count]);
                return YES;
            }
        }
      
    }
    return NO;
     
    /*
    if ([element childCount]==0) {
        return NO;
    }
    NSString *name = [[[element children] objectAtIndex:0] name];
    for (GDataXMLNode* ele in [element children]){
        if (![self isTextKind:ele]) {
            NSLog(@"name :%@, eleName:%@",name,[ele name]);
            if (![name isEqualToString:[ele name]]) {
                return NO;
            }
        }else{
            return NO;
        }
       
    }
    //NSLog(@"hasSameChild");
    return YES;
     */
}

//本身为1-n的节点
-(BOOL)isArrayElement:(GDataXMLNode*)node inFatherNode:(GDataXMLElement*)fnode{
    
     NSArray *chilEle = [fnode elementsForName:[node name]];
    if ([chilEle count]>1) {
        return YES;
    }
    return NO;
}

-(BOOL)hasDifferentChildren:(GDataXMLNode*)node{
    
    if ([node childCount] == 0) {
        return NO;
    }
    for (GDataXMLNode *child in [node children]) {
        if ([self isTextKind:child]) {
            return NO;
        }
    }
    return YES;
    
}


-(IBAction)generatorClass:(id)sender{
    NSLog(@"generatorClass");
    switch (radioButton.selectedColumn) {
        case 0:
            [self generatorClassWithDoc];
            break;
        case 1:
            [self generatorClassWithElement];
            break;
        default:
            break;
    }
}


//生成Doc的解析
-(void)generatorClassWithDoc{
    //桌面路径
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *name = classNameField.stringValue;
    NSString *superClassName = [superClassField.stringValue isEqualToString:@""]?@"NSObject":superClassField.stringValue;
    
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:xmlContent.string options:0 error:&error];
    if (!doc) {
        xmlContent.string = @"xml 格式不正确！！";
        return;
    }else{
        
        GDataXMLElement *rootEle = [doc rootElement];
        NSArray *nodes;
        if (startPathField.stringValue && ![startPathField.stringValue isEqualToString:@""]) {
            nodes = [rootEle nodesForXPath:startPathField.stringValue error:nil];
        }else{
            nodes = [NSArray arrayWithObject:rootEle];
        }
        
        if ([nodes count]==0) {
            xmlContent.string = @"路径会不会写错了";
            return;
        }
        rootEle = [nodes objectAtIndex:0];
        NSLog(@"rootEle:%@", rootEle.name);
        
        /*
         for (GDataXMLElement *childElement in [rootEle children]) {
         NSLog(@"childElement name:%@",childElement.name);
         }*/
        
        int level = 1;
        NSMutableArray *elementArr;
        elementArr = [[NSMutableArray alloc] initWithObjects:rootEle, nil];
        NSMutableDictionary *xmlDic = [NSMutableDictionary dictionaryWithCapacity:10];
        
        //一层层遍历，先判断有没有下一层了
        while ( [self elementsHasChild:elementArr]) {
            NSLog(@"level :%d",level);
            
            //对该层的节点遍历
            level++;
            NSMutableArray *anotherArr = [NSMutableArray array];
            for (GDataXMLElement *element in elementArr) {
                
                
                if ([element childCount]>0) {
                    //NSLog(@"element count:%ld",[element childCount]);
                    for ( GDataXMLElement *child in [element children]) {
                        [anotherArr addObject:child];
                        //有的内容节点为重复多个，我们保存在NSArray里面
                        
                        if (![self isTextKind:child]) {
                            
                            
                            //NSLog(@"属性：%@",[child name]);
                            parseValueType type = [self type:child];
                            if ([self isArrayElement:child inFatherNode:element]) {
                                type = kSelfArray;
                            }
                            NSNumber *typeNumber =  [NSNumber numberWithInt:type];
                            //NSLog(@"%ld",[typeNumber integerValue]);
                            if (level == 2) {
                                [xmlDic setObject:typeNumber forKey:[child name]];
                            }
                            
                        }
                    }
                }
            }
            //elementArr 重新赋值，变为下一层，继续循环
            elementArr = anotherArr;
        }
        
        NSLog(@"xmlDic:%@",xmlDic);
        
        //准备模板
        NSMutableString *templateH =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xml" ofType:@"zx1"]
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:nil];
        NSMutableString *templateM =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xml" ofType:@"zx2"]
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:nil];
        NSMutableString *proterty = [NSMutableString string];
        NSMutableString *synthesizeString = [NSMutableString string];
        NSMutableString *deallocString = [NSMutableString string];
        
        
        //.h
        //name
        //property
        
        for(NSString *key in [xmlDic allKeys])
        {
            parseValueType type = (parseValueType)[(NSNumber*)[xmlDic objectForKey:key] integerValue];
            [synthesizeString appendFormat:@"@synthesize %@;\n",key];
            NSLog(@"type :%d",type);
            switch (type) {
                case kString:
                case kNumber:
                case kChildrenArray:
                case kSelfArray:
                case kData:
                case kNode:
                case kAttribute:
                    [proterty appendFormat:@"@property (nonatomic,retain) %@ *%@;\n",[self typeName:type],key];
                    [deallocString appendFormat:@"[%@ release];\n",key];
                    break;
                case kBool:
                    [proterty appendFormat:@"@property (nonatomic,assign) %@  %@;\n",[self typeName:type],key];
                    break;
                    
                default:
                    break;
            }
        }
         NSLog(@"proterty:%@",proterty);
        //.m
        //NSCoding
        //name
        NSMutableString *parse = [NSMutableString string];
        
        
        /**拼凑主体解析代码**/
        
        [parse appendFormat:@"\t GDataXMLElement *rootNode = [doc rootElement];\n"];
        [parse appendFormat:@"\t NSArray *nodes_lev1 = [rootNode nodesForXPath:@\"\%@\" error:nil];\n",startPathField.stringValue];
        [parse appendFormat:@"\t GDataXMLElement *enode;\n"];
        [parse appendFormat:@"\t if([nodes_lev1 count]>0){\n"];
        [parse appendFormat:@"\t enode = (GDataXMLElement*)[nodes_lev1 objectAtIndex:0];\n\n"];
        //重新设置一下rootElement
        rootEle = [nodes objectAtIndex:0];
        NSLog(@"重新设置一下rootElement:%@",[rootEle name]);
        [parse appendFormat:@"  \t}\n"];
        /*
        //分两种情况，1，子节点是列表的
        if ([self hasSameChild:rootEle]) {
            GDataXMLElement *anyChild = [[rootEle children] objectAtIndex:0];
            [parse appendGDataXMLElement:anyChild rootEleName:@"enode"];
            
            //分两种情况 2，子节点是字段的
        }else{
         }
        */    
        [[xmlDic allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *key = (NSString*)obj;
            parseValueType type = (parseValueType)[(NSNumber*)[xmlDic objectForKey:key] integerValue];
            if (type!=kSelfArray) {
                [parse appendFormat:@"\t NSArray *listarr_%ld = [enode elementsForName:@\"%@\"];\n",idx,key];
                [parse appendFormat:@"\t if([listarr_%ld count]>0){\n",idx];
                [parse appendFormat:@"\t GDataXMLElement *e1_%ld = (GDataXMLElement*)[listarr_%ld objectAtIndex:0];\n",idx,idx];
            }
           
            
            switch (type) {
                case kString:{
                    
                    [parse appendFormat:@" \tself.%@ = [e1_%ld stringValue];\n",key,idx];
                    break;
                }
                case kNumber:{
                    
                    [parse appendFormat:@" \tself.%@ = [NSNumber numberWithInt:[[e1_%ld stringValue] intValue]];\n",key,idx];
                    break;
                }
                case kBool:{
                    [parse appendFormat:@" \tself.%@ = [[e1_%ld stringValue] isEqualToString:@\"%@\"];\n",key,idx,boolkeyField.stringValue];
                    break;
                }
                case kChildrenArray:{
                    GDataXMLElement *anyEle = [[rootEle elementsForName:key] objectAtIndex:0];
                    GDataXMLElement *anyChild = (GDataXMLElement*)[anyEle childAtIndex:0];
                    [parse appendChildArray:anyChild.name rootEleName:[NSString stringWithFormat:@"e1_%ld",idx] propertyName:anyEle.name];
                    break;
                }
                case kSelfArray:{
                    GDataXMLElement *anyEle = [[rootEle elementsForName:key] objectAtIndex:0];
                    //GDataXMLElement *anyChild = (GDataXMLElement*)[anyEle childAtIndex:0];
                    //[synthesizeString appendFormat:@"@synthesize %@;\n",[anyEle name]];
                    //[deallocString appendFormat:@"[%@ release]",[anyEle name]];
                    [proterty appendFormat:@"@property (nonatomic,retain) %@ *%@;\n",@"NSArray",[anyEle name]];
                    
                     [parse appendChildArray:anyEle.name rootEleName:[NSString stringWithFormat:@"e1_%ld",idx]propertyName:anyEle.name];
                    break;
                }
                case kNode:{
                    [parse appendFormat:@" \tself.%@ = [[[#NodeClass# alloc] initWithXNLElement:e1_%ld] autorelease];\n",key,idx];
                    break;
                }
                default:
                    break;
            }
            [parse appendFormat:@"  \t}\n\n"];
        }];
         //NSLog(@"proterty2:%@",proterty);
    
        
         
        /**拼凑主体解析代码**/
        
        [templateM replaceOccurrencesOfString:@"#parseXML#"
                                   withString:parse
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        [templateM replaceOccurrencesOfString:@"#name#"
                                   withString:name
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        [templateM replaceOccurrencesOfString:@"#synthesize#"
                                   withString:synthesizeString
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        [templateM replaceOccurrencesOfString:@"#dealloc#"
                                   withString:deallocString
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        
        /////////////////////////////////////////////////
        
        
        
        
        [templateH replaceOccurrencesOfString:@"#name#"
                                   withString:name
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        
        [templateH replaceOccurrencesOfString:@"#property#"
                                   withString:proterty
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        
        [templateH replaceOccurrencesOfString:@"#superClass#"
                                   withString:superClassName
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        
        
        
        
        [templateH changeToZPlanFormatter];
        [templateM changeToZPlanFormatter];
        //写文件
        [templateH writeToFile:[NSString stringWithFormat:@"%@/%@.h",docDir,name]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
        [templateM writeToFile:[NSString stringWithFormat:@"%@/%@.m",docDir,name]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
        
        xmlContent.string = @"生成了.h.m(ARC)文件，给您放桌面上了，看看格式对不对。";
        
    }
}


//生成Element的解析
-(void)generatorClassWithElement{
    //桌面路径
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *name = classNameField.stringValue;
    
    
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:xmlContent.string options:0 error:&error];
    if (!doc) {
        xmlContent.string = @"xml 格式不正确！！";
        return;
    }else{
        
        GDataXMLElement *rootEle = [doc rootElement];
        
        NSLog(@"rootEle:%@", rootEle.name);
        
        int level = 1;
        NSMutableArray *elementArr;
        elementArr = [[NSMutableArray alloc] initWithObjects:rootEle, nil];
        NSMutableDictionary *xmlDic = [NSMutableDictionary dictionaryWithCapacity:10];
        
        //一层层遍历，先判断有没有下一层了
        while ( [self elementsHasChild:elementArr]) {
            NSLog(@"level :%d",level);
            
            //对该层的节点遍历
            level++;
            NSMutableArray *anotherArr = [NSMutableArray array];
            for (GDataXMLElement *element in elementArr) {
                
                if ([element childCount]>0) {
                    NSLog(@"element count:%ld",[element childCount]);
                    for ( GDataXMLElement *child in [element children]) {
                        [anotherArr addObject:child];
                        //有的内容节点为重复多个，我们保存在NSArray里面
                        
                        if (![self isTextKind:child]) {
                            
                            NSLog(@"属性：%@",[child name]);
                            
                            NSNumber *typeNumber =  [NSNumber numberWithInt:[self type:child]];
                            NSLog(@"%ld",[typeNumber integerValue]);
                            if (level == 2) {
                                [xmlDic setObject:typeNumber forKey:[child name]];
                            }
                            
                        }
                    }
                }
            }
            //elementArr 重新赋值，变为下一层，继续循环
            elementArr = anotherArr;
        }
        
        NSLog(@"xmlDic:%@",xmlDic);
        
        //准备模板
        NSMutableString *templateH =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"XMLEle" ofType:@"zx1"]
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:nil];
        NSMutableString *templateM =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"XMLEle" ofType:@"zx2"]
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:nil];
        
        //.h
        //name
        //property
        NSMutableString *proterty = [NSMutableString string];
        NSMutableString *synthesizeString = [NSMutableString string];
        NSMutableString *deallocString = [NSMutableString string];
        for(NSString *key in [xmlDic allKeys])
        {
            parseValueType type = (parseValueType)[(NSNumber*)[xmlDic objectForKey:key] integerValue];
            [synthesizeString appendFormat:@"@synthesize %@;\n",key];
            switch (type) {
                case kString:
                case kNumber:
                case kChildrenArray:
                case kData:
                case kNode:
                case kAttribute:
                    [proterty appendFormat:@"@property (nonatomic,retain) %@ *%@;\n",[self typeName:type],key];
                    [deallocString appendFormat:@"[%@ release];\n",key];
                    break;
                case 2:
                    [proterty appendFormat:@"@property (nonatomic,assign) %@  %@;\n",[self typeName:type],key];
                    break;
                    
                default:
                    break;
            }
        }
       
        [templateH replaceOccurrencesOfString:@"#name#"
                                   withString:name
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        
        [templateH replaceOccurrencesOfString:@"#property#"
                                   withString:proterty
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateH.length)];
        
        //.m
        //NSCoding
        //name
        NSMutableString *parse = [NSMutableString string];
        
        /**拼凑主体解析代码**/
        
        //重新设置一下rootElement
        rootEle = [doc rootElement];
        NSLog(@"重新设置一下rootElement:%@",[rootEle name]);
        
        
        [[xmlDic allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *key = (NSString*)obj;
            
            [parse appendFormat:@"\t NSArray *listarr_%ld = [enode elementsForName:@\"%@\"];\n",idx,key];
            [parse appendFormat:@"\t if([listarr_%ld count]>0){\n",idx];
            [parse appendFormat:@"\t GDataXMLElement *e1_%ld = (GDataXMLElement*)[listarr_%ld objectAtIndex:0];\n",idx,idx];
            
            parseValueType type = (parseValueType)[(NSNumber*)[xmlDic objectForKey:key] integerValue];
            switch (type) {
                case kString:{
                    [parse appendFormat:@" \tself.%@ = [e1_%ld stringValue];\n",key,idx];
                    break;
                }
                case kNumber:{
                    
                    [parse appendFormat:@" \tself.%@ = [NSNumber numberWithInt:[[e1_%ld stringValue] intValue]];\n",key,idx];
                    break;
                }
                case kBool:{
                    [parse appendFormat:@" \tself.%@ = [[e1_%ld stringValue]isEqualToString:@\"%@\"];\n",key,idx,boolkeyField.stringValue];
                    break;
                }
                
                case kAttribute:{
                    GDataXMLElement *attrEle = [[rootEle elementsForName:key] objectAtIndex:0];
                    
                    GDataXMLNode *firstNode = [[attrEle attributes] objectAtIndex:0];
                   NSLog(@"attrEle attributes:%@",[[attrEle attributeForName:@"data"] stringValue]);
                    //[parse appendFormat:@" \tGDataXMLNode *firstNode_%ld = [[e1_%ld attributes] objectAtIndex:0];\n",idx,idx];
                    //[parse appendFormat:@" \tNSString *attribute_%ld = [firstNode_%ld name];\n",idx,idx];
                    [parse appendFormat:@" \tself.%@ = [[e1_%ld attributeForName:@\"%@\"] stringValue];\n",key,idx,[firstNode name]];
                    break;
                }
                case kChildrenArray:{
                    
                    break;
                }
                default:
                    break;
            }
            [parse appendFormat:@"  \t}\n\n"];
        }];
        
        
        
        /**拼凑主体解析代码**/
        
        [templateM replaceOccurrencesOfString:@"#parseXML#"
                                   withString:parse
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        [templateM replaceOccurrencesOfString:@"#name#"
                                   withString:name
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        [templateM replaceOccurrencesOfString:@"#synthesize#"
                                   withString:synthesizeString
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        [templateM replaceOccurrencesOfString:@"#dealloc#"
                                   withString:deallocString
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
        
        
        /////////////////////////////////////////////////
        //写文件
        [templateH changeToZPlanFormatter];
        [templateM changeToZPlanFormatter];
        [templateH writeToFile:[NSString stringWithFormat:@"%@/%@.h",docDir,name]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
        [templateM writeToFile:[NSString stringWithFormat:@"%@/%@.m",docDir,name]
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:nil];
        
        xmlContent.string = @"生成了.h.m(ARC)文件，给您放桌面上了，看看格式对不对。";
        
    }
}
@end

///////////////////////////////////////////




@implementation NSMutableString (AutoMaticCoder)

-(void)appendChildArray:(NSString*)elementName  rootEleName:(NSString*)enode propertyName:(NSString*)pName{
    [self appendFormat:@"\t NSArray *arr = [%@ elementsForName:@\"%@\"];\n",enode,elementName];
    [self appendFormat:@"  NSMutableArray *elementArr = [NSMutableArray array]; \n"];
    [self appendFormat:@"\t  for (GDataXMLElement *element in arr){\n"];
    [self appendFormat:@"  #subclass# *subObject = [[#subclass# alloc] initWithXMLElement:element];\n"];
    [self appendFormat:@"  [elementArr addObject:subObject];\n"];
    [self appendFormat:@"  \t}\n"];
    [self appendFormat:@" self.%@ = [NSArray arrayWithArray:elementArr];\n",pName];
}

-(void)changeToZPlanFormatter{
    [self replaceOccurrencesOfString:@"NSError"
                          withString:@"ZError"
                             options:NSCaseInsensitiveSearch
                               range:NSMakeRange(0, self.length)];
    
    [self replaceOccurrencesOfString:@"NSArray"
                               withString:@"ZArray"
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, self.length)];
    
    [self replaceOccurrencesOfString:@"NSMutableArray"
                          withString:@"ZMutableArray"
                             options:NSCaseInsensitiveSearch
                               range:NSMakeRange(0, self.length)];
    
    [self replaceOccurrencesOfString:@"initWithXMLString"
                          withString:@"zInitWithXMLString"
                             options:NSCaseInsensitiveSearch
                               range:NSMakeRange(0, self.length)];
    
    [self replaceOccurrencesOfString:@"nodesForXPath"
                          withString:@"zNodesForXPath"
                             options:NSCaseInsensitiveSearch
                               range:NSMakeRange(0, self.length)];
    
    [self replaceOccurrencesOfString:@"elementsForName"
                          withString:@"zElementsForName"
                             options:NSCaseInsensitiveSearch
                               range:NSMakeRange(0, self.length)];
}

@end