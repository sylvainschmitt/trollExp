# ToDo

* Search the origin of the segfault in
`snakemake -j 1 results/simulations/current/10-years/guyaflux/warmup/R1`
at iteration 22
using rcontroll-V4 test & VSCode with associated data


## DEBUG

Warning in Photosyn ! GSDIVA=-nan; DS=3.74281; CS=400.00000
In Photosyn: PPFD=19.73577; TLEAF=23.71643; CS=400.00000; DS=3.74281
Warning in Photosyn: , Anet= -nan, GSDIVA=-nan; Anet*GSDIVA=-nan, AC= -nan, AJ= nan, Rday=0.29582, CS=400.00000; CIC=-nan; CIJ=nan, DS= 3.74281, TLEAF= 23.71643, t_WSF_A=-nan, t_WSF= -nan; GammaT=35.49939; KmT=691.93195; J=nan; PPFD=19.73577; T_Rdark=0.81152; convT=237
Warning in Photosyn: , Anet= -nan, AC= -nan, AJ= nan, Rday=0.29582, GSDIVA=-nan, CS=400.00000; CIC=-nan; CIJ=nan, DS= 3.74281, TLEAF= 23.71643, t_WSF_A=-nan, t_WSF= -nan; GammaT=35.49939; KmT=691.93195; J=nan; PPFD=19.73577; t_Rdark=0.81152; convT=237
Warning in FluxesLeaf:  ALEAF= -nan, GSC= -nan, CS= 400.00000, PPFD=19.73577, DS= 3.74281, TLEAF= 23.71643, ITER=0
Warning in FluxesLeaf:  GV= -nan, GSC= -nan, GBV= 0.29664, GSV=-nan, GSC=-nan, ALEAF=-nan, GSVGSC= 1.57000, ALEAF=-nan, PPFD=19.73577, DS=3.74281, ITER=0, WIND=0.33672
Warning in FluxesLeaf:  ALEAF= -nan, ET= 0.00000, CS= -nan, PPFD=19.73577, DS= -nan, TLEAF= 23.12340, GSV=-nan, GV= -nan, Rnetsiso=-65.03493; lambdaET=0.00000; HDIVT=27.41632; TDIFF=-2.37212; Ta=23.71643; Cair=400.00000; GBH=0.27595; Cair=400.00000; GBHGBC=1.32000; t_site=419; t_sp_lab=91; ITER=0

s_wsg = 0.605
t_g1_0= (-3.97 * t_wsg + 6.53)
GSDIVA = (1.0 + t_g1/sqrt(DS))/CS

-3.97*0.605+6.53

(1+4.12/sqrt(3.74))/400

Reading in file: /home/sschmitt/Documents/trollExp/results/simulations/current/10-years/guyaflux/warmup/R1/R1_input_daily.txt
Warning, VPD is <=0, on day 840 at 7h.

SIGMA 5.67e-8 
ema=1/(SIGMA*pow(temper-ABSZERO,4.0))*(59.38 + (113.7*pow((ABSZERO-temper)/ABSZERO, 6)) + 96.96*sqrt(186*vpd/(temper-ABSZERO)))
INLR=(1-ema)*SIGMA*pow(temper-ABSZERO,4.0)
          
