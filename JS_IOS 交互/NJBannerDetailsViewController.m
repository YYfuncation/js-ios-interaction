//
//  NJBannerDetailsViewController.m
//  EnergyTransfer
//
//  Created by Liandi on 2018/11/27.
//  Copyright © 2018年 Liandi. All rights reserved.
//

#import "NJBannerDetailsViewController.h"
#import "UIColor+GSColor.h"
#import "Marco.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "NJJSObject.h"
#import "NJHomeViewController.h"
#import "NJLoginManager.h"
#import "TSConst.h"
#import "NJLoginViewController.h"

@interface NJBannerDetailsViewController ()<UIWebViewDelegate>
{
    JSContext *_context;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (assign, nonatomic) BOOL isFinishLoad;
//返回按钮
@property (nonatomic, strong) UIBarButtonItem *backItem;
//关闭按钮
@property (nonatomic, strong) UIBarButtonItem *closeItem;

@end

@implementation NJBannerDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.scalesPageToFit = YES;
    
    NSURL *weburl = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:weburl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
//    self.navigationController.navigationBar.translucent = NO;
    [self addLeftButton];
    
}
- (void)loadProgress:(NSTimer *)timer {
    if (self.isFinishLoad) {
        if (self.progressView.progress >= 1.0) {
            self.progressView.hidden = YES;
            [timer invalidate];
            timer = nil;
        } else {
            self.progressView.progress += 0.1;
        }
    } else {
        self.progressView.progress += 0.0005;
        if (self.progressView.progress >= 0.95) self.progressView.progress = 0.95;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    MLog(@"加载的url:%@", request.URL);
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    MLog(@"开始加载。。。");
    self.progressView.hidden = NO;
    self.progressView.progress = 0;
    self.isFinishLoad = NO;
    [NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(loadProgress:) userInfo:nil repeats:YES];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    MLog(@"加载完成");
    self.isFinishLoad = YES;
    //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
    _context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //第二种情况，js是通过对象调用的，我们假设js里面有一个对象 testobject 在调用方法
    //首先创建我们新建类的对象，将他赋值给js的对象
    NJJSObject *testJO = [NJJSObject new];
    testJO.backHome = ^{
        [self backHome];
    };
    testJO.returnTextBlock = ^(NSString *showText) {
        self.title = showText;
    };
    testJO.backLogin = ^{
        [self backLogin];
    };
    testJO.backShopCar = ^{
        [self backShopCar];
    };
    testJO.backMineCenter = ^{
        [self backMineCenter];
    };
    testJO.returnUsernameAndPasswordBlock = ^(NSString *userName, NSString *passWord) {
        [NJLoginManager loginWithusername:userName password:passWord successHandler:^(id object) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:kLoginSuccess];
            [userDefaults setObject:userName forKey:kUserName];
            [userDefaults setObject:passWord forKey:kPassword];
            [userDefaults synchronize];
            self.navigationController.tabBarController.selectedIndex = 0;
            [self.navigationController popToRootViewControllerAnimated:NO];
        } errorHandler:^(NSString *errorString) {
        }];
    };
    _context[@"testobject"] = testJO;
    
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:kUserName];
    NSString *passWord = [[NSUserDefaults standardUserDefaults] valueForKey:kPassword];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"passUserNameAndPassWord('%@','%@');",name,passWord]];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    MLog(@"加载失败，失败原因：%@", [error localizedDescription]);
    self.progressView.hidden = YES;
}

-(void)backHome{
    self.navigationController.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:NO];
}
-(void)backShopCar{
    self.navigationController.tabBarController.selectedIndex = 3;
    [self.navigationController popToRootViewControllerAnimated:NO];
}
-(void)backMineCenter{
    self.navigationController.tabBarController.selectedIndex = 4;
    [self.navigationController popToRootViewControllerAnimated:NO];
}
-(void)backLogin{
    NJLoginViewController *loginVC = [[NJLoginViewController alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
}
#pragma mark - 添加关闭按钮
- (void)addLeftButton
{
    self.navigationItem.leftBarButtonItem = self.backItem;
}
//点击返回的方法
- (void)backNative
{
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //如果有则返回
        [self.webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.closeItem];
    } else {
        [self closeNative];
    }
}

//关闭H5页面，直接回到原生页面
- (void)closeNative
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - init

- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] init];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //这是一张“<”的图片，可以让美工给切一张
        UIImage *image = [UIImage imageNamed:@"navi_back"];
        [btn setImage:image forState:UIControlStateNormal];
//        [btn setTitle:@"返回" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backNative) forControlEvents:UIControlEventTouchUpInside];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //字体的多少为btn的大小
        [btn sizeToFit];
        //左对齐
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //让返回按钮内容继续向左边偏移15，如果不设置的话，就会发现返回按钮离屏幕的左边的距离有点儿大，不美观
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        btn.frame = CGRectMake(0, 0, 40, 40);
        _backItem.customView = btn;
    }
    return _backItem;
}

- (UIBarButtonItem *)closeItem
{
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeNative)];
        _closeItem.tintColor = [UIColor whiteColor];
    }
    return _closeItem;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
