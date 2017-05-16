//
//  LDDTexTFieldView.h
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/11.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDDTexTFieldView : UIView

/**用户名输入框*/
@property (weak, nonatomic) IBOutlet UITextField *IDField;
/**密码输入框*/
@property (weak, nonatomic) IBOutlet UITextField *PWDField;
/**记住用户名*/
@property (weak, nonatomic) IBOutlet UIButton *checkBoxBtn;

/**输入框抖动*/
-(void)shakeAnimation:(UITextField*)textField;

-(void)loadUserInfo;


+(instancetype)loadTextFielView;
@end
