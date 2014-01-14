//
//  ViewController.h
//  MCSelectorView
//
//  Created by Baglan on 7/30/13.
//  Copyright (c) 2013 MobileCreators. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    __weak IBOutlet UIView *_horizontalContainerView;
    __weak IBOutlet UILabel *_horizontalSampleLabel;
    
    __weak IBOutlet UIView *_verticalContainerView;
    __weak IBOutlet UILabel *_verticalSampleLabel;
}

@end
