//
//  UPushManager.h
//  UPush
//
//  Created by 潘涛 on 2017/3/8.
//  Copyright © 2017年 Linkage. All rights reserved.
//
//  UPush 1.0.1  e.g: bindTokenToSever: publishHandler: 支持未启动SDK就可调用


#import <Foundation/Foundation.h>

@protocol UPushManagerDelegate <NSObject>

typedef NS_ENUM(int, UPushMQTTSessionManagerState) {
    UPushMQTTSessionManagerStateStarting,
    UPushMQTTSessionManagerStateConnecting,
    UPushMQTTSessionManagerStateError,
    UPushMQTTSessionManagerStateConnected,
    UPushMQTTSessionManagerStateClosing,
    UPushMQTTSessionManagerStateClosed
};

@optional

typedef void (^MQTTPublishHandler)(NSError *error);

/** 接收到新消息时调用此方法
 @param msg 消息字典对象, 可能为空
 @param topic 推送消息的主题
 @param retained 指示数据是否从服务器存储转发
 */

- (void)handleMessage:(NSDictionary *)msg onTopic:(NSString *)topic retained:(BOOL)retained;



/** 获取未读消息条数
 @param msgCnt 未读消息条数
 */
- (void)handleUnreadMessageCount:(NSInteger)msgCnt;

/**
 上线成功
 */
- (void)onlineSuccess;

/**
 连接状态回调

 @param state 连接状态
 */
- (void)UPushMQTTSessionManagerState:(UPushMQTTSessionManagerState)state;

@end


@interface UPushManager : NSObject


/** 代理对象
 若要接收新消息,以及获取未读消息数,必须设置代理对象
 */
@property (weak, nonatomic) id<UPushManagerDelegate> delegate;

/**
 连接状态
 */
@property (nonatomic, readonly) UPushMQTTSessionManagerState state;

/** 配置Client信息
  host// MQTT服务器地址
  port// MQTT服务器端口
  deviceType// 设备类型
  appId// appId
  userName// MQTT服务器需验证用户名
  passWord// MQTT服务器需验证密码
  publish_qos// MQTT推消息型qos
  subscribe_qos// MQTT订阅型qos
  clean// 是否清除MQTT缓存
  openSSL// 是否开启自签名证书SSL,若YES,则下面的certificate需要配置证书名称(自签名证书是der后缀)
  certificate // 自签名证书名称
 */
- (void)configClientHost:(NSString *)host
                    port:(NSInteger)port
                deviceId:(NSString *)deviceId
              deviceType:(NSInteger)deviceType
                   appId:(NSString *)appId
                userName:(NSString *)username
                passWord:(NSString *)password
             publish_qos:(NSInteger)publish_qos
           subscribe_qos:(NSInteger)subscribe_qos
                   clean:(BOOL)clean
                 openSSL:(BOOL)openSSL
             certificate:(NSString *)certificate;

/** 启动服务器连接
 userId == nil , 以未登录状态连接
 userId != nil , 以登录状态连接
 */
- (void)connectWithUserId:(NSString *)userId andUserType:(NSInteger) userType;


/*  断开连接 */
- (void)disconnect;

/** 发消息
 @param data 消息的data数据
 @param topic 发送主题
 @param retainFlag 若为YES则消息保存在MQTT代理
 */
- (void)sendData:(NSData *)data topic:(NSString *)topic retain:(BOOL)retainFlag publishHandler:(MQTTPublishHandler)publishHandler;

/**
 获取未读数的主动调用方法

 @param publishHandler 向UPush获取未读数的状态block
 */
- (void)queryUnreadCount:(MQTTPublishHandler)publishHandler;

/**
 *  向UPush服务器绑定token
 *  备注：可以未启动SDK就调用该方法
 *
 *  @param token 推送时使用的token
 *  @param publishHandler 向UPush绑定token的状态block
 *
 */
- (void)bindTokenToSever:(NSString *)token publishHandler:(MQTTPublishHandler)publishHandler;

/**
 获取设备类型

 @return 设备类型
 */
- (NSUInteger)getDeviceType;

/**
 获取设备Id

 @return 设备Id
 */
- (NSString *)getDeviceId;


/**
 用于传递到h5消息中心的参数。
 当connectWithUserId没有传入userId时,此方法返回deviceId,否则返回userId。
 @return userId
 */
- (NSString *)getUserId;


/**
 用于传递到h5消息中心的参数。
 当connectWithUserId没有传入userType时,此方法返回deviceType(50),否则返回userType。
 @return userType
 */
