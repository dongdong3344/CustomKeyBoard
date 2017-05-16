//
//  LDDHeadPicture.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/9.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDHeadPicture.h"

@interface LDDHeadPicture ()

@property (nonatomic, strong) NSMutableDictionary *dict;

-(NSString *)imagePathForKey:(NSString *)key;

@end

@implementation LDDHeadPicture


+(instancetype)sharedPicture{
    static LDDHeadPicture *headPicture=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        headPicture=[[self alloc]initPrivate];
    });
    return headPicture;
}


-(instancetype)initPrivate{
    
    self = [super init];
    if (self) {
        
        _dict = [[NSMutableDictionary alloc] init];
        //注册为低内存通知的观察者
        NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
        [notification addObserver:self
               selector:@selector(clearCaches:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    return self;
}

-(void)setImage:(UIImage *)image forKey:(NSString *)key{
    
    [self.dict setObject:image forKey:key];
    
    //获取保存图片的全路径
    NSString *path = [self imagePathForKey:key];
    
    //从图片提取JPEG格式的数据,第二个参数为图片压缩参数
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    //以PNG格式提取图片数据
    //NSData *data = UIImagePNGRepresentation(image);
    
    //将图片数据写入文件
    [data writeToFile:path atomically:YES];
}

-(UIImage *)imageForKey:(NSString *)key{
    
    UIImage *image = [self.dict objectForKey:key];
    if (!image) {
        NSString *path = [self imagePathForKey:key];
        image = [UIImage imageWithContentsOfFile:path];
        if (image) {
            [self.dict setObject:image forKey:key];
        }else{
            NSLog(@"Error: unable to find %@", [self imagePathForKey:key]);
        }
    }
    return image;
}

-(NSString *)imagePathForKey:(NSString *)key{
    //获取Documents目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

-(void)clearCaches:(NSNotification *)notification{
    
    NSLog(@"Flushing %ld images out of the cache", (unsigned long)[self.dict count]);
    [self.dict removeAllObjects];
}

@end
