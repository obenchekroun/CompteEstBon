//
//  ViewController.m
//  CompteEstBon
//
//  Created by Othmane Benchekroun on 26/08/2015.
//  Copyright (c) 2015 BO. All rights reserved.
//

#import "ViewController.h"

#define ADD    '+'
#define MUL    '*'
#define SOUS   '-'
#define DIV    '/'

typedef struct
{
    long valeur1[16];
    char operation[16];
    long valeur2[16];
    long resultat[16];
} solution;

long plaqueini[16]={1,3,5,7,9,1};
long resultat=377;

long meilleurecart;
int meilleurlevel;

long NombreAppelCompte;

long solutions;

long plaque[16][16]; // 16*16 pour optimiser un peu

solution savesolution;
solution bestsolution;

@interface ViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

- (void)calculer;

-(void) AffichePresentation;
-(void) AfficheErreurParametres;
-(void) affichesolution:(int) l;
-(void) compte:(int) l;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _txtACalculer.delegate = self;
    
    [_calculButton setEnabled:YES];
    _tvResultat.layoutManager.allowsNonContiguousLayout = NO;
    _tvResultat.selectable = NO;
    [_fullResults setEnabled:YES];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    //_attributeSubText = [NSDictionary dictionaryWithObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
    _attributeSubText = @{
                          NSFontAttributeName : [UIFont systemFontOfSize:12],
                          NSForegroundColorAttributeName : [UIColor grayColor]
                          };
    
    
    _attributePrimaryText = @{
                              NSFontAttributeName : [UIFont systemFontOfSize:14],
                              NSForegroundColorAttributeName : [UIColor blackColor]
                              };
    
    _attributeSeparatorText = @{
                                NSFontAttributeName : [UIFont systemFontOfSize:20],
                                NSForegroundColorAttributeName : [UIColor purpleColor]
                                };
    
    _attributeTitleText = @{
                                NSFontAttributeName : [UIFont systemFontOfSize:18],
                                NSForegroundColorAttributeName : [UIColor blackColor],
                                NSParagraphStyleAttributeName : paragraphStyle
                                };
    
    _attributeInstructionsText = @{
                            NSFontAttributeName : [UIFont systemFontOfSize:16],
                            NSForegroundColorAttributeName : [UIColor grayColor],
                            NSParagraphStyleAttributeName : paragraphStyle
                            };
    
    _separatorString = [[NSAttributedString alloc]initWithString:@"------------------------------\n" attributes:_attributeSeparatorText];
    
    NSMutableAttributedString *textInit = [[NSMutableAttributedString alloc]initWithString:@"The Total is Right\n\n" attributes:_attributeTitleText];
    
    NSAttributedString *instructions = [[NSAttributedString alloc]initWithString:@"Enter your problem following the listed example and press Solution!" attributes:_attributeInstructionsText];
    
    [textInit appendAttributedString:instructions];
    
    
    [_tvResultat setAttributedText:textInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self calculer];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    _calculButton.enabled = NO;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *testString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    testString = [testString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if( testString.length)
        _calculButton.enabled = YES;
    else
        _calculButton.enabled = NO;
    
    return YES;
}

#pragma mark - IBAction method implementation

- (IBAction)effacer:(id)sender
{
    _txtACalculer.text = @"";
    _tvResultat.attributedText = [[NSMutableAttributedString alloc]initWithString:@""];
    
    [_txtACalculer resignFirstResponder];
}

- (IBAction)calculerSolution:(id)sender
{
    [_tvResultat setAttributedText:[[NSMutableAttributedString alloc]initWithString:@""]];
    [_txtACalculer resignFirstResponder];
    [self calculer];
}

#pragma mark - Private method implementation


-(void) AffichePresentation
{
    //[_tvResultat setString:[NSString stringBya]appendString:@"Algorithme résolution compte est bon\n\n"];
    
    //[_tvResultat performSelectorOnMainThread:@selector(setText:) withObject:[_tvResultat.text stringByAppendingString:[NSString stringWithFormat:@"Algorithme résolution compte est bon\n\n"]] waitUntilDone:NO];
    
    //[_tvResultat setText:@"Algorithm for The total is right\n\n"];
    
    [_tvResultat setAttributedText:[[NSAttributedString alloc]initWithString:@"Algorithm for The total is right\n" attributes:_attributeInstructionsText]];
    
    printf("Algorithm for The total is right\n");
    printf("\n");
}


-(void)AfficheErreurParametres
{
    
    //[_tvResultat setText:@"Parameters are as the following :\n\n2 5 8 7 9 8 689 \n"];
    [_tvResultat setAttributedText:[[NSAttributedString alloc]initWithString:@"Parameters are as the following :\n\n2 5 8 7 9 8 689 \n" attributes:_attributeSubText]];
    
    printf("Parameters are as follow :\n");
    printf("\n");
    printf("2 5 8 7 9 8 689 \n");
    return;
}

