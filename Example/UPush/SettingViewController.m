//
//  SettingViewController.m
//  UPush-sample
//
//  Created by 潘涛 on 2017/3/21.
//  Copyright © 2017年 潘涛. All rights reserved.
//

#import "SettingViewController.h"
#import "XLForm.h"
#import "UPushAppDelegate.h"

NSString *const kIP = @"HOST";
NSString *const kPort = @"PORT";
NSString *const kUserName = @"UserName";
NSString *const kPassword = @"PassWord";
NSString *const kAppId = @"AppId";
NSString *const kCleanBool = @"CleanBool";
NSString *const kUsePush = @"UsePushBool";
NSString *const kSSLBool = @"SSLBool";
NSString *const kCertificate = @"Certificate";

NSString *const kUserId = @"UserId";
NSString *const kUserType = @"UserType";
NSString *const kPublish_qos = @"发布qos";
NSString *const kSubscribe_qos = @"订阅qos";

NSString *const kH5_IP = @"H5_HOST";
NSString *const kH5_PORT = @"H5_PORT";
NSString *const kApiKey = @"ApiKey";
NSString *const kApiSecret = @"ApiSecret";
NSString *const kDeviceType = @"DeviceType";

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)init{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"设置"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = NO;
    
    /*******************************************基础配置***********************************************/
    
    NSString *host = [userDefaults valueForKey:@"host"] ? [userDefaults valueForKey:@"host"] : HOST;
    NSInteger port = PORT;
    if ([userDefaults objectForKey:@"port"]) {
        port = [[userDefaults objectForKey:@"port"] integerValue];
    }
    
    
    BOOL clean = NO;
    if ([userDefaults objectForKey:@"clean"] && [[userDefaults objectForKey:@"clean"] isEqualToString:@"YES"]) {
        clean = YES;
    }
    
    //是否使用推送
    BOOL usePush = [(UPushAppDelegate*)[UIApplication sharedApplication].delegate getPushState];
    
    
    BOOL openSSL = YES;
    if ([userDefaults objectForKey:@"openSSL"] && [[userDefaults objectForKey:@"openSSL"] isEqualToString:@"NO"]) {
        openSSL = NO;
    }
    NSString *appId = [userDefaults valueForKey:@"appId"] ? [userDefaults valueForKey:@"appId"] : AppId;
    
    NSString *userName = [userDefaults valueForKey:@"userName"] ? [userDefaults valueForKey:@"userName"] : UserName;
    
    NSString *passWord = [userDefaults valueForKey:@"passWord"] ? [userDefaults valueForKey:@"passWord"] : PassWord;
    
    NSString *certificate = [userDefaults valueForKey:@"certificate"] ? [userDefaults valueForKey:@"certificate"] :Certificate;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"基础配置"];
    //    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kIP rowType:XLFormRowDescriptorTypeText title:@"IP:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",host];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPort rowType:XLFormRowDescriptorTypeInteger title:@"端口:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%li",(long)port];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUserName rowType:XLFormRowDescriptorTypeText title:@"用户名:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",userName];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPassword rowType:XLFormRowDescriptorTypeText title:@"密码:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",passWord];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAppId rowType:XLFormRowDescriptorTypeText title:@"AppId:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",appId];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUsePush rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"使用推送:"];
    [row.cellConfigAtConfigure setObject:[UIColor greenColor] forKey:@"switchControl.onTintColor"];
    row.value = @(usePush);
    [section addFormRow:row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCleanBool rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Clean:"];
    [row.cellConfigAtConfigure setObject:[UIColor greenColor] forKey:@"switchControl.onTintColor"];
    row.value = @(clean);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSSLBool rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"SSL:"];
    row.value = @(openSSL);
    [row.cellConfigAtConfigure setObject:[UIColor greenColor] forKey:@"switchControl.onTintColor"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCertificate rowType:XLFormRowDescriptorTypeText title:@"证书:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",certificate];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    /*******************************************业务配置***********************************************/
    NSString *userId = @"";
    if ([userDefaults objectForKey:@"userId"]) {
        if ([[userDefaults objectForKey:@"userId"] isEqualToString:@"nil"]) {
        }else{
            userId = [userDefaults objectForKey:@"userId"];
        }
    }
    NSInteger userType = UserType;
    if ([userDefaults objectForKey:@"userType"]) {
        userType = [[userDefaults objectForKey:@"userType"] integerValue];
    }
    
    NSInteger publish_qos = Publish_qos;
    if ([userDefaults objectForKey:@"publish_qos"]) {
        publish_qos = [[userDefaults objectForKey:@"publish_qos"] integerValue];
    }
    
    NSInteger subscribe_qos = Subscribe_qos;
    if ([userDefaults objectForKey:@"subscribe_qos"]) {
        subscribe_qos = [[userDefaults objectForKey:@"subscribe_qos"] integerValue];
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"业务配置"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUserId rowType:XLFormRowDescriptorTypeInteger title:@"UserId:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",userId];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUserType rowType:XLFormRowDescriptorTypeInteger title:@"UserType:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%li",(long)userType];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPublish_qos rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"发布qos:"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"0"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"1"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"2"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(publish_qos) displayText:[NSString stringWithFormat:@"%ld",(long)publish_qos]];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSubscribe_qos rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"订阅qos:"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"0"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"1"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"2"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(subscribe_qos) displayText:[NSString stringWithFormat:@"%ld",(long)subscribe_qos]];
    [section addFormRow:row];
    
    /*******************************************html配置***********************************************/
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
    
    NSInteger deviceType = DeviceType;
    if ([userDefaults objectForKey:@"deviceType"]) {
        deviceType = [[userDefaults objectForKey:@"deviceType"] integerValue];
    }
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"H5配置"];
    [formDescriptor addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kH5_IP rowType:XLFormRowDescriptorTypeText title:@"H5-IP:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",h5_HOST];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kH5_PORT rowType:XLFormRowDescriptorTypeInteger title:@"H5-端口:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",h5_PORT];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApiKey rowType:XLFormRowDescriptorTypeText title:@"ApiKey:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",apiKey];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApiSecret rowType:XLFormRowDescriptorTypeText title:@"ApiSecret:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%@",apiSecret];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDeviceType rowType:XLFormRowDescriptorTypeInteger title:@"DeviceType:"];
    row.required = YES;
    row.value = [NSString stringWithFormat:@"%li",(long)deviceType];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (!formRow || !newValue || [newValue isEqual:[NSNull class]] || [newValue isEqual:NULL] || [newValue isEqual:[NSNull null]]) {
        return;
    }
    /*******************************************基础配置***********************************************/
    if ([formRow.tag isEqualToString:kIP]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"host"];
    }
    
    if ([formRow.tag isEqualToString:kPort]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"port"];
    }
    
    if ([formRow.tag isEqualToString:kUserName]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"userName"];
    }
    
    if ([formRow.tag isEqualToString:kPassword]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"passWord"];
    }
    
    if ([formRow.tag isEqualToString:kAppId]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"appId"];
    }
    
    if ([formRow.tag isEqualToString:kUsePush]) {
        if ([newValue isEqual: @(1)]) {
            [(UPushAppDelegate*)[UIApplication sharedApplication].delegate enablePush];
        }else{
            [(UPushAppDelegate*)[UIApplication sharedApplication].delegate disablePush];
        }
    }
    
    if ([formRow.tag isEqualToString:kCleanBool]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",[newValue isEqual: @(1)]?@"YES":@"NO"] forKey:@"clean"];
    }
    
    if ([formRow.tag isEqualToString:kSSLBool]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",[newValue isEqual: @(1)]?@"YES":@"NO"] forKey:@"openSSL"];
    }
    
    if ([formRow.tag isEqualToString:kCertificate]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"certificate"];
    }
    /*******************************************业务配置***********************************************/
    if ([formRow.tag isEqualToString:kUserId]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"userId"];
    }
    
    if ([formRow.tag isEqualToString:kUserType]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"userType"];
    }
    
    if ([formRow.tag isEqualToString:kPublish_qos]) {
        XLFormOptionsObject *formOptionsObject = (XLFormOptionsObject *)newValue;
        [userDefaults setValue:[NSString stringWithFormat:@"%@",formOptionsObject.displayText] forKey:@"publish_qos"];
    }
    
    if ([formRow.tag isEqualToString:kSubscribe_qos]) {
        XLFormOptionsObject *formOptionsObject = (XLFormOptionsObject *)newValue;
        [userDefaults setValue:[NSString stringWithFormat:@"%@",formOptionsObject.displayText] forKey:@"subscribe_qos"];
    }
    /*******************************************html配置***********************************************/
    if ([formRow.tag isEqualToString:kH5_IP]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"h5_HOST"];
    }
    
    if ([formRow.tag isEqualToString:kH5_PORT]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"h5_PORT"];
    }
    
    if ([formRow.tag isEqualToString:kApiKey]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"apiKey"];
    }
    
    if ([formRow.tag isEqualToString:kApiSecret]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"apiSecret"];
    }
    
    if ([formRow.tag isEqualToString:kDeviceType]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",newValue] forKey:@"deviceType"];
    }
    /*******************************************其他设置***********************************************/
    
}

- (void)connect{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *formValues = self.form.formValues;
    if ([[NSString stringWithFormat:@"%@",[formValues valueForKey:@"UserId"]] isEqualToString:@"<null>"]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",@"nil"] forKey:@"userId"];
    }
    if ([[NSString stringWithFormat:@"%@",[formValues valueForKey:@"DeviceType"]] isEqualToString:@"<null>"]) {
        [userDefaults setValue:[NSString stringWithFormat:@"%@",@"50"] forKey:@"DeviceType"];
    }
    UPushAppDelegate *appDelegate = (UPushAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate MQTTSetup];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(connect)];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    UPushAppDelegate *appDelegate = (UPushAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@" -- %d",appDelegate.sessionManager.state);
    if (appDelegate.sessionManager.state == UPushMQTTSessionManagerStateConnected) {
        NSLog(@"已连接");
        return;
    }
    
    //    [appDelegate MQTTSetup];
}

@end
