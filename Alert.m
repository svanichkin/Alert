//
//  Alert.m
//  v.3.2
//
//  Created by Сергей Ваничкин on 3/12/19.
//  Copyright © 2019 Сергей Ваничкин. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
    [self.stringHolder
     characterAtIndex:index];
}

@end

@implementation CancelButtonStyle

-(instancetype)initWithCharactersNoCopy:(unichar  *)characters
                                 length:(NSUInteger)length
                           freeWhenDone:(BOOL      )freeBuffer
{
    self =
    [super
     initWithCharactersNoCopy:characters
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
    [super
     initWithCharactersNoCopy:characters
     length:length
     freeWhenDone:freeBuffer];

    return self;
}

@end

@implementation NSString (AlertButtonStyle)

-(CancelButtonStyle      *)cancelStyle
{
    return
    [CancelButtonStyle.alloc
     initWithString:self];
}

-(DestructiveButtonStyle *)destructiveStyle
{
    return
    [DestructiveButtonStyle.alloc
     initWithString:self];
}

@end

@interface Alert()

@property (nonatomic, strong) NSTimer                     *timer;
@property (nonatomic, strong) NSMutableArray <UIWindow *> *windows;

@end

@implementation Alert

+(NSString *)localizedButtonTitle:(NSString *)englishTitle;
{
    if (englishTitle == nil)
        return
        nil;
    
    NSString *localizedTitle =
    [[NSBundle bundleForClass:UIApplication.class]
     localizedStringForKey:englishTitle
     value:nil
     table:nil];

    if (localizedTitle == nil ||
        [englishTitle isEqualToString:localizedTitle])
        return
        NSLocalizedString(englishTitle, nil);
    
    return
    localizedTitle;
}

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
    [NSTimer
     scheduledTimerWithTimeInterval:0.5
     repeats:YES
     block:^(NSTimer *timer)
    {
        NSMutableArray <UIWindow *> *dismessed =
        NSMutableArray.new;
        
        // Пробегаем по нашим отображаемым окнам
        for (UIWindow *window in self.windows)
            // Если контроллер был dissmissed добавим в массив
            if (window.rootViewController.presentedViewController == NO)
            {
                window.hidden = YES;
                
                [dismessed
                 addObject:window];
            }
        
        if (dismessed.count)
            [self.windows removeObjectsInArray:dismessed];
        
        if (self.windows.count == 0)
            [self
             stopTimer];
        
        [self
         arrageZOrders];
    }];
}

-(void)arrageZOrders
{
    NSInteger i = 0;
    
    for (UIWindow *window in UIApplication.sharedApplication.windows)
    {
        window.windowLevel = i;
        
        i ++;
    }
}

-(void)stopTimer
{
    [self.timer
     invalidate];
    
    self.timer = nil;
}

+(void)showWindowWithController:(UIViewController *)c
{
    UIViewController __block *controller = c;
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        UIWindow *window;
        
        if (@available(iOS 13.0, *))
        {
            if (UIApplication.sharedApplication.connectedScenes.allObjects.firstObject)
                window =
                [UIWindow.alloc
                 initWithWindowScene:(UIWindowScene *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject];
            
            else
                window =
                UIWindow.new;
        }
        else
            window =
            UIWindow.new;
        
        [Alert.current.windows
         addObject:window];
        
        window.backgroundColor =
        UIColor.clearColor;
        
        NSInteger maxZOrder = NSIntegerMin;
        
        for (UIWindow *w in UIApplication.sharedApplication.windows)
            if (w.windowLevel > maxZOrder)
                maxZOrder = w.windowLevel;
        
        window.windowLevel = maxZOrder + 1;
        
        [Alert.current
         arrageZOrders];
        
        [window
         makeKeyAndVisible];
        
        window.rootViewController =
        UIViewController.new;
        
        controller.modalPresentationStyle =
        UIModalPresentationFullScreen;
        
        if (@available(iOS 13.0, *))
            controller.modalInPresentation = YES;
        
        [window.rootViewController
         presentViewController:controller
         animated:YES
         completion:^
        {
            if (controller.popoverPresentationController)
                [controller.view.superview.superview.superview.subviews[0]
                 addGestureRecognizer:[UITapGestureRecognizer.alloc
                                       initWithTarget:self
                                       action:@selector(tapGestureRecognizer:)]];
            else
                [window
                 addGestureRecognizer:[UITapGestureRecognizer.alloc
                                       initWithTarget:self
                                       action:@selector(tapGestureRecognizer:)]];
        }];
        
        [Alert.current
         startTimer];
    });
}

