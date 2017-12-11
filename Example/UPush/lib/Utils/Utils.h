//
//  Utils.h
//  UPush-sample
//
//  Created by 潘涛 on 2017/3/23.
//  Copyright © 2017年 潘涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

/**
 清除缓存
 */
+ (void)cleanCacheAndCookie;

/**
 配置h5地址
 
 @return h5地址
 */
+ (NSString *)getUrlStrWithUserId:(NSString*)userId userType:(NSInteger)userType;


/**
 发送邮件方式调试
*/
+ (void)sendEmailAction:(NSString *)token;

@end
