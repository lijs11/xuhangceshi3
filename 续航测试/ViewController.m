//
//  ViewController.m
//  续航测试
//
//  Created by Kenny.li on 16/4/5.
//  Copyright (c) 2016年 KK. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startTest;
@property (nonatomic,strong)MPMoviePlayerController *mpc;
@property (nonatomic,assign)int i;

@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong) NSString *str;

- (IBAction)startBtn;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong)NSTimer *currentTimerTimer;
@property (nonatomic,assign)NSTimeInterval j;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;

@end

@implementation ViewController



- (MPMoviePlayerController *)mpc{
    if (_mpc == nil) {
        
        self.mpc = [[MPMoviePlayerController alloc] init];
        self.mpc.contentURL = [[NSBundle mainBundle] URLForResource:@"minion_01.mp4" withExtension:nil];
        self.mpc.view.frame = CGRectMake(10, 130, 355, 300);
        [self.view addSubview:self.mpc.view];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playCounts) name:MPMoviePlayerPlaybackDidFinishNotification object:self.mpc];
    }
    
    return _mpc;
    
}


- (UIWebView *)webView{
    
    if (_webView == nil) {
        
        self.webView = [[UIWebView alloc] init];
        self.webView.frame = self.view.bounds;
        self.webView.delegate = self;
        [self.view addSubview:self.webView];
    }
    
    return _webView;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.batteryLabel.text = @"获取电量中...";
//    [self getBatteryInfo];
}

//获取电池当前的状态，共有4种状态
-(NSString*)getBatteryState {
    UIDevice *device = [UIDevice currentDevice];
    if (device.batteryState == UIDeviceBatteryStateUnknown) {
        return @"UnKnow";
    }else if (device.batteryState == UIDeviceBatteryStateUnplugged){
        return @"Unplugged";
    }else if (device.batteryState == UIDeviceBatteryStateCharging){
        return @"Charging";
    }else if (device.batteryState == UIDeviceBatteryStateFull){
        return @"Full";
    }
    return nil;
}

//获取电量的等级，0.00~1.00
-(float)getBatteryLevel {
    return [UIDevice currentDevice].batteryLevel;
}

-(void)getBatteryInfo
{
    NSString *state =[self getBatteryState];
    float level = [self getBatteryLevel] * 100.0;
    //yourControlFunc(state, level);  //写自己要实现的获取电量信息后怎么处理
    if ((int)level == 100) {
        
//        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
//        NSString *totalTime =self.timeLabel.text;
//        [defaults setObject:totalTime forKey:@"totalTime"];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES) lastObject];
        
        NSString *filePath = [documentPath stringByAppendingPathComponent:@"time.txt"];
       [self.timeLabel.text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [self screenshot];
    }
    
    
    NSLog(@"电池电量：%.f",level);
    NSLog(@"电池状态：%@",state);
    self.batteryLabel.text = [NSString stringWithFormat:@"%@ %.2f%%",state,level];
}

//打开对电量和电池状态的监控，类似定时器的功能
-(void)didLoadBatteryMonitoring
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBatteryInfo) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBatteryInfo) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getBatteryInfo) userInfo:nil repeats:YES];
}



- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
//        NSLog(@"电池电量：%.2f", [UIDevice currentDevice].batteryLevel);
        [self didLoadBatteryMonitoring];
        
    }
    return self;
}





- (IBAction)startBtn {
    
    
    [self removeTimer];
    
        [self addTimer];
    
//        [self startWeb];
        [self.mpc play];
    
}

- (void)playCounts{
    
    
       self.i++;
        
        if (self.i < 2) {
           
            [self.mpc play];
            
        }else{
            
            [self.mpc stop];
            [self.mpc.view removeFromSuperview];
            [self startWeb];
             self.i = 0;
        
        }
    
    
}


- (void)startWeb{
    
    NSString *str = @"http://www.baidu.com";
    self.str = str;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",str]]];
    [self.webView loadRequest:request];
    
    
}

- (void)startPhone{
    
    NSString *str = @"tel://10010";
    self.str = str;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
    [self.webView loadRequest:request];
    
    
}



- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    self.i++;
    
    if ([self.str isEqual:@"http://www.baidu.com"] ) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.i < 2) {
                
                [self.webView reload];
                
            }else{
                
                [self.webView stopLoading];
                [self startPhone];
                self.i = 0;
            }
            
        });
        
        
    }else{
        
        
        
            
            if (self.i < 2) {
                [UIView animateWithDuration:10.0 animations:^{
                    [self.webView stopLoading];
                } completion:^(BOOL finished) {
                    [self.webView reload];
                }];
              
            }else{
               
                [self.webView stopLoading];
                [self.webView removeFromSuperview];
                [self startBtn];
                self.i = 0;
            }
            
        
    }
  
    
    
}





- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)addTimer{
    
    self.currentTimerTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.currentTimerTimer forMode:NSRunLoopCommonModes];
    
    
}


- (void)updateCurrentTime{
    
    self.j += 1;
    
    self.timeLabel.text = [self strWithTime:self.j];
    
}


- (void)removeTimer{
    
    [self.currentTimerTimer invalidate];
    self.currentTimerTimer = nil;
    self.j = 0;
    self.timeLabel.text = [self strWithTime:self.j];
}



- (NSString *)strWithTime:(NSTimeInterval)time{
    
    int minite = time / 60;
    int second = (int)time % 60;
    
    return [NSString stringWithFormat:@"%.2d:%.2d",minite,second];
    
}


- (void)screenshot{
    static dispatch_once_t disOnce;
    
    dispatch_once(&disOnce,  ^ {
        // 该干嘛就干嘛
   
    UIGraphicsBeginImageContext(self.view.bounds.size);     //currentView 当前的view  创建一个基于位图的图形上下文并指定大小为
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];//renderInContext呈现接受者及其子范围到指定的上下文
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();//返回一个基于当前图形上下文的图片
    UIGraphicsEndImageContext();//移除栈顶的基于当前位图的图形上下文
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);//然后将该图片保存到图片图
        
     });
}



@end