+(void)tapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    UIWindow *window;
    
    if ([gestureRecognizer.view
         isKindOfClass:UIWindow.class])
        window =
        (UIWindow *)gestureRecognizer.view;
    
    else
        window =
        gestureRecognizer.view.window;

    [window.rootViewController
     dismissViewControllerAnimated:YES
     completion:nil];
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
        [array addObject:@"OK"];
    
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
          actionWithTitle:[self localizedButtonTitle:button]
          style:style
          handler:^(UIAlertAction *action)
        {
            if (handler)
                handler([array indexOfObject:button]);
        }]];
    }
    
    [self
     showWindowWithController:controller];
}

+(NSArray <UITextField *> *)showWithTitle:(NSString              *)title
                                  message:(NSString              *)message
                             placeholders:(NSArray <NSString *>  *)placeholders
                                  buttons:(NSArray <NSString *>  *)buttons
                                  handler:(AlertInputsButtonHandle)handler
{
    UIAlertController *controller =
    [UIAlertController
     alertControllerWithTitle:title
     message:message
     preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableArray *textFields;
    
    if (placeholders.count)
    {
        textFields = NSMutableArray.new;
        
        for (NSString *placeholder in placeholders)
            [controller
             addTextFieldWithConfigurationHandler:^(UITextField *textField)
            {
                [textFields
                 addObject:textField];
                
                textField.placeholder     = placeholder;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            }];
    }
    
    NSMutableArray *array =
    NSMutableArray.new;
    
    if (buttons == nil)
    {
        [array addObject:@"OK"];
        [array addObject:@"Cancel".cancelStyle];
    }
    
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
          actionWithTitle:[self localizedButtonTitle:button]
          style:style
          handler:^(UIAlertAction *action)
          {
            NSMutableArray *results = NSMutableArray.new;
            
            for (UITextField *textField in controller.textFields)
                if (textField.text.length == 0)
                    [results addObject:@""];
                
                else
                    [results addObject:textField.text];
            
            if (handler)
                handler([array indexOfObject:button],
                        results.copy);
        }]];
    }
    
    [self
     showWindowWithController:controller];
    
    return
    textFields.copy;
}

+(void)showWithTitle:(NSString             *)title
   actionSheetSender:(id                    )sender // UIView or UIBarButtonItem or UIButton etc
             message:(NSString             *)message
             buttons:(NSArray <NSString *> *)buttons
             handler:(AlertButtonHandle     )handler
{
    BOOL isIpad =
    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    UIBarButtonItem *barButtonItem;
    UIView          *sourceView;
    
    if ([sender
         isKindOfClass:UIBarButtonItem.class])
        barButtonItem =
        sender;
    
    else if ([sender
              isKindOfClass:UIView.class])
    {
        sourceView =
        sender;
        
        if (sourceView.frame.size.width  * 1.5 > UIScreen.mainScreen.bounds.size.width &&
            sourceView.frame.size.height * 1.5 > UIScreen.mainScreen.bounds.size.height)
            sourceView = nil;
    }
    
    UIAlertController *controller;
    
    if (isIpad && !barButtonItem & !sourceView)
        controller =
        [UIAlertController
         alertControllerWithTitle:title
         message:message
         preferredStyle:UIAlertControllerStyleAlert];

    else
    {
        controller =
        [UIAlertController
         alertControllerWithTitle:title
         message:message
         preferredStyle:UIAlertControllerStyleActionSheet];
        
        controller.popoverPresentationController.barButtonItem =
        barButtonItem;
        
        controller.popoverPresentationController.sourceView =
        sourceView;
    }
    
    NSMutableArray *array =
    NSMutableArray.new;
    
    if (buttons == nil)
        [array addObject:@"OK"];
    
    else
        [array addObjectsFromArray:buttons];
    
    for (id button in array)
    {
        UIAlertActionStyle style =
        UIAlertActionStyleDefault;
        
        if ([button
             isKindOfClass:CancelButtonStyle.class])
            style =
            UIAlertActionStyleCancel;
        
        if ([button
             isKindOfClass:DestructiveButtonStyle.class])
            style =
            UIAlertActionStyleDestructive;
        
        [controller
         addAction:[UIAlertAction
                    actionWithTitle:[self localizedButtonTitle:button]
                    style:style
                    handler:^(UIAlertAction *action)
        {
            if (handler)
                handler([array indexOfObject:button]);
        }]];
    }
    
    [self
     showWindowWithController:controller];
}

