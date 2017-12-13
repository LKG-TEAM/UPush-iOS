//
//  UPushAppDelegate.m
//  UPush
//
//  Created by 潘涛 on 12/08/2017.
//  Copyright (c) 2017 潘涛. All rights reserved.
//

#import "UPushAppDelegate.h"
#import "ListViewController.h"

@interface UPushAppDelegate ()<UPushManagerDelegate>{
    NSString *_token;
    UIView *_messageV;
}

@property (nonatomic, strong)  ListViewController *listVC;

@end

@implementation UPushAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerToken];
    // mqtt
    //1.创建任务对象
    self.sessionManager = [[UPushManager alloc] init];
    //2.设置代理
    self.sessionManager.delegate = self;
    [self MQTTSetup];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.listVC];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    /** app进程被杀死后，启动app获取推送消息 */
    NSDictionary * userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        self.listVC.msgId = [NSString stringWithFormat:@"%@",[userInfo valueForKey:@"id"]];
    }
    return YES;
}

/**
 配置MQTT
 */
- (void)MQTTSetup{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *host = [userDefaults valueForKey:@"host"] ? [userDefaults valueForKey:@"host"] : HOST;
    NSInteger port = PORT;
    if ([userDefaults objectForKey:@"port"]) {
        port = [[userDefaults objectForKey:@"port"] integerValue];
    }
    
    NSInteger userType = UserType;
    if ([userDefaults objectForKey:@"userType"]) {
        userType = [[userDefaults objectForKey:@"userType"] integerValue];
    }
    
    NSInteger deviceType = DeviceType;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceType"]) {
        deviceType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceType"] integerValue];
    }
    
    NSString *appId = [userDefaults valueForKey:@"appId"] ? [userDefaults valueForKey:@"appId"] : AppId;
    
    NSString *userName = [userDefaults valueForKey:@"userName"] ? [userDefaults valueForKey:@"userName"] : UserName;
    
    NSString *passWord = [userDefaults valueForKey:@"passWord"] ? [userDefaults valueForKey:@"passWord"] : PassWord;
    
    NSInteger publish_qos = Publish_qos;
    if ([userDefaults objectForKey:@"publish_qos"]) {
        publish_qos = [[userDefaults objectForKey:@"publish_qos"] integerValue];
    }
    
    NSInteger subscribe_qos = Subscribe_qos;
    if ([userDefaults objectForKey:@"subscribe_qos"]) {
        subscribe_qos = [[userDefaults objectForKey:@"subscribe_qos"] integerValue];
    }
    
    BOOL clean = NO;
    if ([userDefaults objectForKey:@"clean"] && [[userDefaults objectForKey:@"clean"] isEqualToString:@"YES"]) {
        clean = YES;
    }
    
    BOOL openSSL = YES;
    if ([userDefaults objectForKey:@"openSSL"] && [[userDefaults objectForKey:@"openSSL"] isEqualToString:@"NO"]) {
        openSSL = NO;
    }
    
    NSString *certificate = [userDefaults valueForKey:@"certificate"] ? [userDefaults valueForKey:@"certificate"] :Certificate;
    
    //    3.配置Client对象
    [self.sessionManager configClientHost:host// MQTT服务器地址
                                     port:port// MQTT服务器端口
                                 deviceId: nil
                               deviceType:deviceType
                                    appId:appId// appId
                                 userName:userName// MQTT服务器需验证用户名
                                 passWord:passWord// MQTT服务器需验证密码
                              publish_qos:publish_qos// MQTT推消息型qos
                            subscribe_qos:subscribe_qos// MQTT订阅型qos
                                    clean:clean// 是否清除MQTT缓存
                                  openSSL:openSSL// 是否开启自签名证书SSL,若YES,则下面的certificate需要配置证书名称(自签名证书是der后缀)
                              certificate:certificate];// 自签名证书名称
    
    self.sessionManager.openShock = YES;
    self.sessionManager.soundID = 1312;
    //    [self.sessionManager customSoundWithFileName:@"shake_sound_male" extension:@"wav"];
    
    //    4.启动连接
    NSString *userId = nil;
    if ([userDefaults objectForKey:@"userId"]) {
        if ([[userDefaults objectForKey:@"userId"] isEqualToString:@"nil"]) {
            
        }else{
            userId = [userDefaults objectForKey:@"userId"];
        }
    }
    
    NSInteger _userType=1;
    if ([userDefaults objectForKey:@"userType"]) {
        _userType =[[userDefaults objectForKey:@"userType"] integerValue];
    }
    
    [self.sessionManager connectWithUserId:userId andUserType:_userType];
}

