# Alert
Alert - this is a simple class for displaying an alert from anywhere in your application (iOS and macOS)

Easy to use:
```
[Alert
 showWithTitle:@"Title"
 message:@"Text"
 buttons:@[@"Delete".destructiveStyle],
           @"OK",
           @"Cancel".cancelStyle]
 handler:^(NSInteger buttonIndex)
 {
     if (buttonIndex == 0)
     {
        // Delete
     }
 }];
```  

All button names indicated in English are automatically translated from the system. Or they are looking for a translation in the application localization files. For example, “Cancel” will be translated automatically, and “MyButtonName” will search for a translation in the application localization file.

For an AppKit application, translation will always be in the application localization file.

The class itself defines the top controller for display. Enjoy.
