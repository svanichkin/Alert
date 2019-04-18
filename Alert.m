//
//  Alert.m
//  v.1.5
//
//  Created by Сергей Ваничкин on 3/12/19.
//  Copyright © 2019 Сергей Ваничкин. All rights reserved.
//

#import "Alert.h"

@interface DefaultButtonStyle ()

@property (nonatomic, strong) NSString *stringHolder;

@end

@implementation DefaultButtonStyle

-(instancetype)initWithCharactersNoCopy:(unichar  *)characters
                                 length:(NSUInteger)length
                           freeWhenDone:(BOOL      )freeBuffer
{
    if (self = [super init])
    {
        self.stringHolder =
        [NSString.alloc
         initWithCharactersNoCopy:characters
         length:length
         freeWhenDone:freeBuffer];
    }
    return self;
}

-(NSUInteger)length
{
    return
    self.stringHolder.length;
}

-(unichar)characterAtIndex:(NSUInteger)index
{
    return
    [self.stringHolder characterAtIndex:index];
}

@end

@implementation CancelButtonStyle

-(instancetype)initWithCharactersNoCopy:(unichar  *)characters
                                 length:(NSUInteger)length
                           freeWhenDone:(BOOL      )freeBuffer
{
    self = [super initWithCharactersNoCopy:characters
                                    length:length
                              freeWhenDone:freeBuffer];

    return self;
}

@end

@implementation DestructiveButtonStyle

-(instancetype)initWithCharactersNoCopy:(unichar  *)characters
                                 length:(NSUInteger)length
                           freeWhenDone:(BOOL      )freeBuffer
{
    self =
    [super initWithCharactersNoCopy:characters
                             length:length
                       freeWhenDone:freeBuffer];

    return self;
}

@end

@implementation NSString (AlertButtonStyle)

-(CancelButtonStyle      *)cancelStyle
{
    return
    [CancelButtonStyle.alloc initWithString:self];
}

-(DestructiveButtonStyle *)destructiveStyle
{
    return
    [DestructiveButtonStyle.alloc initWithString:self];
}

@end

@implementation Alert

#if TARGET_OS_IPHONE
+(void)showWithTitle:(NSString             *)title
             message:(NSString             *)message
             buttons:(NSArray <NSString *> *)buttons
             handler:(AlertButtonHandle     )handler
{
    UIAlertController *controller =
    [UIAlertController
     alertControllerWithTitle:title
     message:message
     preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableArray *array =
    NSMutableArray.new;
    
    if (buttons == nil)
        [array addObject:OK_BUTTON];
    
    else
        [array addObjectsFromArray:buttons];
    
    for (id button in array)
    {
        UIAlertActionStyle style =
        UIAlertActionStyleDefault;
        
        if ([button isKindOfClass:CancelButtonStyle.class])
            style =
            UIAlertActionStyleCancel;
        
        if ([button isKindOfClass:DestructiveButtonStyle.class])
            style =
            UIAlertActionStyleDestructive;
        
        [controller addAction:
         [UIAlertAction
          actionWithTitle:button
          style:style
          handler:^(UIAlertAction *action)
          {
              if (handler)
                  handler([array indexOfObject:button]);
          }]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        UIWindow *window =
        UIWindow.new;
        
        window.backgroundColor =
        UIColor.clearColor;
        
        NSInteger maxZOrder = NSIntegerMin;
        
        for (UIWindow *w in UIApplication.sharedApplication.windows)
            if (w.windowLevel > maxZOrder)
                maxZOrder = w.windowLevel;

        window.windowLevel = maxZOrder + 1;
        
        [window makeKeyAndVisible];
        
        window.rootViewController =
        UIViewController.new;
        
        [window.rootViewController
         presentViewController:controller
         animated:YES
         completion:nil];
    });
}

#else
+(void)showWithTitle:(NSString             *)title
             message:(NSString             *)message
             buttons:(NSArray <NSString *> *)buttons
             handler:(AlertButtonHandle     )handler
{
    NSAlert *alert =
    [NSAlert alertWithError:self];
    
    alert.messageText = title;
    
    if (buttons == nil)
        [alert addButtonWithTitle:OK_BUTTON];
    
    for (AlertButton *button in buttons)
        [alert addButtonWithTitle:button.title];
    
    for (NSButton *button in alert.buttons)
        button.tag =
        [alert.buttons indexOfObject:button];
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        [alert beginSheetModalForWindow:NSApp.mainWindow
                      completionHandler:^(NSModalResponse returnCode)
        {
            if (handler)
                handler([alert.buttons[returnCode] tag]);
        }];
    });
}

#endif

@end
