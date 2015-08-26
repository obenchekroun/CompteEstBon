//
//  ViewController.h
//  CompteEstBon
//
//  Created by Othmane Benchekroun on 26/08/2015.
//  Copyright (c) 2015 BO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>


@interface ViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtACalculer;
@property (weak, nonatomic) IBOutlet UITextView *tvResultat;
@property (weak, nonatomic) IBOutlet UIButton *calculButton;
@property (weak, nonatomic) IBOutlet UIButton *effacerButton;
@property (weak, nonatomic) IBOutlet UISwitch *fullResults;

@property (nonatomic, strong) NSDictionary *attributeSubText;
@property (nonatomic, strong) NSDictionary *attributePrimaryText;
@property (nonatomic, strong) NSDictionary *attributeSeparatorText;
@property (nonatomic, strong) NSDictionary *attributeTitleText;
@property (nonatomic, strong) NSDictionary *attributeInstructionsText;

@property (nonatomic, strong) NSAttributedString *separatorString;


- (IBAction)calculerSolution:(id)sender;
- (IBAction)effacer:(id)sender;

@end

