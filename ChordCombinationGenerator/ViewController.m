//
//  ViewController.m
//  ChordCombinationGenerator
//
//  Created by liuge on 12/28/14.
//  Copyright (c) 2014 iLegendSoft. All rights reserved.
//

#import "ViewController.h"
#include <stdlib.h>

@interface ViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *lengthPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *autoGenerateTimeIntervalPicker;

@property (strong, nonatomic) NSArray *autoGenerateTimeIntervals;
@property (strong, nonatomic) NSArray *chordsArray;

@property (weak, nonatomic) IBOutlet UIButton *generateBtn;
@property (weak, nonatomic) IBOutlet UIButton *cheatSheetBtn;

@property (weak, nonatomic) IBOutlet UIView *topContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;

@property (weak, nonatomic) IBOutlet UISwitch *repeatableSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *textOnTopSwitch;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;


@property (strong, nonatomic) NSTimer *autoGenerateTimer;
@property (nonatomic) int countdown;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _autoGenerateTimeIntervals = @[@(0), @(5), @(10), @(15), @(20), @(25), @(30), @(35), @(40), @(45), @(50)];
    _chordsArray = @[@"Am", @"F", @"C", @"Dm", @"Em", @"G"];
    
    
    // pickerView config
    _lengthPicker.delegate = self;
    _lengthPicker.dataSource = self;
    
    _autoGenerateTimeIntervalPicker.delegate = self;
    _autoGenerateTimeIntervalPicker.dataSource = self;
    
    // button appearence TODO:add highlighted color
    _generateBtn.layer.cornerRadius = 2.f;
    _generateBtn.clipsToBounds = YES;
    [_generateBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:100 / 255.f green:150 / 255.f blue:75 / 255.f alpha:1.f]] forState:UIControlStateHighlighted];
    
    _cheatSheetBtn.layer.cornerRadius = 2.f;
    _cheatSheetBtn.clipsToBounds = YES;
    [_cheatSheetBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:100 / 255.f green:150 / 255.f blue:75 / 255.f alpha:1.f]] forState:UIControlStateHighlighted];
    
    [_lengthPicker selectRow:_chordsArray.count inComponent:0 animated:NO];
    [_autoGenerateTimeIntervalPicker selectRow:_autoGenerateTimeIntervals.count / 2.f inComponent:0 animated:NO];
}

#pragma mark - UIButton Action
- (IBAction)didClickGenerate:(id)sender {
    
    if (_autoGenerateTimer && _autoGenerateTimer.isValid) {
        [_autoGenerateTimer invalidate];
        _autoGenerateTimer = nil;
    }
    
    NSArray *randomSequence = [self randomSequenceOfLength:(int)[_lengthPicker selectedRowInComponent:0] + 1 repeatable:_repeatableSwitch.isOn sourceLength:(int)_chordsArray.count];
    
    if (_textOnTopSwitch.isOn) {
        [self addTextToView:_topContainer dataSource:_chordsArray indices:randomSequence];
        [self addImagesToView:_bottomContainer isTopContainer:NO dataSource:_chordsArray indices:randomSequence];
    } else {
        [self addImagesToView:_topContainer isTopContainer:YES dataSource:_chordsArray indices:randomSequence];
        [self addTextToView:_bottomContainer dataSource:_chordsArray indices:randomSequence];
    }
    
    
    _countdown = [_autoGenerateTimeIntervals[[_autoGenerateTimeIntervalPicker selectedRowInComponent:0]] intValue];
    if (_countdown > 0) {
        _countdownLabel.hidden = NO;
        [self refreshCountdownLabelWithCountdown:_countdown];
        _autoGenerateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleCountDownTimer) userInfo:nil repeats:YES];
    } else {
        _countdownLabel.hidden = YES;
    }
}

- (void)handleCountDownTimer {
    [self refreshCountdownLabelWithCountdown:--_countdown];
    if (_countdown <= 0) {
        [self didClickGenerate:nil];
    }
}

- (void)refreshCountdownLabelWithCountdown:(int)countdown {
    _countdownLabel.text = [NSString stringWithFormat:@"%d Seconds Left",_countdown];
}


- (IBAction)didClickCheatSheet:(id)sender {
    _bottomContainer.hidden = !_bottomContainer.hidden;
}



