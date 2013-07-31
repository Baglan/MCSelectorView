# MCSelectorView

Horizontal selector where values can be chosen by either scrolling or tapping. Can be thought asa customized version of the UIPickerView.

## Installation

Add files in the the 'Classes' folder to your project.

## Usage

MCSelectorView was designed to take advantage of an existing element laid out in the Interface Builder or created by some other means. Below is the typical scenario:

1. Design an element in the Inteface Builder. Sample project uses a UILabel, but it can be any kind of UIView or a UIView subclass;
2. Initialize selector, add it to a superview and present it:


		#import "MCSelectorView.h"
		
		...
		
		_selectorView = [[MCSelectorView alloc] init];
    	_selectorView.dataSource = self;
    	_selectorView.delegate = self;
    	[self.view addSubview:_selectorView];
    	[_selectorView present];

3. Implement the MCSelectorViewDataSource methods; here's the code from the sample project:

		- (CGRect)optionRectForSelectorView:(MCSelectorView *)view
		{
		    return _sampleLabel.frame;
		}
		
		- (NSArray *)optionViewsForSelectorView:(MCSelectorView *)view
		{
		    NSArray * optionTitles = @[@"One", @"Two", @"Three", @"Four", @"Five"];
		    NSMutableArray * options = [NSMutableArray array];
		    
		    [optionTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		        UILabel * label = [self copyLabel];
		        label.text = obj;
		        [options addObject:label];
		    }];
		    
		    return options;
		}

4. Implement the __selectorView:didSelectOptionAtIndex:__ methods of the *MCSelectorViewDelegate* protocol:

		- (void)selectorView:(MCSelectorView *)selectorView didSelectOptionAtIndex:(NSUInteger)index
		{
		    // Do something useful with the index
		}

5. Optionally, implement other available methods to decorate the selector view or change it's behavior; check the MCSelectorView.h file for possible options.


## License

All the code and other assets in this project are avaiable under the MIT license.