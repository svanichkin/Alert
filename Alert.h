//
//  Alert.h
//  v.1.6
//
//  Created by Сергей Ваничкин on 3/12/19.
//  Copyright © 2019 Сергей Ваничкин. All rights reserved.
//
//  Пример использования
//
/*
[Alert showWithTitle:@"Title"
             message:@"Text"
             buttons:@[[@"Destructive" destructiveStyle],
                       @"OK",
                       [@"Cancel" cancelStyle]]
             handler:^(NSInteger buttonIndex)
 {
     if (buttonIndex == 0)
     {
     }
 }];
*/

#import <Foundation/Foundation.h>
#import "TargetConditionals.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#define OK_BUTTON @"OK"

@interface DefaultButtonStyle : NSString
@end

@interface CancelButtonStyle : DefaultButtonStyle
@end

@interface DestructiveButtonStyle : DefaultButtonStyle
@end

@interface NSString (AlertButtonStyle)

-(CancelButtonStyle      *)cancelStyle;
-(DestructiveButtonStyle *)destructiveStyle;

@end

typedef void(^AlertButtonHandle)(NSInteger buttonIndex);

@interface Alert : NSObject

+(void)showWithTitle:(NSString             *)title
             message:(NSString             *)message
             buttons:(NSArray <NSString *> *)buttons
             handler:(AlertButtonHandle     )handler;

@end
