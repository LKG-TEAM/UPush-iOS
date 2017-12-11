//
//  UPushAppDelegate.h
//  UPush
//
//  Created by 潘涛 on 12/08/2017.
//  Copyright (c) 2017 潘涛. All rights reserved.
//

@import UIKit;
#import <UPush/UPushManager.h>

@interface UPushAppDelegate : UIResponder <UIApplicationDelegate, UPushManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong,nonatomic) UPushManager *sessionManager;
- (void)MQTTSetup;
- (NSString*) getUserId;
- (NSInteger) getUserType;
- (Boolean) getPushState;
- (void) enablePush;
- (void) disablePush;


@end
