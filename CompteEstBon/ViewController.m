//
//  ViewController.m
//  CompteEstBon
//
//  Created by Othmane Benchekroun on 26/08/2015.
//  Copyright (c) 2015 BO. All rights reserved.
//

#import "ViewController.h"

#define PP   0   // deux plaques
#define RP   1   // un résultat et une plaque
#define RR   2   // deux résultats
#define RR2  3   // deux résultats mais pas issus des 2 résultats justes précédents (1 autre résultat entre les 2)

#define ADD    '+'
#define MUL    '*'
#define SOUS   '-'
#define DIV    '/'

typedef struct
{
    int typeoperation[8];
} schema;

typedef struct
{
    long valeur1[16];
    char operation[16];
    long valeur2[16];
    long resultat[16];
} solution;

long PlaqueIni[16]={1,3,5,7,9,1};
long Resultat=377;

long MeilleurEcart;
int MeilleurNombrePlaques;

long NombreAppelCompte;

long Solutions;

long Plaque[16][16]; // 16*16 pour optimiser un peu
long ResultatLigne[16];

schema Cas[8][8]=
{{0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {{PP},0,0,0,0,0,0,0},
    {{PP,RP},0,0,0,0,0,0,0},
    {{PP,PP,RR},{PP,RP,RP},0,0,0,0,0,0},
    {{PP,RP,PP,RR},{PP,PP,RR,RP},{PP,RP,RP,RP},0,0,0,0,0},
    {{PP,PP,RR,PP,RR},{PP,RP,PP,RP,RR2},{PP,RP,PP,RR,RP},{PP,RP,RP,PP,RR},{PP,PP,RR,RP,RP},{PP,RP,RP,RP,RP},0,0},
    {0,0,0,0,0,0,0,0}};

int NombreConfigs[8]={0,0,1,1,2,3,6,0};

int NombrePlaques;
int Config;

solution SaveSolution;
solution BestSolution;

@interface ViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

- (void)calculer;


-(void) AffichePresentation;
-(void) AfficheErreurParametres;
-(void) AfficheSolution:(int) l;
-(void) Calcule:(int)l pP:(int)p plaquesPrises:(int) plaquesPrises plaque1:(long) plaque1 plaque2:(long)plaque2;
-(void) compte:(int)l pP:(int) p;

/*
-(void) AffichePresentation;
-(void) AfficheErreurParametres;
-(void) affichesolution:(int) l;
-(void) compte:(int) l;
 */

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

-(void) AfficheSolution:(int) l
{
    int i;
    
    //[_tvResultat performSelectorOnMainThread:@selector(setText:) withObject:[_tvResultat.text stringByAppendingString:[NSString stringWithFormat:@"******************\n"]] waitUntilDone:NO];
    
    NSMutableAttributedString *historyText = [[NSMutableAttributedString alloc] initWithAttributedString:_tvResultat.attributedText];
    [historyText appendAttributedString:_separatorString];
    
    [_tvResultat setAttributedText:historyText];
    
    printf("******************\n");
    for(i=0;i<l;i++)
    {
        
        //[_tvResultat performSelectorOnMainThread:@selector(setText:) withObject:[_tvResultat.text stringByAppendingString:[NSString stringWithFormat:@"%lu %c %lu = %lu\n",bestsolution.valeur1[i],bestsolution.operation[i],bestsolution.valeur2[i],bestsolution.resultat[i]]] waitUntilDone:NO];
        NSString *daz = [[NSString alloc]initWithFormat:@"%lu %c %lu = %lu\n",BestSolution.valeur1[i],BestSolution.operation[i],BestSolution.valeur2[i],BestSolution.resultat[i]];
        
        NSAttributedString *solutionText = [[NSAttributedString alloc]initWithString:daz attributes:_attributePrimaryText];
        historyText = [[NSMutableAttributedString alloc] initWithAttributedString:_tvResultat.attributedText];
        [historyText appendAttributedString:solutionText];
        
        [_tvResultat setAttributedText:historyText];
        
        printf("%lu %c %lu = %lu\n",BestSolution.valeur1[i],BestSolution.operation[i],BestSolution.valeur2[i],BestSolution.resultat[i]);
    }
    
    //[_tvResultat setText:[_tvResultat.text stringByAppendingString:[NSString stringWithFormat:@"******************\n"]]];
    historyText = [[NSMutableAttributedString alloc] initWithAttributedString:_tvResultat.attributedText];
    [historyText appendAttributedString:_separatorString];
    [_tvResultat setAttributedText:historyText];
    
    printf("******************\n");
}


-(void) Calcule:(int)l pP:(int)p plaquesPrises:(int) plaquesPrises plaque1:(long)plaque1 plaque2:(long)plaque2
{
    long r;
    
    ResultatLigne[l]=plaque1+plaque2;
    SaveSolution.valeur1[l]=plaque1;
    SaveSolution.operation[l]=ADD;
    SaveSolution.valeur2[l]=plaque2;
    SaveSolution.resultat[l]=ResultatLigne[l];
    [self compte:(l+1) pP:(p-plaquesPrises)];
    if(plaque1!=1 && plaque2!=1)
    {
        ResultatLigne[l]=plaque1*plaque2;
        
        SaveSolution.operation[l]=MUL;
        
        SaveSolution.resultat[l]=ResultatLigne[l];
        [self compte:(l+1) pP:(p-plaquesPrises)];
        
        
        if(plaque1>=plaque2)
        {
            ResultatLigne[l]=plaque1-plaque2;
            if(ResultatLigne[l])
            {
                //        SaveSolution.valeur1[l]=plaque1;
                SaveSolution.operation[l]=SOUS;
                //        SaveSolution.valeur2[l]=plaque2;
                SaveSolution.resultat[l]=ResultatLigne[l];
                [self compte:(l+1) pP:(p-plaquesPrises)];
            }
            
            r= plaque1 % plaque2;
            
            if(!r)
            {
                ResultatLigne[l]=plaque1/plaque2;
                //        SaveSolution.valeur1[l]=plaque1;
                SaveSolution.operation[l]=DIV;
                //        SaveSolution.valeur2[l]=plaque2;
                SaveSolution.resultat[l]=ResultatLigne[l];
                [self compte:(l+1) pP:(p-plaquesPrises)];
            }
        }
        else
        {
            ResultatLigne[l]=plaque2-plaque1;
            SaveSolution.valeur1[l]=plaque2;
            SaveSolution.operation[l]=SOUS;
            SaveSolution.valeur2[l]=plaque1;
            SaveSolution.resultat[l]=ResultatLigne[l];
            [self compte:(l+1) pP:(p-plaquesPrises)];
            
            r=plaque2 % plaque1;
            if(!r)
            {
                ResultatLigne[l]=plaque2/plaque1;
                //        SaveSolution.valeur1[l]=plaque2;
                SaveSolution.operation[l]=DIV;
                //      SaveSolution.valeur2[l]=plaque1;
                SaveSolution.resultat[l]=ResultatLigne[l];
                [self compte:(l+1) pP:(p-plaquesPrises)];
            }
        }
    }
    else if(plaque1>=plaque2)
    {
        ResultatLigne[l]=plaque1-plaque2;
        if(ResultatLigne[l])
        {
            //      SaveSolution.valeur1[l]=plaque1;
            SaveSolution.operation[l]=SOUS;
            //      SaveSolution.valeur2[l]=plaque2;
            SaveSolution.resultat[l]=ResultatLigne[l];
            [self compte:(l+1) pP:(p-plaquesPrises)];
        }
    }
    else
    {
        ResultatLigne[l]=plaque2-plaque1;
        SaveSolution.valeur1[l]=plaque2;
        SaveSolution.operation[l]=SOUS;
        SaveSolution.valeur2[l]=plaque1;
        SaveSolution.resultat[l]=ResultatLigne[l];
        [self compte:(l+1) pP:(p-plaquesPrises)];
    }
}



-(void) compte:(int)l pP:(int) p     // l= numeroligne, p=plaqueRestantes
{
    int i,j,k,n;
    long ecart;
    long plaque1,plaque2;
    
    NombreAppelCompte++;
    
    if(l==NombrePlaques-1)
    {
        ecart=Resultat-ResultatLigne[l-1];
        if(ecart<0)
            ecart=-ecart;
        if(ecart<=MeilleurEcart)
        {
            if(ecart<MeilleurEcart)
            {
                MeilleurEcart=ecart;
                BestSolution=SaveSolution;
                MeilleurNombrePlaques=NombrePlaques;
                if(!ecart)
                {
                    Solutions++;
                    [self AfficheSolution:l];
                }
            }
            else     // (ecart==MeilleurEcart)
            {
                if(!ecart)
                    Solutions++;
                    if(_fullResults.isOn)
                        [self AfficheSolution:l];
                if(NombrePlaques<MeilleurNombrePlaques)
                {
                    BestSolution=SaveSolution;
                    MeilleurNombrePlaques=NombrePlaques;
                    if(!ecart)
                        [self AfficheSolution:l];
                }
            }
        }
        
        return;
    }
    
    switch(Cas[NombrePlaques][Config].typeoperation[l])
    {
        case PP :
            
            for(i=0;i<p-1;i++)
            {
                for(j=i+1;j<p;j++)
                {
                    plaque1=Plaque[l][i];   // prend 2 plaques parmi les C(p,2)=(p*(p-1))/2
                    plaque2=Plaque[l][j];   // couples possibles de plaques restantes
                    
                    n=0;
                    for(k=0;k<p;k++)
                    {
                        if(k!=i && k!=j)
                        {
                            Plaque[l+1][n]=Plaque[l][k];
                            n++;
                        }
                    }
                    
                    [self Calcule:l pP:p plaquesPrises:2 plaque1:plaque1 plaque2:plaque2];
                    
                }
            }
            
            break;
            
        case RP :
            
            for(i=0;i<p;i++)
            {
                plaque1=ResultatLigne[l-1];  // prend 1 plaque parmi les p plaques restantes
                plaque2=Plaque[l][i];        // et le resultat pr√©c√©dent
                
                n=0;
                for(k=0;k<p;k++)
                {
                    if(k!=i)
                    {
                        Plaque[l+1][n]=Plaque[l][k];
                        n++;
                    }
                }
                
                [self Calcule:l pP:p plaquesPrises:1 plaque1:plaque1 plaque2:plaque2];
            }
            
            break;
            
        case RR :
            
            plaque1=ResultatLigne[l-2];   // prend les 2 resultats pr√©c√©dents :
            plaque2=ResultatLigne[l-1];
            
            for(k=0;k<p;k++)                  // simple recopie au niveau suivant
                Plaque[l+1][k]=Plaque[l][k];
            
            [self Calcule:l pP:p plaquesPrises:0 plaque1:plaque1 plaque2:plaque2];
            
            break;
            
        case RR2 : // meme chose que "case RR" sauf la ligne qui suit :
            
            plaque1=ResultatLigne[l-3];   // prend les 2 resultats pr√©c√©dents
            plaque2=ResultatLigne[l-1];   // avec un resultat intermediaire : ResultatLigne[l-2] 
            
            for(k=0;k<p;k++)                  // simple recopie au niveau suivant
                Plaque[l+1][k]=Plaque[l][k];
            
            [self Calcule:l pP:p plaquesPrises:0 plaque1:plaque1 plaque2:plaque2];
            
            break;
            
        default :
            printf("Problem in SWITCH \n");
            exit(1);
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
            PlaqueIni[i] = [[arrayParam objectAtIndex:i]intValue];
            if(PlaqueIni[i]<=0)
            {
                [self AfficheErreurParametres];
                return;
            }
        }
        Resultat = [[arrayParam objectAtIndex:6]intValue];
        if (Resultat<=0)
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
        if(Resultat==PlaqueIni[i])
        {
            
            [_tvResultat setAttributedText:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"Solution in the original 6 numbers : %ld \n",Resultat] attributes:_attributeSubText]];
            
            printf("Solution in the original 6 numbers : %ld \n",Resultat);
            return;
        }
    }
    
    for(i=0;i<6;i++)  // initialise plaque[][]
        Plaque[0][i]=PlaqueIni[i];
    MeilleurEcart=LONG_MAX; //ecart maximal
    MeilleurNombrePlaques=INT_MAX;
    
    NombreAppelCompte=0;
    
    Solutions=0;
    
    for(NombrePlaques=6;NombrePlaques>=2;NombrePlaques--)
    {
        for(Config=0;Config<NombreConfigs[NombrePlaques];Config++)
        {
            [self compte:0 pP:6];
        }
    }
    
    if(MeilleurEcart>0)
    {
        
        [_tvResultat setAttributedText:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"Closest Solution \n"] attributes:_attributeSubText]];
        
        printf("Closest solution :\n");
        [self AfficheSolution:(MeilleurNombrePlaques-1)];
    }
    
    printf("\n");
    printf("N solutions : %lu\n",Solutions);
    printf("min ecart : %lu\n",MeilleurEcart);
    printf("N appels √† la fonction rÇcursive : %lu \n",NombreAppelCompte);
    
    
    NSMutableAttributedString *historyText = [[NSMutableAttributedString alloc] initWithAttributedString:_tvResultat.attributedText];
    NSString *stats = [[NSString alloc]initWithFormat:@"\n N solutions : %lu \n min delta : %lu \n N recursive function calls : %lu \n",Solutions,MeilleurEcart,NombreAppelCompte];
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
