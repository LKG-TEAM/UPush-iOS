//
//  ViewController.m
//  UPush-sample
//
//  Created by 潘涛 on 2017/3/20.
//  Copyright © 2017年 潘涛. All rights reserved.
//

#import "ListViewController.h"
#import "DetailViewController.h"
#import "SettingViewController.h"
#import "UPushAppDelegate.h"
#import "GPRS.h"

@interface ListViewController (){
    BOOL _isLoaded;
    NSString *_hash;
    UPushAppDelegate *_appDelegate;
    BOOL _canBack;
}

@property (nonatomic, strong) UILabel *upLoad;

@property (nonatomic, strong) UILabel *downLoad;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(setup)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"未读数:%li",(long)self.unReadCount] style:UIBarButtonItemStylePlain target:self action:@selector(click)];
    
    [Utils cleanCacheAndCookie];
    [self requestWebView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewHistoryDidChange)
                                                 name:@"WebHistoryItemChangedNotification"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)webViewHistoryDidChange
{
    [self performSelector:@selector(getHash) withObject:self ];
    
}

- (void)gprs{
    NSArray *gprs = [GPRS getDataCounters];
    self.upLoad.text = [NSString stringWithFormat:@"%@",gprs[0]];
    self.downLoad.text = [NSString stringWithFormat:@"%@",gprs[1]];
}

- (void)setMsgId:(NSString *)msgId{
    _msgId = msgId;
    if (_hash.length > 0) {// 说明不是在首页
        [self requestWebView];
    }
    
    _appDelegate  = (UPushAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    DSToast *toast = [[DSToast alloc] initWithText:[NSString stringWithFormat:@"userId:%@, userType:%lu",[[_appDelegate sessionManager] getUserId], (unsigned long)[[_appDelegate sessionManager] getUserType]]];
    [toast showInView:[UIApplication sharedApplication].keyWindow showType:DSToastShowTypeBottom];
    
    if (self.navigationController.childViewControllers.count == 1) {
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        
        //
        //       NSString *u =  [[_appDelegate sessionManager] getUserId];
        //
        //        //初始化AlertView
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AlertViewTest"
        //                                                        message:@"message"
        //                                                       delegate:self
        //                                              cancelButtonTitle:@"c1"
        //                                              otherButtonTitles:@"o1",nil];
        //        //设置标题与信息，通常在使用frame初始化AlertView时使用
        //        alert.title = @"userID";
        //        alert.message = u;
        //        [alert show];
        //
        //
        //        NSInteger t = [[_appDelegate sessionManager] getUserType];
        //        //初始化AlertView
        //        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"AlertViewTest"
        //                                                        message:@"message"
        //                                                       delegate:self
        //                                              cancelButtonTitle:@"c2"
        //                                              otherButtonTitles:@"o2",nil];
        //        //设置标题与信息，通常在使用frame初始化AlertView时使用
        //        alert1.title = @"userType";
        //        alert1.message = [NSString stringWithFormat:@"%li", t];
        //        [alert1 show];
        
        
        detailVC.urlStr = [[Utils  getUrlStrWithUserId:[[_appDelegate sessionManager] getUserId] userType:[[_appDelegate sessionManager] getUserType]] stringByAppendingString:[NSString stringWithFormat:@"&msgId=%@",msgId]];
        
        
        //        //初始化AlertView
        //        UIAlertView *alert3 = [[UIAlertView alloc] initWithTitle:@"AlertViewTest"
        //                                                         message:@"message"
        //                                                        delegate:self
        //                                               cancelButtonTitle:@"c3"
        //                                               otherButtonTitles:@"o3",nil];
        //        //设置标题与信息，通常在使用frame初始化AlertView时使用
        //        alert3.title = @"URL";
        //        alert3.message = detailVC.urlStr;
        //        [alert3 show];
        
        [self.navigationController pushViewController:detailVC animated:YES];
    }else if (self.navigationController.childViewControllers.count == 2){
        
        
        
        DetailViewController *detailVC = (DetailViewController *)self.navigationController.childViewControllers[1];
        
        //        NSString *u =  [[_appDelegate sessionManager] getUserId];
        //
        //        //初始化AlertView
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AlertViewTest"
        //                                                        message:@"message"
        //                                                       delegate:self
        //                                              cancelButtonTitle:@"c1"
        //                                              otherButtonTitles:@"o1",nil];
        //        //设置标题与信息，通常在使用frame初始化AlertView时使用
        //        alert.title = @"userID";
        //        alert.message = u;
        //        [alert show];
        //
        //
        //        NSInteger t = [[_appDelegate sessionManager] getUserType];
        //        //初始化AlertView
        //        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"AlertViewTest"
        //                                                         message:@"message"
        //                                                        delegate:self
        //                                               cancelButtonTitle:@"c2"
        //                                               otherButtonTitles:@"o2",nil];
        //        //设置标题与信息，通常在使用frame初始化AlertView时使用
        //        alert1.title = @"userType";
        //        alert1.message = [NSString stringWithFormat:@"%li", t];
        //        [alert1 show];
        
        //        detailVC.urlStr = [[Utils  getUrlStrWithUserId:[_appDelegate getUserId] userType:[_appDelegate getUserType]] stringByAppendingString:[NSString stringWithFormat:@"&msgId=%@",msgId]];
        
        
        
        detailVC.urlStr = [[Utils  getUrlStrWithUserId:[[_appDelegate sessionManager] getUserId] userType:[[_appDelegate sessionManager] getUserType]] stringByAppendingString:[NSString stringWithFormat:@"&msgId=%@",msgId]];
        
        
        //        //初始化AlertView
        //        UIAlertView *alert3 = [[UIAlertView alloc] initWithTitle:@"AlertViewTest"
        //                                                         message:@"message"
        //                                                        delegate:self
        //                                               cancelButtonTitle:@"c3"
        //                                               otherButtonTitles:@"o3",nil];
        //        //设置标题与信息，通常在使用frame初始化AlertView时使用
        //        alert3.title = @"URL";
        //        alert3.message = detailVC.urlStr;
        //        [alert3 show];
        
        [detailVC reloadWebView];
    }
    NSLog(@"[[_appDelegate sessionManager] getUserId]:   %@",[[_appDelegate sessionManager] getUserId]);
    NSLog(@"[[_appDelegate sessionManager] getUserType]: %lu",(unsigned long)[[_appDelegate sessionManager] getUserType]);
}


- (void)requestWebView{
    _appDelegate = (UPushAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *_userId = [_appDelegate getUserId];
    NSInteger _userType = [_appDelegate getUserType];
    
    NSString *urlStr = [Utils getUrlStrWithUserId:_userId userType:_userType];
    _request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:_request];
}


- (void)setUnReadCount:(NSInteger)unReadCount{
    _unReadCount = unReadCount;
    self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"未读数:%li",(long)unReadCount];
}

