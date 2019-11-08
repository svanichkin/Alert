//
//  Alert.h
//  v.2.0
//
//  Created by Сергей Ваничкин on 3/12/19.
//  Copyright © 2019 Сергей Ваничкин. All rights reserved.
//
//  Пример использования
//
//  [Alert
//   showWithTitle:@"Title"
//   message:@"Text"
//   buttons:@[@"Destructive".destructiveStyle],
//             @"OK",
//             @"Cancel".cancelStyle]
//   handler:^(NSInteger buttonIndex)
//   {
//       if (buttonIndex == 0)
//       {
//          // Destructive
//       }
//   }];
//
//  Или сразу для ошибки
//
//  NSError *error = nil;
//
//  ...
//
//  if (error)
//      return
//      [error show];
//
//

#import <Foundation/Foundation.h>
#import "TargetConditionals.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

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

#if TARGET_OS_IPHONE
+(void)showWithTitle:(NSString             *)title
             message:(NSString             *)message
             buttons:(NSArray <NSString *> *)buttons
             handler:(AlertButtonHandle     )handler;
#else
+(void)showWithTitle:(NSString             *)title
             message:(NSString             *)message
             buttons:(NSArray <NSString *> *)buttons
               style:(NSAlertStyle          )style
             handler:(AlertButtonHandle     )handler;
#endif

@end

// NSError+Alert.h

@interface NSError (Alert)

+(void)showErrorDisabled:(BOOL)disabled;

-(void)show;
-(void)showWithTitle:(NSString             *)title;
-(void)showWithTitle:(NSString             *)title
             buttons:(NSArray <NSString *> *)buttons
             handler:(AlertButtonHandle     )handler;

@end