-(void) affichesolution:(int) l
{
    int i;
    
    //[_tvResultat performSelectorOnMainThread:@selector(setText:) withObject:[_tvResultat.text stringByAppendingString:[NSString stringWithFormat:@"******************\n"]] waitUntilDone:NO];
    
    NSMutableAttributedString *historyText = [[NSMutableAttributedString alloc] initWithAttributedString:_tvResultat.attributedText];
    [historyText appendAttributedString:_separatorString];
    
    [_tvResultat setAttributedText:historyText];
    
    printf("******************\n");
    for(i=6;i>l;i--)
    {
        
        //[_tvResultat performSelectorOnMainThread:@selector(setText:) withObject:[_tvResultat.text stringByAppendingString:[NSString stringWithFormat:@"%lu %c %lu = %lu\n",bestsolution.valeur1[i],bestsolution.operation[i],bestsolution.valeur2[i],bestsolution.resultat[i]]] waitUntilDone:NO];
        NSString *daz = [[NSString alloc]initWithFormat:@"%lu %c %lu = %lu\n",bestsolution.valeur1[i],bestsolution.operation[i],bestsolution.valeur2[i],bestsolution.resultat[i]];
        
        NSAttributedString *solutionText = [[NSAttributedString alloc]initWithString:daz attributes:_attributePrimaryText];
        historyText = [[NSMutableAttributedString alloc] initWithAttributedString:_tvResultat.attributedText];
        [historyText appendAttributedString:solutionText];
        
        [_tvResultat setAttributedText:historyText];
        
        printf("%lu %c %lu = %lu\n",bestsolution.valeur1[i],bestsolution.operation[i],bestsolution.valeur2[i],bestsolution.resultat[i]);
    }
    
    //[_tvResultat setText:[_tvResultat.text stringByAppendingString:[NSString stringWithFormat:@"******************\n"]]];
    historyText = [[NSMutableAttributedString alloc] initWithAttributedString:_tvResultat.attributedText];
    [historyText appendAttributedString:_separatorString];
    [_tvResultat setAttributedText:historyText];
    
    printf("******************\n");
}

-(void) compte:(int) l
{
    int i,j,k,n;
    long plaque1,plaque2;
    long ecart;
    long r;
    
    NombreAppelCompte++;
    
    ecart=resultat-plaque[l][0];
    if(ecart<0)
        ecart=-ecart;
    if(ecart<=meilleurecart)
    {
        if(ecart<meilleurecart)
        {
            meilleurecart=ecart;
            bestsolution=savesolution;
            meilleurlevel=l;
            if(!ecart)
            {
                solutions++;
                [self affichesolution:l];
            }
        }
        else  // (ecart==meilleurecart)
        {
            if(!ecart)
                solutions++;
                if(_fullResults.isOn)
                    [self affichesolution:l];
            
            if(l>meilleurlevel)
            {
                bestsolution=savesolution;
                meilleurlevel=l;
                if(!ecart)
                    [self affichesolution:l];
            }
        }
    }
    
    if(l==1)
        return;
    
    for(i=0;i<l-1;i++)
    {
        for(j=i+1;j<l;j++)
        {
            plaque1=plaque[l][i];     // prend 2 plaques
            plaque2=plaque[l][j];     // parmi les C(l,2)=(l*l-1)/2 possibles
            
            
            n=1;
            for(k=0;k<l;k++)
            {
                if(k!=i && k!=j)
                {
                    plaque[l-1][n]=plaque[l][k];
                    n++;
                }
            }
            
            plaque[l-1][0]=plaque1+plaque2;
            savesolution.valeur1[l]=plaque1;
            savesolution.operation[l]=ADD;
            savesolution.valeur2[l]=plaque2;
            savesolution.resultat[l]=plaque[l-1][0];
            [self compte:(l-1)];
            if(plaque1!=1 && plaque2!=1)
            {
                plaque[l-1][0]=plaque1*plaque2;
                //      savesolution.valeur1[l]=plaque1; inutile car fait juste avant
                savesolution.operation[l]=MUL;
                //      savesolution.valeur2[l]=plaque2;  inutile car fait juste avant
                savesolution.resultat[l]=plaque[l-1][0];
                [self compte:(l-1)];
                
                if(plaque1>=plaque2)
                {
                    plaque[l-1][0]=plaque1-plaque2;
                    if(plaque[l-1][0])
                    {
                        //          savesolution.valeur1[l]=plaque1;
                        savesolution.operation[l]=SOUS;
                        //          savesolution.valeur2[l]=plaque2;
                        savesolution.resultat[l]=plaque[l-1][0];
                        [self compte:(l-1)];
                    }
                    r=plaque1%plaque2;
                    if(!r)
                    {
                        plaque[l-1][0]=plaque1/plaque2;
                        //          savesolution.valeur1[l]=plaque1;
                        savesolution.operation[l]=DIV;
                        //          savesolution.valeur2[l]=plaque2;
                        savesolution.resultat[l]=plaque[l-1][0];
                        [self compte:(l-1)];
                    }
                }
                else
                {
                    plaque[l-1][0]=plaque2-plaque1; // toujours superieur à 0
                    savesolution.valeur1[l]=plaque2;
                    savesolution.operation[l]=SOUS;
                    savesolution.valeur2[l]=plaque1;
                    savesolution.resultat[l]=plaque[l-1][0];
                    [self compte:(l-1)];
                    
                    r=plaque2%plaque1;
                    if(!r)
                    {
                        plaque[l-1][0]=plaque2/plaque1;
                        //          savesolution.valeur1[l]=plaque2;
                        savesolution.operation[l]=DIV;
                        //          savesolution.valeur2[l]=plaque1;
                        savesolution.resultat[l]=plaque[l-1][0];
                        [self compte:(l-1)];
                    }
                }
            }
            else if(plaque1>=plaque2)
            {
                plaque[l-1][0]=plaque1-plaque2;
                if(plaque[l-1][0])
                {
                    //        savesolution.valeur1[l]=plaque1;
                    savesolution.operation[l]=SOUS;
                    //        savesolution.valeur2[l]=plaque2;
                    savesolution.resultat[l]=plaque[l-1][0];
                    [self compte:(l-1)];
                }
            }
            else
            {
                plaque[l-1][0]=plaque2-plaque1; // toujours superieur à 0
                savesolution.valeur1[l]=plaque2;
                savesolution.operation[l]=SOUS;
                savesolution.valeur2[l]=plaque1;
                savesolution.resultat[l]=plaque[l-1][0];
                [self compte:(l-1)];
            }
        }
    }
}

