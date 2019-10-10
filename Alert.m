//
//  Alert.m
//  v.1.8
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

@interface Alert()

@property (nonatomic, strong) NSTimer                     *timer;
@property (nonatomic, strong) NSMutableArray <UIWindow *> *windows;

@end

@implementation Alert

#if TARGET_OS_IPHONE
+(instancetype)current
{
    static Alert *_current = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^
    {
        _current = Alert.new;
    });
    
    return _current;
}

-(instancetype)init
{
    if (self = [super init])
    {
        self.windows =
        NSMutableArray.new;
    }
    
    return self;
}

-(void)startTimer
{
    if (self.timer)
        return;
    
    self.timer =
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                    repeats:YES
                                      block:^(NSTimer *timer)
    {
        NSMutableArray <UIWindow *> *dismessed =
        NSMutableArray.new;
        
        // Пробегаем по нашим отображаемым окнам
        for (UIWindow *window in self.windows)
            // Если контроллер был dissmissed добавим в массив
            if (window.rootViewController.presentedViewController == NO)
                [dismessed addObject:window];
        
        if (dismessed.count)
            [self.windows removeObjectsInArray:dismessed];
        
        if (self.windows.count == 0)
            [self stopTimer];
    }];
}

-(void)stopTimer
{
    [self.timer invalidate];
    
    self.timer = nil;
}

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

        [Alert.current.windows addObject:window];

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

        controller.modalPresentationStyle = UIModalPresentationFullScreen;

        if (@available(iOS 13.0, *))
            controller.modalInPresentation = YES;
        
        [window.rootViewController
         presentViewController:controller
         animated:YES
         completion:nil];

        [Alert.current startTimer];
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
