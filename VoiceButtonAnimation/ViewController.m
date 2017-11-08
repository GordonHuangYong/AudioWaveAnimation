//
//  ViewController.m
//  VoiceButtonAnimation
//
//  Created by yunfei on 2017/9/26.
//  Copyright © 2017年 yunfei. All rights reserved.
//

#import "ViewController.h"
#import "VoiceRecordButton.h"
#import "WaveView.h"

@interface ViewController () <VoiceButtonDelegate, WaveViewDelegate>
@property (strong, nonatomic) VoiceRecordButton *voiceRecordBtn;
@property (strong, nonatomic) WaveView *waveView;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *pointArray;
@end

@implementation ViewController
- (NSMutableArray *)pointArray
{
    if (_pointArray == nil) {
        _pointArray = [NSMutableArray array];
    }
    return _pointArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat width = 40;
    VoiceRecordButton *voiceRecordBtn = [[VoiceRecordButton alloc] initWithFrame:NSMakeRect(200, 100, width, width)];
    voiceRecordBtn.target = self;
    voiceRecordBtn.action = @selector(recordEvent:);
    voiceRecordBtn.delegate = self;
    voiceRecordBtn.recordingDuration = NSIntegerMax;
    [self.view addSubview:voiceRecordBtn];
    self.voiceRecordBtn = voiceRecordBtn;
    
    self.waveView = [[WaveView alloc] initWithFrame:NSMakeRect(100, 10, 300, width)];
    self.waveView.delegate = self;
    self.waveView.playDuration = 5;
    [self.view addSubview:self.waveView];
    
    
    NSButton *stopBtn = [[NSButton alloc] initWithFrame:NSMakeRect(200, 200, 50, 50)];
    stopBtn.title = @"stop";
    stopBtn.target = self;
    stopBtn.action = @selector(stopEvent:);
    [self.view addSubview:stopBtn];
    
    NSButton *playBtn = [[NSButton alloc] initWithFrame:NSMakeRect(300, 200, 50, 50)];
    playBtn.title = @"play";
    playBtn.target = self;
    playBtn.action = @selector(playEvent:);
    [self.view addSubview:playBtn];
    
    NSButton *pauseBtn = [[NSButton alloc] initWithFrame:NSMakeRect(400, 200, 50, 50)];
    pauseBtn.title = @"pause";
    pauseBtn.target = self;
    pauseBtn.action = @selector(pauseEvent:);
    [self.view addSubview:pauseBtn];
}



#pragma mark - 定时器，造数据
- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)addTimer{
    //添加定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(addPoint) userInfo:nil repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)addPoint
{
    //随机点
     NSPoint point = NSMakePoint(self.voiceRecordBtn.bounds.size.height / 2.f, arc4random_uniform(NSHeight(self.voiceRecordBtn.frame) / 4.f) + 0);
    
    //插入到数组最前面（动画视图最右边），array添加CGPoint需要转换一下
//    [self.pointArray insertObject:[NSValue valueWithPoint:point] atIndex:0];
    [self.pointArray addObject:[NSValue valueWithPoint:point]];
    
    //传值，重绘视图
    self.voiceRecordBtn.pointArray = self.pointArray;
}


#pragma mark - Events
//录音
- (void)recordEvent:(VoiceRecordButton *)sender{
    //移除定时器
    [self removeTimer];
    [self.pointArray removeAllObjects];
    
    [self.voiceRecordBtn startAnimation];
}

//停止录音
- (void)stopEvent:(NSButton *)sender{
//    [self.voiceRecordBtn stopRecording];
    [self voiceRecordingDidFinish];
}

- (void)playEvent:(NSButton *)sender{
    [self.waveView play];
}

- (void)pauseEvent:(NSButton *)sender{
    [self.waveView pause];
}

#pragma mark - voice recording button delegate
//录音即将开始
- (void)voiceRecordingWillBegin{
    //之前的动画只是图层动画，图层已经到了目标位置，但视图的 frame 还在原来的位置，因此要修改视图的位置和尺寸
    NSRect frame = self.voiceRecordBtn.frame;
    CGFloat centerX = frame.origin.x + frame.size.width / 2.f;
    CGFloat centerY = frame.origin.y + frame.size.height / 2.f - frame.size.height;
    frame.size.width = 400; //这里直接将尺寸设为最大了，这样后面绘制数据时就不用关心尺寸，只需要关心图层即可
    frame.origin.x = centerX - frame.size.width / 2.f;
    frame.origin.y = centerY - frame.size.height / 2.f;
    self.voiceRecordBtn.frame = frame;
    
    //添加计时器，构造模拟数据
    [self addTimer];
}

//录音完成
- (void)voiceRecordingDidFinish{
    [self removeTimer];

    self.waveView.playDuration = 5; //播放时长
    self.waveView.pointArray = self.pointArray;  //波形图 NSPoint 数组
}


#pragma mark - voice playing button delegate
- (void)voicePlayingDidFinished{
    
}

- (void)waveAnimationDidFinished{
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
