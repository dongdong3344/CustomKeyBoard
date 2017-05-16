//
//  LDDAlertView.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/12.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDAlertView.h"
#import "UIView+TYAlertView.h"

static const CGFloat spacing=20.0;

@interface LDDAlertView ()
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation LDDAlertView




-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.bgView.layer.cornerRadius=5;
    self.bgView.layer.masksToBounds=YES;
       
   
}


- (IBAction)cancelBtnClick:(UIButton *)sender {
    
    [self hideView];
    
     [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmBtnClick:(UIButton *)sender {
    
     [self hideView];
   
    if (self.comfirmBlock) {
        self.comfirmBlock();
    }
    
}


-(void)labelAlignment{
    
    CGFloat labelWidth=self.frame.size.width-2*spacing;
    CGSize size = [self.msgLabel.text boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT) options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName:self.msgLabel.font} context:nil].size;
    
    if (size.width<=labelWidth) {
        //一行居中显示
        self.msgLabel.textAlignment=NSTextAlignmentCenter;
        
    }else{
        //一行以上，左对齐
        self.msgLabel.textAlignment=NSTextAlignmentLeft;
    }
}


+(instancetype)loadAlertView{
    
    return [[[NSBundle mainBundle]loadNibNamed:@"LDDAlertView" owner:self options:nil]lastObject];
}

@end
