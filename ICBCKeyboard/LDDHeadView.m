//
//  LDDHeadView.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/11.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDHeadView.h"
#import "LDDSelectPhotoPicker.h"
#import "LDDScanImage.h"

@implementation LDDHeadView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    //设置头像相关属性
    _iconImgView.layer.cornerRadius=self.iconImgView.frame.size.width/2.0;
    _iconImgView.layer.masksToBounds=YES;
    _iconImgView.layer.borderWidth=1.5;
    _iconImgView.layer.borderColor=[UIColor whiteColor].CGColor;
    _iconImgView.userInteractionEnabled=YES;
    //添加手势
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scanBigImageClick:)];
    [_iconImgView addGestureRecognizer:tapGesture];
    
}

//点击编辑头像按钮
- (IBAction)selectImage:(UIButton *)button {
    __weak typeof(self) weakSelf=self;
    [[LDDSelectPhotoPicker sharedTool]showImageViewSelectWithResultBlock:^(UIImage *image){
        weakSelf.iconImgView.image=image;
    }];
    
}
//点击头像，大图显示
-(void)scanBigImageClick:(UITapGestureRecognizer *)tap{
    
    UIImageView *imgView = (UIImageView *)tap.view;
    [[LDDScanImage sharedBigImage]scanBigImageWithImageView:imgView];;
}

+(instancetype)loadHeadView{
    
    return [[[NSBundle mainBundle]loadNibNamed:@"LDDHeadView" owner:nil options:nil]lastObject];
}

@end
