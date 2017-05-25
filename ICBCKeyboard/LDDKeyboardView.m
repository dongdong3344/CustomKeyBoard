//
//  LDDKeyboardView.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/12.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDKeyboardView.h"
#import "CYRKeyboardButton.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width

typedef NS_ENUM(NSUInteger,LDDButtonType) {
    LDDButtonTypeNumber=100,  //数字键盘类型按钮
    LDDButtonTypeChar,        //字符键盘类型按钮
    LDDButtonTypeSign,        //符合键盘类型按钮
    LDDButtonTypeDelete,      //删除按钮
    LDDButtonTypeLogin,       //登录按钮
    LDDButtonTypeShift,       //大小写切换按钮
    LDDButtonTypeSpace,       //空格按钮
};

@interface LDDKeyboardView ()
/**字母键盘*/
@property (weak, nonatomic) IBOutlet UIView *signView;
/**数字键盘*/
@property (weak, nonatomic) IBOutlet UIView *numberView;

@end


@implementation LDDKeyboardView

-(void)awakeFromNib{
    
    [super awakeFromNib];
    
    //1,设置按钮状态
    UIButton *charTypeBtn=(UIButton*)[self.accessoryView viewWithTag:LDDButtonTypeChar];
    charTypeBtn.selected=YES;
    charTypeBtn.userInteractionEnabled=NO;
    self.selectedBtn=charTypeBtn;
    
    //2,数字键盘随机数
    [self generateRandomNumber];
    
     UIButton *shiftBtn=(UIButton*)[self.charView viewWithTag:LDDButtonTypeShift];
     shiftBtn.selected=NO;
    
    //3,键盘类型按钮添加点击事件
    [self.accessoryView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *typeBtn=(UIButton*)obj;
        [typeBtn addTarget:self action:@selector(keyTypeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    
    //4,设置各个类型键盘上的按钮点击
    
    for (UIView *subView in self.inputView.subviews) {
        [self setupButtonClickWithView:subView];
    }
    
}


//键盘类型按钮点击事件
-(void)keyTypeButtonClick:(UIButton*)button{
    
    //1,更改按钮状态
    button.selected=YES;
    button.userInteractionEnabled=NO;
    self.selectedBtn.selected=NO;
    self.selectedBtn.userInteractionEnabled=YES;
    self.selectedBtn=button;
    
    //2,设置点击事件方法
    switch (button.tag) {
        case LDDButtonTypeChar:
            self.leftConstraint.constant=0;//改变char键盘距离父视图左边的约束条件
            [self generateRandomNumber];//点击数字按钮时更新键盘数字
            break;
            
        case LDDButtonTypeNumber:
            self.leftConstraint.constant=kScreenW;
            [self lowercaseCurrentTitle];
            break;
            
        case LDDButtonTypeSign:
            [self generateRandomNumber];
            self.leftConstraint.constant=-kScreenW;
            [self lowercaseCurrentTitle];
            break;
    }
}

//设置各个键盘View上的按钮点击方法
-(void)setupButtonClickWithView:(UIView*)view{
    
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //按钮类型是CYRKeyboardButton，则点击按钮时有extension
        if ([obj isKindOfClass:[CYRKeyboardButton class]]) {
            CYRKeyboardButton *cyrButton=(CYRKeyboardButton*)obj;
            cyrButton.input=cyrButton.currentTitle;
            //cyrButton.inputOptions=@[@"A",@"B",@"C",@"D"];
            [cyrButton addTarget:self action:@selector(keyboardBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            //按钮类型是UIButton，直接执行点击方法
        }else if ([obj isKindOfClass:[UIButton class]]){
            UIButton *button=(UIButton*)obj;
            [button addTarget:self action:@selector(keyboardBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
    }];
    
}

//键盘按钮点击事件
-(void)keyboardBtnClick:(UIButton*)button{
    //1,使用代理
    if ([self.delegate respondsToSelector:@selector(clickKeyboardButton:)]) {
        [self.delegate clickKeyboardButton:button];
    }
    
    //2,使用Block
//    if (self.clickBlock) {
//        self.clickBlock(button);
//    }
    
}

-(void)lowercaseCurrentTitle{
    
    UIButton *shiftBtn=(UIButton*)[self.charView viewWithTag:LDDButtonTypeShift];
    //如果shiftBtn是选中状态，则将所有大写字母->小写字母，并将shift按钮状态置为未选中
    if (shiftBtn.selected) {
        for (CYRKeyboardButton *charBtn in self.charView.subviews) {
            if ([charBtn isKindOfClass:[CYRKeyboardButton class]] ) {
                [charBtn setTitle:[NSString stringWithFormat:@"%@",[charBtn.currentTitle lowercaseString]] forState:UIControlStateNormal];
                charBtn.input=charBtn.currentTitle;
                shiftBtn.selected=NO;
                
            }
        }
    }
    
}

//数字键盘产生随机数
-(void)generateRandomNumber{
    
    NSArray *randomArr=[self randomDataFromLower:0 toHigher:9 withQuantity:10];
    UIButton *charTypeBtn=(UIButton*)[self.accessoryView viewWithTag:LDDButtonTypeChar];
    UIButton *signTypeBtn=(UIButton*)[self.accessoryView viewWithTag:LDDButtonTypeSign];
    
    if (charTypeBtn.selected || signTypeBtn.selected) {
        __block NSInteger index=0;
        [self.numberView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button=(UIButton*)obj;
            if (button.tag!=LDDButtonTypeLogin && button.tag!=LDDButtonTypeDelete) {
                NSNumber *number=randomArr[index++];
                [button setTitle:number.stringValue forState:UIControlStateNormal];
            }
        }];
    }
}



//产生任意范围内任意数量的随机数(使用此方法)
-(NSArray*)randomDataFromLower:(NSInteger)lower
                      toHigher:(NSInteger)higher
                  withQuantity:(NSInteger)quantity{
    
    NSMutableArray *myRandomNumbers=[NSMutableArray array];
    if (!quantity||quantity>(higher-lower)+1) {
         quantity=(higher-lower)+1;
        
    }
    while (myRandomNumbers.count!=quantity) {
       NSInteger myNumber=arc4random_uniform((uint32_t)(higher+1-lower))+(uint32_t)lower;
        if (![myRandomNumbers containsObject: @(myNumber)]) {
            [myRandomNumbers addObject:@(myNumber)];
        }
    }
    return [myRandomNumbers copy];//可变数组变成不可变
    
    
}

//直接产生0-9随机数
-(NSArray*)randomData{
    NSMutableArray *numberArr=[NSMutableArray arrayWithArray:@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@0]];
    NSInteger numberCount=numberArr.count;
    NSMutableArray *tmpArr=[NSMutableArray array];
    for (NSInteger i=0; i<numberCount; i++) {
        NSNumber *number=numberArr[arc4random() % numberArr.count];
        [tmpArr addObject:number];
        [numberArr removeObject:number];
    }
    
    return tmpArr;
    
}

+(instancetype)loadKeyboardFromNib{
    
    return [[[NSBundle mainBundle]loadNibNamed:@"LDDKeyboardView" owner:self options:nil]lastObject];
}
@end
