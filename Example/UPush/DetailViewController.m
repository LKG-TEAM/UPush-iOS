//
//  DetailViewController.m
//  UPush-sample
//
//  Created by 潘涛 on 2017/3/20.
//  Copyright © 2017年 潘涛. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController (){
    UPushAppDelegate *_appDelegate;
}

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadWebView];
}

- (void)reloadWebView{
    _request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    [self.webView loadRequest:_request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    if([error code] == NSURLErrorCancelled)  {
        return;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = theTitle;
    
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

@end
