//
//  LDDSelectPhotoPicker.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/9.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDSelectPhotoPicker.h"
#import "LDDHeadPicture.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "LDDSheetController.h"
#import <AVFoundation/AVFoundation.h>  
#import "UIView+TYAlertView.h"
#import "LDDAlertView.h"

static const CGFloat spaceMargin=40.0;
typedef NS_ENUM(NSUInteger,LDDSheetActionType) {
    LDDSheetActionTypeCarmera=301,  //相机
    LDDSheetActionTypeLibrary,      //相册
    LDDSheetActionTypeCancel,       //取消
};

static LDDSelectPhotoPicker *_picker;

@interface LDDSelectPhotoPickerDelegate: NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic,copy)LDDSelectPhotoPickerBlock selectPhotoBlock;

@end


@interface LDDSelectPhotoPicker ()

@property(nonatomic,strong)LDDSelectPhotoPickerDelegate *photoPickerDelegate;
@property(nonatomic,strong)LDDSheetController *sheetController;

@end

@implementation LDDSelectPhotoPicker

//单例
+(instancetype)sharedTool{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _picker=[[self alloc]init];
        
    });
    return _picker;
    
}

-(void)showImageViewSelectWithResultBlock:(LDDSelectPhotoPickerBlock)selectPhotoBlock{
    //设置代理
    _picker.photoPickerDelegate=[[LDDSelectPhotoPickerDelegate alloc]init];
    _picker.delegate=_picker.photoPickerDelegate;
    //对代理里的block进行赋值
    _picker.photoPickerDelegate.selectPhotoBlock =selectPhotoBlock;
    
    //允许编辑
    _picker.allowsEditing=YES;
    
    /**
     使用自定义的sheet
     */
    LDDSheetController *sheet=[[LDDSheetController alloc]init];
   
    sheet.modalPresentationStyle = UIModalPresentationOverCurrentContext;//OverCurrentContext,sheet是被present的控制器
     [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:sheet animated:YES completion:nil];
    
    __weak typeof(sheet) weakSheet=sheet;
    sheet.sheetBlock = ^(NSInteger buttonTag) {
        
        NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
      
        switch (buttonTag) {
    
            /**相机按钮*/
            case LDDSheetActionTypeCarmera:
            
                if(authStatus==AVAuthorizationStatusAuthorized){
                //选择相机时，设置UIImagePickerController对象相关属性
                _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                _picker.modalPresentationStyle = UIModalPresentationFullScreen;
                _picker.mediaTypes = @[(NSString *)kUTTypeImage];
                _picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                //跳转到UIImagePickerController控制器弹出相机
                [weakSheet presentViewController:_picker animated:YES completion:nil];
                
                }else if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                    
                    LDDAlertView *alertView=[LDDAlertView loadAlertView];
                    alertView.msgLabel.text=@"此App无法获取相机权限，点击确定按钮前往设置";
                    alertView.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-2*spaceMargin, 192);
                    
                    [alertView labelAlignment];//label文字Alignment
                    [alertView showInWindow];
                    alertView.comfirmBlock = ^{
                         //跳转至设置app权限页面
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                        }
                        
                    };
                    
                
                }else{
                    
                    LDDAlertView *alertView=[LDDAlertView loadAlertView];
                    alertView.msgLabel.text=@"当前设备不支持该操作";
                    alertView.msgLabel.textAlignment=NSTextAlignmentCenter;
                    alertView.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-2*spaceMargin, 192);
                    [alertView labelAlignment];//label文字Alignment
                    [alertView showInWindow];
                    alertView.comfirmBlock = ^{
                    
                         [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
                    };
               
                }
                break;
                
                
            /**相册按钮*/
            case LDDSheetActionTypeLibrary:
                
                _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                //跳转到UIImagePickerController控制器弹出相册
                [weakSheet presentViewController:_picker animated:YES completion:nil];

                break;
                
            /**取消按钮*/
            case LDDSheetActionTypeCancel:
                [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
                break;
              
        }
        
    };
    
}


@end


//代理协议
@implementation LDDSelectPhotoPickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image;
    //判断图片是否允许修改
    if ([picker allowsEditing]){
        //通过info字典获取选择的照片
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    }else{
        //通过info字典获取选择的照片
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    //以itemKey为键，将照片存入ImageStore对象中
    [[LDDHeadPicture sharedPicture]setImage:image forKey:@"HeadPicture"];
    
    //block传图片
    if (self.selectPhotoBlock)  self.selectPhotoBlock(image);
    
    //如果是通过相册拍照，保存图片至相册
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
    
    //关闭以模态形式显示的UIImagePickerController
    [[UIApplication sharedApplication].keyWindow.rootViewController  dismissViewControllerAnimated:YES completion:nil];
    
}

//取消选择图片
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [[UIApplication sharedApplication].keyWindow.rootViewController  dismissViewControllerAnimated:YES completion:nil];
}

@end