#pragma mark -- UPush回调方法
/**
 UPush连接MQTT状态的回调方法
 
 @param state 状态
 */
- (void)UPushMQTTSessionManagerState:(UPushMQTTSessionManagerState)state{
    
    DSToast *toast = [[DSToast alloc] initWithText:@"连接异常"];
    switch (state) {
            case UPushMQTTSessionManagerStateError:
            [toast showInView:[UIApplication sharedApplication].keyWindow showType:DSToastShowTypeBottom];
            // 异常
            break;
            case UPushMQTTSessionManagerStateConnected:
            toast = [[DSToast alloc] initWithText:@"已连接"];
            [toast showInView:[UIApplication sharedApplication].keyWindow showType:DSToastShowTypeBottom];
            // 已连接
            break;
        default:
            break;
    }
}

- (NSString*) getUserId
{
    return [self.sessionManager getUserId];
}


- (NSInteger) getUserType
{
    return [self.sessionManager getUserType];
}

- (Boolean) getPushState
{
    return [self.sessionManager getPushState];
}

- (void) enablePush
{
    [self.sessionManager enablePush];
}
- (void) disablePush
{
    [self.sessionManager disablePush];
}


/**
 未读数接收方法
 
 @param msgCnt 未读数
 */
- (void)handleUnreadMessageCount:(NSInteger)msgCnt{
    NSLog(@"=========has %li unread messages========", (long)msgCnt);
    self.listVC.unReadCount = msgCnt;
}

/**
 新消息接收方法
 
 @param msg 新消息字典
 @param topic 消息话题字符串
 @param retained 是否在服务器保留
 */
- (void)handleMessage:(NSDictionary *)msg onTopic:(NSString *)topic retained:(BOOL)retained{
    NSLog(@"=========has new message===========%@",msg);
}

- (void)upushBannerViewDidClick:(NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    self.listVC.msgId = [NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]];
}

/**
 上线成功。可做未读数查询、token绑定
 */
- (void)onlineSuccess{
    NSLog(@"---------------------------- onlineSuccess ----------------------------");
    //iOS 10
}

/**
 注册token
 */
- (void)registerToken{
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];// iOS 8以后
    }else{
        //iOS 10 before
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];// iOS 8以后
            [[UIApplication sharedApplication] registerForRemoteNotifications];// iOS 8以后
        }else{
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                UIRemoteNotificationType type = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];// iOS 3 到 iOS 8
            }
        }
    }
    
    [self.sessionManager queryUnreadCount:^(NSError *error) {
        if (!error) {
            NSLog(@"查询未读数成功");
        }else{
            NSLog(@"查询未读数失败");
        }
    }];
}

// iOS 8以后
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

#pragma mark -- token相关 (iOS 3以后)
// 获取token成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    _token = token;
        NSLog(@"My token is:%@", token);
    [self.sessionManager bindTokenToSever:_token publishHandler:^(NSError *error) {
        if (!error) {
        }
    }];
}

// 获取token失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"Failed to get token, error:%@", error_str);
    
    //    [Utils sendEmailAction:error_str];
}


#pragma mark -- 点击推送消息后回调
// iOS 3 到 iOS 10
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *s = [self convertToJSONData: userInfo];
    
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"AlertViewTitle" message:s preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"简书-FlyElephant");
    }];
    [alertController addAction:sureAction];
    
    //在此处理接收到的消息。
    self.listVC.msgId = [NSString stringWithFormat:@"%@",[userInfo valueForKey:@"id"]];
    //    [Utils sendEmailAction:@"iOS 3 到 iOS 10"];
}

// iOS 8 到 iOS 10
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    NSString *s = [self convertToJSONData: userInfo];
    
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"AlertViewTitle" message:s preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"简书-FlyElephant");
    }];
    [alertController addAction:sureAction];
    
    
    self.listVC.msgId = [NSString stringWithFormat:@"%@",[userInfo valueForKey:@"id"]];
    //    [Utils sendEmailAction:@"iOS 8 到 iOS 10"];
}

// iOS 10
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSString *s = [self convertToJSONData: response.notification.request.content.userInfo];
    
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"AlertViewTitle" message:s preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"简书-FlyElephant");
    }];
    [alertController addAction:sureAction];
    
    self.listVC.msgId = [NSString stringWithFormat:@"%@",[response.notification.request.content.userInfo valueForKey:@"id"]];
    //    [Utils sendEmailAction:@"iOS 10"];
}

#pragma mark -- 懒加载
- (ListViewController *)listVC{
    if (!_listVC) {
        _listVC = [[ListViewController alloc] init];
    }
    return _listVC;
}

- (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

@end