#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _lengthPicker) {
        return [NSString stringWithFormat:@"%ld", (long)row + 1];
    } else if (pickerView == _autoGenerateTimeIntervalPicker) {
        
        int interval = [_autoGenerateTimeIntervals[row] intValue];
        if (interval == 0) {
            return @"Never";
        } else {
            return [NSString stringWithFormat:@"%d", interval];
        }
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _lengthPicker) {
        if (_repeatableSwitch.isOn) {
            return 10;
        } else {
            return _chordsArray.count;
        }
    } else if (pickerView == _autoGenerateTimeIntervalPicker) {
        return _autoGenerateTimeIntervals.count;
    }
    
    return 0;
}



#pragma mark - UISwitch action

- (IBAction)didClickedRepeatableSwitch:(id)sender {
    [_lengthPicker reloadAllComponents];
}

- (IBAction)didClickTextOnTopSwitch:(id)sender {
    
}


#pragma mark - utility method
// may be try NSOrderedSet next time
- (NSArray *)randomSequenceOfLength:(int)length repeatable:(BOOL)repeatable sourceLength:(int)sourceLength {
    if (length == 0 || (length > sourceLength && !repeatable)) return nil;
    
    NSMutableArray *result = [NSMutableArray new];
    
    while (length--) {
        int randomInt;
        
        do {
            randomInt = arc4random_uniform(sourceLength);
        } while (!repeatable && [result containsObject:@(randomInt)]);
        
        [result addObject:@(randomInt)];
    }
    
    return result;
}

- (void)addTextToView:(UIView *)containerView dataSource:(NSArray *)dataSource indices:(NSArray *)indices {
    NSString *content = @"";
    for (int i = 0; i < indices.count; ++i) {
        int index = [indices[i] intValue];
        
        content = [content stringByAppendingString:dataSource[index]];
        
        if (i != indices.count - 1) {
            content = [content stringByAppendingString:@" | "];
        }
    }
    
    [self removeAllSubviewsOfView:containerView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){0, containerView.frame.size.height / 4.f,
        containerView.frame.size.width, 50.f}];
    label.text = content;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:205 / 255.f green:81 / 255.f blue:83 / 255.f alpha:1.f];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:30.f];
    
    [containerView addSubview:label];
}

- (void)addImagesToView:(UIView *)containerView isTopContainer:(BOOL)isTopContainer dataSource:(NSArray *)dataSource indices:(NSArray *)indices {
    
    NSMutableArray *imageCountInRow = [NSMutableArray new];
    
    if (indices.count <= 4) {
        [imageCountInRow addObject:@(indices.count)];
    } else {
        NSInteger imageCountInRow1 = indices.count / 2;// 隐含想下取整
        [imageCountInRow addObject:@(imageCountInRow1)];
        [imageCountInRow addObject:@(indices.count - imageCountInRow1)];
    }
    
    [self removeAllSubviewsOfView:containerView];
    
    CGFloat interval = 8.f;// horizontal and vertical space between imageviews
    CGSize imageViewSize;
    if (isTopContainer) {
        imageViewSize = (CGSize){140, 100};
    } else {
        imageViewSize = (CGSize){140, 140};
    }
    
    int alreadySetCount = 0;
    
    CGFloat startY = (containerView.frame.size.height - imageCountInRow.count * imageViewSize.height - (imageCountInRow.count - 1) * interval) / 2.f;
    
    for (int i = 0; i < imageCountInRow.count; ++i) {
        
        int imageCountInThisRow = [imageCountInRow[i] intValue];
        CGFloat startX = (containerView.frame.size.width - imageCountInThisRow * imageViewSize.width - (imageCountInThisRow - 1) * interval) / 2.f;
        
        for (int j = 0; j < imageCountInThisRow; ++j) {
            UIImageView *imageView = [[UIImageView alloc]
                                      initWithFrame:(CGRect){startX, startY, imageViewSize.width, imageViewSize.height}];
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.clipsToBounds = YES;
            NSInteger index = [indices[alreadySetCount++] integerValue];
            NSString *imageName = dataSource[index];
            if (isTopContainer) imageName = [imageName stringByAppendingString:@"_"];// don't have name of the chord
            imageView.image = [UIImage imageNamed:imageName];
            [containerView addSubview:imageView];
            
            startX += (imageViewSize.width + interval);
        }
        
        startY += ((imageViewSize.height + interval));
    }
}


- (void)removeAllSubviewsOfView:(UIView *)view {
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
