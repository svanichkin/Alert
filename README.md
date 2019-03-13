# Alert
Alert - this is a simple class for displaying an alert from anywhere in your application (iOS and macOS)

Easy to use:
```
[Alert showWithTitle:@"Title"
             message:@"Text"
             buttons:@[@"Destructive".destructiveStyle,
                       @"OK",
                       @"Cancel".cancelStyle]
             handler:^(NSInteger buttonIndex)
{
  if (buttonIndex == 1)
  {
    // OK button pressed
  }
}];
```  

The class itself defines the top controller for display. Enjoy.
