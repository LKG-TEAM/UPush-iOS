//
//  DetailViewController.h
//  UPush-sample
//
//  Created by 潘涛 on 2017/3/20.
//  Copyright © 2017年 潘涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController<UIWebViewDelegate,NSURLConnectionDelegate>{
    BOOL _authenticated;
    NSURLConnection *_urlConnection;
    NSURLRequest *_request;
}

@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, strong) UIWebView *webView;

- (void)reloadWebView;

@end