- (NSUInteger)getUserType;

/*************************************************铃声提醒、静音震动功能************************************************/

// 默认系统提示音 默认 soundID == -1，即不开启铃声提醒，若要使用系统铃声提醒静音功能，请按下方注释传入相应soundID
/* 注意：
        *若未设置过
                soundID属性
                - (void)customSoundWithFileName:(NSString *)fileName extension:(NSString *)extension方法
                和openShock属性，
                则sdk默认不开启铃声提醒和设备静音震动功能
        *soundID进行了NSUserDefaults缓存，因此在app开发中，若使用到NSUserDefaults缓存策略，请不要使用soundID这个key
        *因为soundID进行了NSUserDefaults缓存，因此不需要每次运行app都需要设置
                soundID属性
                - (void)customSoundWithFileName:(NSString *)fileName extension:(NSString *)extension方法
         但是若需要改变既有铃声需要重新赋值
                soundID属性调用系统铃声，或者
                执行- (void)customSoundWithFileName:(NSString *)fileName extension:(NSString *)extension方法自定义铃声
                若要关闭铃声提醒功能，soundID = -1即可
        *静音震动的openShock默认关闭静音震动，openShock = YES则为开启，同样做了NSUserDefaults缓存策略，请不要使用openShock这个key
        *因为soundID进行了NSUserDefaults缓存，因此不需要每次运行app都需要设置
                但是若需要开启或关闭静音震动需要重新赋值openShock
 */