- (void)click{
    UPushAppDelegate *appDelegate = (UPushAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.sessionManager queryUnreadCount:^(NSError *error) {
        if (!error) {
            NSLog(@"查询未读数成功");
        }else{
            NSLog(@"查询未读数失败");
        }
    }];
    
    [self requestWebView];
    return;
}

- (void)setup{
    [self.navigationController pushViewController:[SettingViewController new] animated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webview start!");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_hash.length > 0) {
        _canBack = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if([error code] == NSURLErrorCancelled)  {
        if (_hash.length > 0) {
            _canBack = YES;
        }
        return;
    }
}


- (void)back{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)getHash{
    NSString *hashStr=[self.webView stringByEvaluatingJavaScriptFromString:@"document.location.hash"];
    //    NSLog(@" hash: %@",hashStr);
    _hash = hashStr;
    
    NSString *theTitle=[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = theTitle;
    
    if (hashStr.length > 0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(setup)];
        _appDelegate = (UPushAppDelegate *)[[UIApplication sharedApplication] delegate];
        [_appDelegate.sessionManager queryUnreadCount:^(NSError *error) {
            if (!error) {
                NSLog(@"查询未读数成功");
            }else{
                NSLog(@"查询未读数失败");
            }
        }];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    
    //    NSLog(@"%@", [request URL]);
    //
    //    // 延时500ms去取url hash。在iOS之上，url不会立即更新，而是在一个事件loop之后才更新，因此延时去取hash
    //    [self performSelector:@selector(getHash) withObject:self afterDelay:0.5];
    
    
    if (!_authenticated) {
        
        _authenticated = NO;
        
        _urlConnection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
        
        [_urlConnection start];
        
        return NO;
    }
    return YES;
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    if ([challenge previousFailureCount] == 0)
    {
        _authenticated = YES;
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        
    } else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    // remake a webview call now that authentication has passed ok.
    _authenticated = YES;
    [self.webView loadRequest:_request];
    // Cancel the URL connection otherwise we double up (webview + url connection, same url = no good!)
    [_urlConnection cancel];
}

#pragma mark -- 懒加载
- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_webView];
        _webView.delegate = self;
    }
    return _webView;
}

- (UILabel *)upLoad{
    if (!_upLoad) {
        _upLoad = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 40, 100, 30)];
        _upLoad.textColor = [UIColor whiteColor];
        _upLoad.font = [UIFont systemFontOfSize:14];
        _upLoad.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
        [self.view addSubview:_upLoad];
    }
    return _upLoad;
}

- (UILabel *)downLoad{
    if (!_downLoad) {
        _downLoad = [[UILabel alloc] initWithFrame:CGRectMake(150, self.view.frame.size.height - 40, 100, 30)];
        _downLoad.textColor = [UIColor whiteColor];
        _downLoad.font = [UIFont systemFontOfSize:14];
        _downLoad.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
        [self.view addSubview:_downLoad];
    }
    return _downLoad;
}


@end

