//
//  ViewController.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/4.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#define kScreenW   [UIScreen mainScreen].bounds.size.width

#import "ViewController.h"
#import "LDDKeyChain.h"
#import "MBProgressHUD.h"
#import "UIView+Toast.h"
#import "LDDHeadPicture.h"
#import "LDDKeyboardView.h"
#import "LDDHeadView.h"
#import "LDDTextFieldLeftView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CYRKeyboardButton.h"


static const CGFloat kImgFrameH=44.0;
static const CGFloat kImgFrameW=44.0;
NSString *const KEY_USERNAME = @"com.omni.key_username";

typedef NS_ENUM(NSUInteger,LDDButtonType) {
    LDDButtonTypeNumber=100,
    LDDButtonTypeChar,
    LDDButtonTypeSign,
    LDDButtonTypeDelete,
    LDDButtonTypeLogin,
    LDDButtonTypeShift,
    LDDButtonTypeSpace,
};

@interface ViewController ()<UITextFieldDelegate,CAAnimationDelegate,LDDKeyboardViewDelegate>

/**用户名输入框*/
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
/**密码输入框*/
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
/**记住用户名复选框*/
@property (weak, nonatomic) IBOutlet UIButton *checkBoxBtn;
/**登录按钮*/
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
/**密码是否可见按钮*/
@property (weak, nonatomic) IBOutlet UIButton *visiblePwdBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;
@property(nonatomic,strong)LDDHeadView *headView;
@property(nonatomic,strong)LDDKeyboardView *keyboardView;

@end

@implementation ViewController

-(LDDHeadView *)headView{
    if (!_headView) {
        _headView=[LDDHeadView loadHeadView];
        _headView.frame=CGRectMake(0, 0, kScreenW, 200);
    }
    return _headView;
}

-(LDDKeyboardView*)keyboardView{
    if (!_keyboardView) {
        _keyboardView=[LDDKeyboardView loadKeyboardFromNib];
    
        _keyboardView.frame=CGRectMake(0, 0, kScreenW, 260);
        
        //1,第一种方式使用代理
        _keyboardView.delegate=self;
        
        //2,第二种方式使用block
        /**
        
        __weak typeof(self) weakSelf=self;
        _keyboardView.clickBlock = ^(UIButton *button) {
            [weakSelf clickKeyboardButton:button];
        };
         
         */
    }
    return _keyboardView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];

    [self loadUserInfo];
    
}

/**代理方法*/
-(void)clickKeyboardButton:(UIButton*)button{
    
    NSMutableString *str=[NSMutableString stringWithString:self.passwordField.text];

            switch (button.tag) {
                //1，删除按钮
                case LDDButtonTypeDelete:
                    AudioServicesPlaySystemSound(1105);//按键时播放系统声音
                    if ([str isEqualToString:@""])  return;//若密码框为空直接return，
                    NSRange range={str.length-1,1};
                    [str deleteCharactersInRange:range];
                    self.passwordField.text=str;
                    break;
                    
                //2，大小写切换按钮
                case LDDButtonTypeShift:
                    button.selected=!button.selected;
                    AudioServicesPlaySystemSound(1105);//按钮点击声音
                    for (CYRKeyboardButton *charBtn in self.keyboardView.charView.subviews) {
                        
                        if ([charBtn isKindOfClass:[CYRKeyboardButton class]] && button.selected) {
                            [charBtn setTitle:[NSString stringWithFormat:@"%@",[charBtn.currentTitle uppercaseString]] forState:UIControlStateNormal];
                            charBtn.input=charBtn.currentTitle;
                           
                        }else if ([charBtn isKindOfClass:[CYRKeyboardButton class]] &&!button.selected){
                            [charBtn setTitle:[NSString stringWithFormat:@"%@",[charBtn.currentTitle lowercaseString]] forState:UIControlStateNormal];
                            charBtn.input=charBtn.currentTitle;

                        }
                    }
                    
                    break;
                    
                //3，空格按钮
                case LDDButtonTypeSpace:
                    AudioServicesPlaySystemSound(1105);
                    [button addTarget:self action:@selector(backgroundHighlighted:) forControlEvents:UIControlEventTouchDown];
                    self.passwordField.text=[self.passwordField.text stringByAppendingString:@" "];
                    button.backgroundColor=[UIColor whiteColor];
                    break;
                    
                    
                //4，登录按钮
                case LDDButtonTypeLogin:
                   AudioServicesPlaySystemSound(1105);
                   [self loginBtnClick];
                    break;
                    
                //5，其他按钮
                default:
                    AudioServicesPlaySystemSound(1104);
                    self.passwordField.text=[self.passwordField.text stringByAppendingString:button.currentTitle];
                    break;
            }
    
}

//按下空格键，按钮背景变灰色
-(void)backgroundHighlighted:(UIButton*)button{
    
    button.backgroundColor=[UIColor colorWithRed:110/255.0 green:110/255.0 blue:110/255.0 alpha:1];
    
}

//密码明文和暗文的切换
- (IBAction)visiblePwdClick:(UIButton *)button {
    
    button.selected=!button.selected;
    
    self.passwordField.secureTextEntry=!button.selected;

}

- (IBAction)checkBoxBtnClick:(UIButton *)button {
    
    button.selected=!button.selected;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (button.selected&&self.userNameField.text.length) {

        //保存用户名信息
        NSMutableDictionary *mutableDict=[NSMutableDictionary dictionary];
        [mutableDict setObject:self.userNameField.text forKey:KEY_USERNAME];
        [LDDKeyChain save:KEY_USERNAME data:mutableDict];
        
        //记录checkBox按钮状态并且保存
        
        [defaults setBool:YES forKey:@"checkBoxStatus"];
        [defaults synchronize];//不要忘记这行代码
    }else{
        [LDDKeyChain delete:KEY_USERNAME];//删除用户名
        [defaults setBool:NO forKey:@"checkBoxStatus"];
        [defaults synchronize];
    }
    
}

