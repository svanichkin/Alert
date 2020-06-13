//
//  Alert.h
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

+(void)showWithTitle:(NSString             *)title
   actionSheetSender:(id                    )sender // UIView or UIBarButtonItem or UIButton etc
             message:(NSString             *)message
             buttons:(NSArray <NSString *> *)buttons
             handler:(AlertButtonHandle     )handler;

+(void)shareItems:(NSArray *)items
           sender:(id       )sender;

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