/*使用系统自带声音，默认的推送三全音 id 是 1312
 注意：系统声音部分会自带震动，比如1312是收到sms时的声音，会有自带震动
                             1305是lock锁屏声音，不会自带震动
 
soundID: is ios system sound id
Sound ID	File name (iPhone)	File name (iPod Touch)	Category	Note
1000	new-mail.caf	new-mail.caf	MailReceived
1001	mail-sent.caf	mail-sent.caf	MailSent
1002	Voicemail.caf	Voicemail.caf	VoicemailReceived
1003	ReceivedMessage.caf	ReceivedMessage.caf	SMSReceived
1004	SentMessage.caf	SentMessage.caf	SMSSent
1005	alarm.caf	sq_alarm.caf	CalendarAlert
1006	low_power.caf	low_power.caf	LowPower
1007	sms-received1.caf	sms-received1.caf	SMSReceived_Alert
1008	sms-received2.caf	sms-received2.caf	SMSReceived_Alert
1009	sms-received3.caf	sms-received3.caf	SMSReceived_Alert
1010	sms-received4.caf	sms-received4.caf	SMSReceived_Alert
1011	-	-	SMSReceived_Vibrate
1012	sms-received1.caf	sms-received1.caf	SMSReceived_Alert
1013	sms-received5.caf	sms-received5.caf	SMSReceived_Alert
1014	sms-received6.caf	sms-received6.caf	SMSReceived_Alert
1015	Voicemail.caf	Voicemail.caf	-	Available since 2.1
1016	tweet_sent.caf	tweet_sent.caf	SMSSent	Available since 5.0
1020	Anticipate.caf	Anticipate.caf	SMSReceived_Alert	Available since 4.2
1021	Bloom.caf	Bloom.caf	SMSReceived_Alert	Available since 4.2
1022	Calypso.caf	Calypso.caf	SMSReceived_Alert	Available since 4.2
1023	Choo_Choo.caf	Choo_Choo.caf	SMSReceived_Alert	Available since 4.2
1024	Descent.caf	Descent.caf	SMSReceived_Alert	Available since 4.2
1025	Fanfare.caf	Fanfare.caf	SMSReceived_Alert	Available since 4.2
1026	Ladder.caf	Ladder.caf	SMSReceived_Alert	Available since 4.2
1027	Minuet.caf	Minuet.caf	SMSReceived_Alert	Available since 4.2
1028	News_Flash.caf	News_Flash.caf	SMSReceived_Alert	Available since 4.2
1029	Noir.caf	Noir.caf	SMSReceived_Alert	Available since 4.2
1030	Sherwood_Forest.caf	Sherwood_Forest.caf	SMSReceived_Alert	Available since 4.2
1031	Spell.caf	Spell.caf	SMSReceived_Alert	Available since 4.2
1032	Suspense.caf	Suspense.caf	SMSReceived_Alert	Available since 4.2
1033	Telegraph.caf	Telegraph.caf	SMSReceived_Alert	Available since 4.2
1034	Tiptoes.caf	Tiptoes.caf	SMSReceived_Alert	Available since 4.2
1035	Typewriters.caf	Typewriters.caf	SMSReceived_Alert	Available since 4.2
1036	Update.caf	Update.caf	SMSReceived_Alert	Available since 4.2
1050	ussd.caf	ussd.caf	USSDAlert
1051	SIMToolkitCallDropped.caf	SIMToolkitCallDropped.caf	SIMToolkitTone
1052	SIMToolkitGeneralBeep.caf	SIMToolkitGeneralBeep.caf	SIMToolkitTone
1053	SIMToolkitNegativeACK.caf	SIMToolkitNegativeACK.caf	SIMToolkitTone
1054	SIMToolkitPositiveACK.caf	SIMToolkitPositiveACK.caf	SIMToolkitTone
1055	SIMToolkitSMS.caf	SIMToolkitSMS.caf	SIMToolkitTone
1057	Tink.caf	Tink.caf	PINKeyPressed
1070	ct-busy.caf	ct-busy.caf	AudioToneBusy	There was no category for this sound before 4.0.
1071	ct-congestion.caf	ct-congestion.caf	AudioToneCongestion	There was no category for this sound before 4.0.
1072	ct-path-ack.caf	ct-path-ack.caf	AudioTonePathAcknowledge	There was no category for this sound before 4.0.
1073	ct-error.caf	ct-error.caf	AudioToneError	There was no category for this sound before 4.0.
1074	ct-call-waiting.caf	ct-call-waiting.caf	AudioToneCallWaiting	There was no category for this sound before 4.0.
1075	ct-keytone2.caf	ct-keytone2.caf	AudioToneKey2	There was no category for this sound before 4.0.
1100	lock.caf	sq_lock.caf	ScreenLocked
1101	unlock.caf	sq_lock.caf	ScreenUnlocked
1102	-	-	FailedUnlock
1103	Tink.caf	sq_tock.caf	KeyPressed
1104	Tock.caf	sq_tock.caf	KeyPressed
1105	Tock.caf	sq_tock.caf	KeyPressed
1106	beep-beep.caf	sq_beep-beep.caf	ConnectedToPower
1107	RingerChanged.caf	RingerChanged.caf	RingerSwitchIndication
1108	photoShutter.caf	photoShutter.caf	CameraShutter
1109	shake.caf	shake.caf	ShakeToShuffle	Available since 3.0
1110	jbl_begin.caf	jbl_begin.caf	JBL_Begin	Available since 3.0
1111	jbl_confirm.caf	jbl_confirm.caf	JBL_Confirm	Available since 3.0
1112	jbl_cancel.caf	jbl_cancel.caf	JBL_Cancel	Available since 3.0
1113	begin_record.caf	begin_record.caf	BeginRecording	Available since 3.0
1114	end_record.caf	end_record.caf	EndRecording	Available since 3.0
1115	jbl_ambiguous.caf	jbl_ambiguous.caf	JBL_Ambiguous	Available since 3.0
1116	jbl_no_match.caf	jbl_no_match.caf	JBL_NoMatch	Available since 3.0
1117	begin_video_record.caf	begin_video_record.caf	BeginVideoRecording	Available since 3.0
1118	end_video_record.caf	end_video_record.caf	EndVideoRecording	Available since 3.0
1150	vc~invitation-accepted.caf	vc~invitation-accepted.caf	VCInvitationAccepted	Available since 4.0
1151	vc~ringing.caf	vc~ringing.caf	VCRinging	Available since 4.0
1152	vc~ended.caf	vc~ended.caf	VCEnded	Available since 4.0
1153	ct-call-waiting.caf	ct-call-waiting.caf	VCCallWaiting	Available since 4.1
1154	vc~ringing.caf	vc~ringing.caf	VCCallUpgrade	Available since 4.1
1200	dtmf-0.caf	dtmf-0.caf	TouchTone
1201	dtmf-1.caf	dtmf-1.caf	TouchTone
1202	dtmf-2.caf	dtmf-2.caf	TouchTone
1203	dtmf-3.caf	dtmf-3.caf	TouchTone
1204	dtmf-4.caf	dtmf-4.caf	TouchTone
1205	dtmf-5.caf	dtmf-5.caf	TouchTone
1206	dtmf-6.caf	dtmf-6.caf	TouchTone
1207	dtmf-7.caf	dtmf-7.caf	TouchTone
1208	dtmf-8.caf	dtmf-8.caf	TouchTone
1209	dtmf-9.caf	dtmf-9.caf	TouchTone
1210	dtmf-star.caf	dtmf-star.caf	TouchTone
1211	dtmf-pound.caf	dtmf-pound.caf	TouchTone
1254	long_low_short_high.caf	long_low_short_high.caf	Headset_StartCall
1255	short_double_high.caf	short_double_high.caf	Headset_Redial
1256	short_low_high.caf	short_low_high.caf	Headset_AnswerCall
1257	short_double_low.caf	short_double_low.caf	Headset_EndCall
1258	short_double_low.caf	short_double_low.caf	Headset_CallWaitingActions
1259	middle_9_short_double_low.caf	middle_9_short_double_low.caf	Headset_TransitionEnd
1300	Voicemail.caf	Voicemail.caf	SystemSoundPreview
1301	ReceivedMessage.caf	ReceivedMessage.caf	SystemSoundPreview
1302	new-mail.caf	new-mail.caf	SystemSoundPreview
1303	mail-sent.caf	mail-sent.caf	SystemSoundPreview
1304	alarm.caf	sq_alarm.caf	SystemSoundPreview
1305	lock.caf	sq_lock.caf	SystemSoundPreview
1306	Tock.caf	sq_tock.caf	KeyPressClickPreview	The category was SystemSoundPreview before 3.2.
1307	sms-received1.caf	sms-received1.caf	SMSReceived_Selection
1308	sms-received2.caf	sms-received2.caf	SMSReceived_Selection
1309	sms-received3.caf	sms-received3.caf	SMSReceived_Selection
1310	sms-received4.caf	sms-received4.caf	SMSReceived_Selection
1311	-	-	SMSReceived_Vibrate
1312	sms-received1.caf	sms-received1.caf	SMSReceived_Selection
1313	sms-received5.caf	sms-received5.caf	SMSReceived_Selection
1314	sms-received6.caf	sms-received6.caf	SMSReceived_Selection
1315	Voicemail.caf	Voicemail.caf	SystemSoundPreview	Available since 2.1
1320	Anticipate.caf	Anticipate.caf	SMSReceived_Selection	Available since 4.2
1321	Bloom.caf	Bloom.caf	SMSReceived_Selection	Available since 4.2
1322	Calypso.caf	Calypso.caf	SMSReceived_Selection	Available since 4.2
1323	Choo_Choo.caf	Choo_Choo.caf	SMSReceived_Selection	Available since 4.2
1324	Descent.caf	Descent.caf	SMSReceived_Selection	Available since 4.2
1325	Fanfare.caf	Fanfare.caf	SMSReceived_Selection	Available since 4.2
1326	Ladder.caf	Ladder.caf	SMSReceived_Selection	Available since 4.2
1327	Minuet.caf	Minuet.caf	SMSReceived_Selection	Available since 4.2
1328	News_Flash.caf	News_Flash.caf	SMSReceived_Selection	Available since 4.2
1329	Noir.caf	Noir.caf	SMSReceived_Selection	Available since 4.2
1330	Sherwood_Forest.caf	Sherwood_Forest.caf	SMSReceived_Selection	Available since 4.2
1331	Spell.caf	Spell.caf	SMSReceived_Selection	Available since 4.2
1332	Suspense.caf	Suspense.caf	SMSReceived_Selection	Available since 4.2
1333	Telegraph.caf	Telegraph.caf	SMSReceived_Selection	Available since 4.2
1334	Tiptoes.caf	Tiptoes.caf	SMSReceived_Selection	Available since 4.2
1335	Typewriters.caf	Typewriters.caf	SMSReceived_Selection	Available since 4.2
1336	Update.caf	Update.caf	SMSReceived_Selection	Available since 4.2
1350	-	-	RingerVibeChanged
1351	-	-	SilentVibeChanged
4095	-	-	Vibrate	There was no category for this sound before 2.2.
In the SDK this is the constant kSystemSoundID_Vibrate.

*/
@property (nonatomic, assign) int soundID;

/**
 自定义铃声

 @param fileName 铃声文件名
 @param extension 铃声文件扩展名
 
 必须是 .caf、.aif 、.wav 、的文件
 声音长度不能超过30秒
 */
- (void)customSoundWithFileName:(NSString *)fileName extension:(NSString *)extension;

/*
 SDK 默认关闭手机静音震动
 NO -- 关闭静音震动
 YES -- 开启静音震动
 */
@property (nonatomic, assign) BOOL openShock;

@end
