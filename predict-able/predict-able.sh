#! /bin/sh
# shebang can be changed to specify any of these shells: bash, zsh, posh, dash and ksh

# The actual updating of neuralnetweights.ssv is disabled, for demo purposes

# adapted from original predict.sh from:
# https://github.com/justinstaines/neuralnetwork
# thanks to Justin Staines for showing the way

input1=0.1
input2=0.1
target=1
e=2.718281828459045235360287471352

source=1 . ./iq
# be sure to source the correct iq version, if named like below
#source=1 . ./iq_1.618033988.sh

# we use these three functions copied from iq4sh-ext_1.618.sh
sigmoid_tanh() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1 
    x_divided=$( mul -s$scale $x 0.5 )
    tanh_beta=$( tanh_pade -s$scale $x_divided )    # faster
    tanh_beta_plus_1=$( add $tanh_beta 1 )
    div -s$scale $tanh_beta_plus_1 / 2 $scale
} ## sigmoid
# We use a Pade approximation because tanh_real would be very slow
tanh_pade() { case $1 in -s*) thpscale=${1#-s*} ; shift ;; *) thpscale=$defprec ;;esac
    x=$1
    case $x in '-'*) tanh_neg='-' x=${x#*-} ;; *) tanh_neg= ;; esac
    x2=$( mul -s$thpscale $x $x )
    x4=$( mul -s$thpscale $x2 $x2 )
    x6=$( mul -s$thpscale $x4 $x2 )
    # nom
    a=$( mul -s$thpscale 1260 $x2 )
    b=$( mul -s$thpscale 21 $x4 )
    d=$( add 10395 + $a + $b  )
    e=$( mul -s$thpscale $x $d )
    # denom
    f=$( mul -s$thpscale 4725 $x2 )
    g=$( mul -s$thpscale 210 $x4 )
    j=$( add -s$thpscale  10395 + $f + $g + $x6 )
    
    r_tanh=$( div -s$thpscale $e / $j )
    echo $tanh_neg$r_tanh
} ## tanh_pade

#weight1=0.8

set -- $(  read REPLY <neuralnetweights.ssv ; echo $REPLY )
weight1=$1  weight2=$2 weight3=$3 
weight4=$4  weight5=$5 weight6=$6
weight7=$7  weight8=$8 weight9=$9

scale=10
#weight2=0.4
#weight3=0.3
#weight4=0.2
#weight5=0.9
#weight6=0.5
#weight7=0.3
#weight8=0.5
#weight9=0.9
#echo $weight1,$weight2,$weight3,$weight4,$weight5,$weight6,$weight7,$weight8,$weight9
loop=0
while [ $loop -lt 10 ]; do
loop=$((loop+1))
hidden1=$( add $(mul -s$scale $weight1 $input1) + $(mul -s$scale $input2 $weight4) )
hidden2=$( add $(mul -s$scale $weight2 $input1) + $(mul -s$scale $input2 $weight5) )
hidden3=$( add $(mul -s$scale $weight3 $input1) + $(mul -s$scale $input2 $weight6) )
#echo hidden1=$hidden1
hiddensum1=$( sigmoid_tanh -s7 $hidden1 )
hiddensum2=$( sigmoid_tanh -s7 $hidden2 )
hiddensum3=$( sigmoid_tanh -s7 $hidden3 )
#echo hiddensum1=$hiddensum1
#weight7=0.3
#weight8=0.5
#weight9=0.9

output1=$( mul -s$scale $hiddensum1 $weight7 )
output2=$( mul -s$scale $hiddensum2 $weight8 )
output3=$( mul -s$scale $hiddensum3 $weight9 )

outputsum=$( add $output1 + $output2 + $output3 )
targetcalc=$( sigmoid_tanh -s7 $outputsum)
#echo targetcalc=$targetcalc 
sumerror=$( add $target - $targetcalc )

deltaoutput=$( mul -s$scale  $sumerror  $(mul -s$scale $targetcalc $(add 1 - $targetcalc)  ) )

deltaweight1=$(div -s$scale $deltaoutput / $hiddensum1 )
deltaweight2=$(div -s$scale $deltaoutput / $hiddensum2 )
deltaweight3=$(div -s$scale $deltaoutput / $hiddensum3 )

newweight7=$(add $weight7 + $deltaweight1 )
newweight8=$(add $weight8 + $deltaweight2 )
newweight9=$(add $weight9 + $deltaweight3 )

deltahiddensum1=$(mul -s$scale  $hiddensum1 $(add 1 - $hiddensum1 ) )
deltahiddensum2=$(mul -s$scale  $hiddensum2 $(add 1 - $hiddensum2 ) )
deltahiddensum3=$(mul -s$scale  $hiddensum3 $(add 1 - $hiddensum3 ) )

newhiddensum1=$( mul -s$scale  $(div -s$scale $deltaoutput / $weight7) $deltahiddensum1 )
newhiddensum2=$( mul -s$scale  $(div -s$scale $deltaoutput / $weight8) $deltahiddensum2 )
newhiddensum3=$( mul -s$scale  $(div -s$scale $deltaoutput / $weight9) $deltahiddensum3 )

deltaweightin1=$(div -s$scale $newhiddensum1 / $input1 )
deltaweightin2=$(div -s$scale $newhiddensum2 / $input1 )
deltaweightin3=$(div -s$scale $newhiddensum3 / $input1 )
deltaweightin4=$(div -s$scale $newhiddensum1 / $input2 )
deltaweightin5=$(div -s$scale $newhiddensum2 / $input2 )
deltaweightin6=$(div -s$scale $newhiddensum3 / $input2 )

newweight1=$( add -s$scale $weight1 + $deltaweightin1 )
newweight2=$( add -s$scale $weight2 + $deltaweightin2 )
newweight3=$( add -s$scale $weight3 + $deltaweightin3 )
newweight4=$( add -s$scale $weight4 + $deltaweightin4 )
newweight5=$( add -s$scale $weight5 + $deltaweightin5 )
newweight6=$( add -s$scale $weight6 + $deltaweightin6 )

weight1=$newweight1
weight2=$newweight2
weight3=$newweight3
weight4=$newweight4
weight5=$newweight5
weight6=$newweight6
weight7=$newweight7
weight8=$newweight8

#echo $targetcalc
(echo -e "\033[0m";echo $newweight1,$newweight2,$newweight3,$newweight4,$newweight5,$newweight6,$newweight7,$newweight8,$newweight9;echo -e "\033[33;0;7m";echo $targetcalc;echo -e "\033[0m") | tr '\n' '\t'
echo \ 
#echo $targetcalc

done

exit

echo -n "" > neuralnetweights.csv
echo -n $newweight1 $newweight2 $newweight3 $newweight4 $newweight5 $newweight6 $newweight7 $newweight8 $newweight9 > neuralnetweights.ssv
echo $newweight1,$newweight2,$newweight3,$newweight4,$newweight5,$newweight6,$newweight7,$newweight8,$newweight9
