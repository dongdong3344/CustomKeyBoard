//
//  LDDKeyboardView.h
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/12.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LDDKeyboardBtnClickBlock)(UIButton*button);


@class LDDKeyboardView;

@protocol LDDKeyboardViewDelegate <NSObject>

-(void)clickKeyboardButton:(UIButton*)button;

@end


@interface LDDKeyboardView : UIView
/**键盘按钮点击block*/
@property(nonatomic,copy) LDDKeyboardBtnClickBlock clickBlock;

/**键盘按钮点击代理*/
@property (nonatomic,weak)  id <LDDKeyboardViewDelegate>delegate;

/**inputAccessoryView*/
@property (weak, nonatomic) IBOutlet UIView *accessoryView;

/**inputView*/
@property (weak, nonatomic) IBOutlet UIView *inputView;

/**字符键盘*/
@property (weak, nonatomic) IBOutlet UIView *charView;

/**当前选中按钮*/
@property(nonatomic,strong) UIButton *selectedBtn;

/**字符键盘左边约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;

-(void)lowercaseCurrentTitle;


/**通过xib方式加载View*/
+(instancetype)loadKeyboardFromNib;



@end