-(void)calculer;
{
    [_tvResultat setText:@""];
    [_fullResults setEnabled:NO];
    int i;
    
    NSString *param = [[NSString alloc]initWithString:_txtACalculer.text];
    NSArray *arrayParam = [param componentsSeparatedByString:@" "];
    [self AffichePresentation];
    int argc = (int) arrayParam.count;
    //printf("%i",argc);
    //NSLog(@"%i",[[arrayParam objectAtIndex:1]intValue]);
    
    if(argc==7)
    {
        for(i=0;i<6;i++)
        {
            plaqueini[i] = [[arrayParam objectAtIndex:i]intValue];
            if(plaqueini[i]<=0)
            {
                [self AfficheErreurParametres];
                return;
            }
        }
        resultat = [[arrayParam objectAtIndex:6]intValue];
        if (resultat<=0)
        {
            [self AfficheErreurParametres];
            return;
        }
    }
    else
    {
        [self AfficheErreurParametres];
        return;
    }
    for(i=0;i<6;i++)   // Résultat dans les 6 nombres
    {
        if(resultat==plaqueini[i])
        {
            
            [_tvResultat setAttributedText:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"Solution in the original 6 numbers : %ld \n",resultat] attributes:_attributeSubText]];
            
            printf("Solution in the original 6 numbers : %ld \n",resultat);
            return;
        }
    }
    for(i=0;i<6;i++)  // initialise plaque[][]
        plaque[6][i]=plaqueini[i];
    meilleurecart=LONG_MAX; //ecart maximal
    meilleurlevel=INT_MAX;
    
    NombreAppelCompte=0;
    
    solutions=0;
    
    [self compte:6];
    
    if(meilleurecart>0)
    {
        
        [_tvResultat setAttributedText:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"Closest Solution \n"] attributes:_attributeSubText]];
        
        printf("Closest solution :\n");
        [self affichesolution:meilleurlevel];
    }
    
    printf("\n");
    printf("N solutions : %lu\n",solutions);
    printf("min ecart : %lu\n",meilleurecart);
    printf("N appels fonction récursive : %lu \n",NombreAppelCompte);
    
    
    NSMutableAttributedString *historyText = [[NSMutableAttributedString alloc] initWithAttributedString:_tvResultat.attributedText];
    NSString *stats = [[NSString alloc]initWithFormat:@"\n N solutions : %lu \n min delta : %lu \n N recursive function calls : %lu \n",solutions,meilleurecart,NombreAppelCompte];
    NSMutableAttributedString *statsText = [[NSMutableAttributedString alloc]initWithString:stats attributes:_attributeSubText];
    
    [historyText appendAttributedString:statsText];
    [_tvResultat setAttributedText:historyText];
    
    [_tvResultat layoutIfNeeded];
    NSRange range = NSMakeRange(_tvResultat.text.length - 2, 1); //I ignore the final carriage return, to avoid a blank line at the bottom
    [_tvResultat scrollRangeToVisible:range];
    
    //[_tvResultat setText:[_tvResultat.text stringByAppendingString:[NSString stringWithFormat:@"\n N solutions : %lu \n min delta : %lu \n N recursive function calls : %lu \n",solutions,meilleurecart,NombreAppelCompte]]];
    
    [_fullResults setEnabled:YES];
    return;
}

@end
