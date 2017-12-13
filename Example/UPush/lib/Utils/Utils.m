//
//  Utils.m
//  UPush-sample
//
//  Created by 潘涛 on 2017/3/23.
//  Copyright © 2017年 潘涛. All rights reserved.
//

#import "Utils.h"
#import "UPushManager.h"

@implementation Utils

/**
 清除缓存
 */
+ (void)cleanCacheAndCookie{
    //清除cookies
    
    NSHTTPCookie *cookie;
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (cookie in [storage cookies]){
        
        [storage deleteCookie:cookie];
    }
    
    //清除UIWebView的缓存
    NSURLCache * cache = [NSURLCache sharedURLCache];
    
    [cache removeAllCachedResponses];
    
    [cache setDiskCapacity:0];
    
    [cache setMemoryCapacity:0];
}

/**
 配置h5地址

 @return h5地址
 */
+ (NSString *)getUrlStrWithUserId:(NSString*)userId userType:(NSInteger)userType
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *h5_HOST = H5_HOST;
    if ([userDefaults objectForKey:@"h5_HOST"]) {
        h5_HOST = [userDefaults objectForKey:@"h5_HOST"];
    }
    
    NSString *h5_PORT = H5_PORT;
    if ([userDefaults objectForKey:@"h5_PORT"]) {
        h5_PORT = [userDefaults objectForKey:@"h5_PORT"];
    }
    
    NSString *apiKey = ApiKey;
    if ([userDefaults objectForKey:@"apiKey"]) {
        apiKey = [userDefaults objectForKey:@"apiKey"];
    }
    
    NSString *apiSecret = ApiSecret;
    if ([userDefaults objectForKey:@"apiSecret"]) {
        apiSecret = [userDefaults objectForKey:@"apiSecret"];
    }
    
//    NSString *userId = [LZUUID uuidForDevice];
//    NSInteger userType = DeviceType;
//    if ([userDefaults objectForKey:@"userId"]) {
//        if ([[userDefaults objectForKey:@"userId"] isEqualToString:@"nil"]) {
//        }else{
//            userId = [userDefaults objectForKey:@"userId"];
//            userType = UserType;
//            if ([userDefaults objectForKey:@"userType"]) {
//                userType = [[userDefaults objectForKey:@"userType"] integerValue];
//            }
//        }
//    }
    
    NSString *appId = [userDefaults objectForKey:@"appId"] ? [userDefaults objectForKey:@"appId"] : AppId;
    NSLog(@" ------------ userId  : %@",userId);
    NSLog(@" ------------ userType: %ld",(long)userType);
    return [NSString stringWithFormat:@"https://%@:%@/?userId=%@&userType=%li&appid=%@&apikey=%@&apisecret=%@",h5_HOST,h5_PORT,userId,(long)userType,appId,apiKey,apiSecret];
}



/**
 发送邮件方式调试
*/
+ (void)sendEmailAction:(NSString *)token
{
    NSMutableString *mailUrl = [[NSMutableString alloc] init];
    
    NSArray *toRecipients = @[@"771764208@qq.com"];
    // 注意：如有多个收件人，可以使用componentsJoinedByString方法连接，连接符为@","
    [mailUrl appendFormat:@"mailto:%@", toRecipients[0]];
    
    NSArray *ccRecipients = @[@"15711611659@qq.com"];
    [mailUrl appendFormat:@"?cc=%@", ccRecipients[0]];
    
    NSArray *bccRecipients = @[@"15711611659@163.com"];
    [mailUrl appendFormat:@"&bcc=%@", bccRecipients[0]];
    
    [mailUrl appendString:[NSString stringWithFormat:@"&subject=%@",token]];
    [mailUrl appendString:@"&body=<b> </b>"];
    
    NSString *emailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailPath]];
}

@end
