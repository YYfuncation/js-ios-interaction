//
//  NJJSObject.m
//  EnergyTransfer
//
//  Created by Liandi on 2018/12/4.
//  Copyright © 2018年 Liandi. All rights reserved.
//

#import "NJJSObject.h"

@implementation NJJSObject
-(void)BackHome{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当然回调后要处理的逻辑，肯定不能在这个类里处理，这里采用block回调到控制器中处理，其余的三种方式都可以用这种方式处理，这里就不一一列举了
        self.backHome();
    });
}

- (void)PassParameter:(NSString *)title{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当然回调后要处理的逻辑，肯定不能在这个类里处理，这里采用block回调到控制器中处理，其余的三种方式都可以用这种方式处理，这里就不一一列举了
        self.returnTextBlock(title);
    });
    
}
-(void)BackLogin{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backLogin();
    });
}
-(void)BackShopCar{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backShopCar();
    });
}
-(void)BackMineCenter{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backMineCenter();
    });
}
-(void)PassUsername:(NSString *)username AndPassword:(NSString *)password{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"用户名－－%@ 密码－－－%@", username, password);
        self.returnUsernameAndPasswordBlock(username, password);
    });
}
@end