//登录按钮点击事件
- (IBAction)loginBtnClick{
    
    if (!self.userNameField.text.length) {
        [self.userNameField becomeFirstResponder];
        [self shakeAnimation:self.userNameField];
    }else if (self.userNameField.text.length && !self.passwordField.text.length){
        [self.passwordField becomeFirstResponder];
        [self shakeAnimation:self.passwordField];
    }else if ([self.userNameField.text isEqualToString:@"15262352648"] && [self.passwordField.text isEqualToString:@"omni3344"]){
        [self.view endEditing:YES];
        self.actIndicator.hidden=NO;
        [self.actIndicator startAnimating];
        [self.loginBtn setTitle:@"正在载入……" forState:UIControlStateNormal];
        //模拟登录成功
        [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:1.5];
    }else{
        [self.view endEditing:YES];
        [self.actIndicator startAnimating];
        [self.loginBtn setTitle:@"正在载入……" forState:UIControlStateNormal];
        CSToastStyle *style=[[CSToastStyle alloc]initWithDefaultStyle];
        style.messageFont=[UIFont systemFontOfSize:15];
        style.maxWidthPercentage=0.8;
        style.fadeDuration=1.5;
        //模拟登录成败
        [self.view makeToast:@"用户名或密码错误，请认真核实后重新输入。" duration:1.5 position:@"CSToastPositionCenter" style:style];
        
    }
}

-(void)stopAnimation{
    
    [self.actIndicator stopAnimating];
    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];

}

-(void)initUI{
    
    [self.view addSubview:self.headView];
    
    //1,加载首先访问本地沙盒是否存在相关图片
    UIImage *image=[[LDDHeadPicture sharedPicture]imageForKey:@"HeadPicture"];
    if (image) {
        self.headView.iconImgView.image=image;
    }else{
        self.headView.iconImgView.image=[UIImage imageNamed:@"defualtIcon"];
    }
    
    //2,设置按钮状态
    self.checkBoxBtn.selected=NO;
    self.visiblePwdBtn.selected=NO;
    
    //3,设置文本框
    
    CGRect rect=CGRectMake(0, 0, kImgFrameW, kImgFrameH);
    _userNameField.leftView=[LDDTextFieldLeftView textFiledLeftViewWithImageName:@"username_icon" andImageFrame:rect];
    _userNameField.leftViewMode = UITextFieldViewModeAlways;
    _userNameField.delegate=self;
    
    _passwordField.leftView=[LDDTextFieldLeftView textFiledLeftViewWithImageName:@"password_icon" andImageFrame:rect];
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    _passwordField.delegate=self;
    
    //4,设置键盘的inputView和inputAccessoryView
    _passwordField.inputView=self.keyboardView.inputView;
    _passwordField.inputAccessoryView=self.keyboardView.accessoryView;
}

-(void)loadUserInfo{
    //判断程序是否是第一次启动
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
        return;//如果是第一次启动，直接return
    }else{
        //1,获取之前checkBox按钮状态
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.checkBoxBtn.selected = [defaults boolForKey:@"checkBoxStatus"];
        
        //2,从keyChain中读取用户名信息
        NSMutableDictionary* readDict = (NSMutableDictionary *)[LDDKeyChain load:KEY_USERNAME];
        self.userNameField.text=[readDict objectForKey:KEY_USERNAME];
        
    }
}

//PlaceholderLabel左右晃动动画效果
-(void)shakeAnimation:(UITextField*)textField{
    
    //获取placeholderLabel
    UILabel *placeholderLabel=[textField valueForKeyPath:@"_placeholderLabel"];
    //创建动画
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat currentTx = placeholderLabel.transform.tx;
    //设置代理
    animation.delegate = self;
    //动画时间
    animation.duration = 0.5;
    animation.values = @[@(currentTx), @(currentTx + 10), @(currentTx-8), @(currentTx + 8), @(currentTx -5), @(currentTx + 5), @(currentTx)];
    //时间段
    animation.keyTimes = @[@(0), @(0.2), @(0.4), @(0.6), @(0.8), @(0.875), @(1) ];
    //动画出现先快后慢
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //添加动画
    [placeholderLabel.layer addAnimation:animation forKey:nil];
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (textField==self.userNameField) [self defaultToCharKey];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (range.length == 1 && string.length == 0) {
        return YES; //此句话十分重要，否则输满字符后不能回退删除
    }
    if (textField==self.userNameField ) return textField.text.length<22;//用户名限制在22个字符
    
    //防止明暗文切换导致字符数限制失效
    if (textField == self.passwordField && textField.isSecureTextEntry){
        NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = toBeString;
        return NO;
    }
    return YES;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
    [self defaultToCharKey];

}

//Pwd textField重新成为响应者时，键盘类型默认是char
-(void)defaultToCharKey{
    
    [self.keyboardView lowercaseString];

    self.keyboardView.leftConstraint.constant=0;
   
    UIButton *charTypeBtn=(UIButton*)[self.keyboardView.accessoryView viewWithTag:LDDButtonTypeChar];
    charTypeBtn.selected=YES;
    if (self.keyboardView.selectedBtn!=charTypeBtn) {
        self.keyboardView.selectedBtn.selected=NO;
        self.keyboardView.selectedBtn.userInteractionEnabled=YES;
        self.keyboardView.selectedBtn=charTypeBtn;

    }
    
}


@end
