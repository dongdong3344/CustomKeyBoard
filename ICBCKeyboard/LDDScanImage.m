//
//  LDDScanImage.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/9.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDScanImage.h"

#define kScreenW   [UIScreen mainScreen].bounds.size.width
#define kScreenH   [UIScreen mainScreen].bounds.size.height

@implementation LDDScanImage
//原始尺寸
static CGRect oldframe;

+(instancetype)sharedBigImage{
    
    static LDDScanImage *bigImage=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bigImage=[[self alloc]init];
    });
    return bigImage;
}


-(void)scanBigImageWithImageView:(UIImageView *)currentImageview{
    //当前imgview的图片
    UIImage *currentImage = currentImageview.image;
    //当前windown
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //背景
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 20, kScreenW, 30)];
    
    //将currentImageview.bounds所在视图转换到目标视图window中
    oldframe = [currentImageview convertRect:currentImageview.bounds toView:window];
    //设置背景色
    backgroundView.backgroundColor=[UIColor blackColor];
    //此时视图不会显示
    backgroundView.alpha=0.0;
    //将所展示的imageView重新绘制在Window中
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:oldframe];
    imgView.image=currentImage;
    imgView.tag=1024;
    [backgroundView addSubview:imgView];
    [backgroundView addSubview:titleLabel];
    //将原始视图添加到背景视图中
    [window addSubview:backgroundView];
    
    
    //添加点击事件同样是类方法 -> 作用是再次点击回到初始大小
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageView:)];
    [backgroundView addGestureRecognizer:tap];
    
    //动画放大所展示的ImageView
    
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat y,width,height;
        y=(kScreenH - currentImage.size.height * kScreenW / currentImage.size.width) * 0.5;
        //宽度为屏幕宽度
        width=kScreenW;
        //高度根据图片宽高比设置
        height=currentImage.size.height * kScreenW / currentImage.size.width;
        imgView.frame=CGRectMake(0, y, width, height);
        //将视图显示出来
        backgroundView.alpha=1.0;
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)hideImageView:(UITapGestureRecognizer *)tap{
    UIView *backgroundView = tap.view;
    //原始imageView
    UIImageView *imgView = [tap.view viewWithTag:1024];
    //恢复
    [UIView animateWithDuration:0.2 animations:^{
        imgView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        //完成后操作,将背景视图删掉
        [backgroundView removeFromSuperview];
    }];
}

@end
