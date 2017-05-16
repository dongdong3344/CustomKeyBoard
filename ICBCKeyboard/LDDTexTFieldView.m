//
//  LDDTexTFieldView.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/11.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDTexTFieldView.h"
#import "LDDKeyChain.h"
static const CGFloat kTextFieldH=45.0f;

NSString *const KEY_USERNAME = @"com.omni.key_username";

@interface LDDTexTFieldView ()<UITextFieldDelegate,CAAnimationDelegate>


/**密码是否可见*/
@property (weak, nonatomic) IBOutlet UIButton *visiblePwdBtn;

@end

@implementation LDDTexTFieldView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    //1,设置文本框属性
    
    UIImage *imageUser = [UIImage imageNamed:@"username_icon"];
    UIImageView *imgViewUser = [[UIImageView alloc] initWithImage:imageUser];
    imgViewUser.frame = CGRectMake(0, 0, kTextFieldH, kTextFieldH);
    imgViewUser.contentMode = UIViewContentModeCenter;
    _IDField.leftView = imgViewUser;
    _IDField.leftViewMode = UITextFieldViewModeAlways;
    _IDField.delegate=self;
    
    
    UIImage *imagePwd = [UIImage imageNamed:@"password_icon"];
    UIImageView *imgViewPwd=[[UIImageView alloc] initWithImage:imagePwd];
    imgViewPwd.frame =CGRectMake(0, 0, kTextFieldH, kTextFieldH);
    imgViewPwd.contentMode = UIViewContentModeCenter;
    _PWDField.leftView = imgViewPwd;
    _PWDField.leftViewMode = UITextFieldViewModeAlways;
    _PWDField.delegate=self;
    
    
    //2,checkBox按钮状态
    self.checkBoxBtn.selected=NO;

    
}


//密码明文和暗文的切换
- (IBAction)visiblePwdClick:(UIButton *)button {
    
    button.selected=!button.selected;
    self.PWDField.secureTextEntry=button.selected;
    
}

- (IBAction)checkBoxBtnClick:(UIButton *)button {
    
    button.selected=!button.selected;
    //1,记录checkBox按钮状态并且保存
    if (!self.IDField.text.length) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:button.selected forKey:@"checkBoxStatus"];
        [defaults synchronize];//不要忘记这行代码
    }
    
    //2,保存或删除用户名信息
    if (button.selected&&!self.IDField.text.length) {
        NSMutableDictionary *mutableDict=[NSMutableDictionary dictionary];
        [mutableDict setObject:self.IDField.text forKey:KEY_USERNAME];
        [LDDKeyChain save:KEY_USERNAME data:mutableDict];
    }else{
        [LDDKeyChain delete:KEY_USERNAME];//删除用户名
    }
    
}


-(void)loadUserInfo{
    //判断程序是否是第一次启动
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
        return;//如果是第一次启动，直接return
    }else{
        //1,获取之前checkbox按钮状态
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.checkBoxBtn.selected = [defaults boolForKey:@"checkBoxStatus"];
        
        //2,从keychain中读取用户名信息
        NSMutableDictionary* readDict = (NSMutableDictionary *)[LDDKeyChain load:KEY_USERNAME];
        self.IDField.text=[readDict objectForKey:KEY_USERNAME];
        
    }
}

-(void)shakeAnimation:(UITextField*)textField{
    
    UILabel *placeholderLabel =[textField valueForKeyPath:@"_placeholderLabel"];
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat currentTx = placeholderLabel.transform.tx;
    animation.delegate = self;
    //动画时间
    animation.duration = 0.5;
    animation.values = @[@(currentTx), @(currentTx + 10), @(currentTx-8), @(currentTx + 8), @(currentTx -5), @(currentTx + 5), @(currentTx)];
    //时间段
    animation.keyTimes = @[@(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    //动画出现先快后慢
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //添加动画
    [placeholderLabel.layer addAnimation:animation forKey:nil];
    
}




+(instancetype)loadTextFielView{
    
     return [[[NSBundle mainBundle]loadNibNamed:@"LDDTexTFieldView" owner:nil options:nil]lastObject];
    
}

@end
