//
//  LDDSelectPhotoPicker.h
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/9.
//  Copyright © 2017年 Ringo. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef void(^LDDSelectPhotoPickerBlock)(UIImage *image);

@interface LDDSelectPhotoPicker : UIImagePickerController


+(instancetype)sharedTool;


-(void)showImageViewSelectWithResultBlock:(LDDSelectPhotoPickerBlock)selectPhotoBlock;

@end