+(void)shareItems:(NSArray *)items
           sender:(id       )sender
{
    BOOL isIpad =
    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    UIBarButtonItem *barButtonItem;
    UIView          *sourceView;
    
    if ([sender
         isKindOfClass:UIBarButtonItem.class])
        barButtonItem =
        sender;
    
    else if ([sender
              isKindOfClass:UIView.class])
    {
        sourceView =
        sender;
        
        if (sourceView.frame.size.width  * 1.5 > UIScreen.mainScreen.bounds.size.width &&
            sourceView.frame.size.height * 1.5 > UIScreen.mainScreen.bounds.size.height)
            sourceView = nil;
    }
    
    NSMutableArray *readyItems =
    NSMutableArray.new;
    
    for (int i = 0; i < items.count; i ++)
    {
        id item = items[i];
        
        if ([item
             isKindOfClass:UIImage.class])
        {
            NSString *tempDirectory =
            [NSTemporaryDirectory()
             stringByAppendingPathComponent:[NSString
                                             stringWithFormat:@"image%i.png", i]];
            
            [UIImagePNGRepresentation(item)
             writeToFile:tempDirectory
             atomically:YES];
            
            NSURL *imageURL =
            [NSURL
             fileURLWithPath:tempDirectory];
            
            [readyItems
             addObject:imageURL];
        }
        
        else
            [readyItems
             addObject:item];
    }
    
    UIActivityViewController *controller =
    [UIActivityViewController.alloc
     initWithActivityItems:readyItems.copy
     applicationActivities:nil];
    
    controller.popoverPresentationController.barButtonItem =
    barButtonItem;
    
    controller.popoverPresentationController.sourceView =
    sourceView;
    
    controller.popoverPresentationController.sourceRect =
    sourceView.frame;
    
    [self
     showWindowWithController:controller];
}

@end

static BOOL showErrorDisabled;

@implementation NSError (Alert)

+(void)showErrorDisabled:(BOOL)disabled
{
    showErrorDisabled = disabled;
}

-(void)show
{
    if (showErrorDisabled)
        return;
    
    [self
     showWithTitle:nil
     buttons:nil
     handler:nil];
}

-(void)showWithTitle:(NSString *)title
{
    if (showErrorDisabled)
        return;
    
    [self
     showWithTitle:title
     buttons:nil
     handler:nil];
}

-(void)showWithTitle:(NSString             *)title
             buttons:(NSArray <NSString *> *)buttons
             handler:(AlertButtonHandle     )handler
{
    NSMutableArray <NSString *> *array =
    NSMutableArray.new;
    
    if (buttons == nil)
        [array addObject:@"OK"];
    
    else
        [array addObjectsFromArray:buttons];

    [Alert
     showWithTitle:title
     message:self.localizedDescription
     buttons:array
     handler:handler];
}

@end

