//
//  NJJSObject.h
//  EnergyTransfer
//
//  Created by Liandi on 2018/12/4.
//  Copyright © 2018年 Liandi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
typedef void (^ReturnTextBlock)(NSString *showText);
typedef void (^ReturnUsernameAndPasswordBlock)(NSString *userName ,NSString *passWord);
@protocol JSObjectProtocol <JSExport>
// 回调首页
- (void)BackHome;
// js传参数给oc（标题）
- (void)PassParameter:(NSString *)title;
// 回调登录页面
- (void)BackLogin;
// 回调购物车
- (void)BackShopCar;
// 回调会员中心
- (void)BackMineCenter;
//js传参数给oc (用户名和密码)
- (void)PassUsername:(NSString *)username AndPassword:(NSString *)password;
@end

@interface NJJSObject : NSObject<JSObjectProtocol>

/// 定义block，回调到控制器中；
@property (nonatomic, copy) void(^backHome)(void);
@property (nonatomic, copy) ReturnTextBlock returnTextBlock;
@property (nonatomic, copy) void(^backLogin)(void);
@property (nonatomic, copy) void(^backShopCar)(void);
@property (nonatomic, copy) void(^backMineCenter)(void);
@property (nonatomic, copy) ReturnUsernameAndPasswordBlock returnUsernameAndPasswordBlock;
@end
