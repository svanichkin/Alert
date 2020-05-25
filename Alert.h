//
//  Alert.h
//  v.3.0
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

#import <UIKit/UIKit.h>

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
typedef void(^AlertInputsButtonHandle)(NSInteger             buttonIndex,
                                       NSArray <NSString *> *inputResults);

@interface Alert : NSObject

+(void)showWithTitle:(NSString             *)title
             message:(NSString             *)message
             buttons:(NSArray <NSString *> *)buttons
             handler:(AlertButtonHandle     )handler;

+(NSArray <UITextField *> *)showWithTitle:(NSString              *)title
                                  message:(NSString              *)message
                             placeholders:(NSArray <NSString *>  *)placeholders
                                  buttons:(NSArray <NSString *>  *)buttons
                                  handler:(AlertInputsButtonHandle)handler;

@end
