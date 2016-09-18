//
//  ViewController.m
//  FMImageTextScroll
//
//  Created by zhufaming on 16/9/15.
//  Copyright © 2016年 zhufaming. All rights reserved.
//

#import "ViewController.h"
#import "FMImageTextScroller.h"
#import "SourceModel.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *imageNames = @[
                           
                            @"http://img1.shougongke.com/Public/data/hand/201507/27/topic/1437989144334_312.jpg",
                            @"http://img1.shougongke.com/Public/data/hand/201507/27/topic/1437989024721_312.jpg",
                            @"http://img1.shougongke.com/Public/data/hand/201507/27/topic/1437988940687_312.jpg",
                            @"http://img1.shougongke.com/Public/data/hand/201507/27/topic/1437988949635_312.jpg",
                            @"http://img1.shougongke.com/Public/data/hand/201507/27/topic/1437988975581_312.jpg"];
    
    NSMutableArray *sourceArray=[NSMutableArray array];
    
    for (int i=0; i<imageNames.count; ++i) {
        
        SourceModel *sourceM=[[SourceModel alloc] init];
        sourceM.imgUrl=imageNames[i];
        sourceM.imgText=[NSString stringWithFormat:@"This %d 张图片",i+1];
        
        [sourceArray addObject:sourceM];
    }
    
    FMImageTextScroller *imgSc = [FMImageTextScroller imageScrollWithframe:CGRectMake(10, 60, 355, 200) withSoureceArray:[sourceArray mutableCopy] withFlag:YES];
    
    imgSc.touchBlock=^(SourceModel *soureM){
       //你需要的操作
        NSLog(@"model:%@",soureM);
    };
    
    
    
    //    imgSc.userInteractionEnabled = YES;
    //    imgSc.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:imgSc];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
