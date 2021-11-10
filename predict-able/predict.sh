#!/bin/sh
# shebang can be changed to specify either bash, zsh or ksh

# The actual updating of neuralnetweights.csv is disabled, for demo purposes

# origin of this script -thanks to Justin Staines for showing the way
# https://github.com/justinstaines/neuralnetwork

input1=0.1
input2=0.1
target=1
e=2.718281828459045235360287471352

#weight1=0.8
weight1=( $(cut -d ',' -f1 neuralnetweights.csv ) )
weight2=( $(cut -d ',' -f2 neuralnetweights.csv ) )
weight3=( $(cut -d ',' -f3 neuralnetweights.csv ) )
weight4=( $(cut -d ',' -f4 neuralnetweights.csv ) )
weight5=( $(cut -d ',' -f5 neuralnetweights.csv ) )
weight6=( $(cut -d ',' -f6 neuralnetweights.csv ) )
weight7=( $(cut -d ',' -f7 neuralnetweights.csv ) )
weight8=( $(cut -d ',' -f8 neuralnetweights.csv ) )
weight9=( $(cut -d ',' -f9 neuralnetweights.csv ) )

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
((loop+=1))
hidden1=`echo "($weight1 * $input1) + ($input2 * $weight4)" | bc`
hidden2=`echo "($weight2 * $input1) + ($input2 * $weight5)" | bc`
hidden3=`echo "($weight3 * $input1) + ($input2 * $weight6)" | bc`
#echo hidden1=$hidden1
hiddensum1=`echo - | awk -v var1="$e" -v  var2="$hidden1" '{print (1/(1+(var1 ^ -var2)))}'`
hiddensum2=`echo - | awk -v var1="$e" -v  var2="$hidden2" '{print (1/(1+(var1 ^ -var2)))}'`
hiddensum3=`echo - | awk -v var1="$e" -v  var2="$hidden3" '{print (1/(1+(var1 ^ -var2)))}'`
#echo hiddensum1=$hiddensum1
#weight7=0.3
#weight8=0.5
#weight9=0.9
output1=`echo "($hiddensum1 * $weight7)" | bc`
output2=`echo "($hiddensum2 * $weight8)" | bc`
output3=`echo "($hiddensum3 * $weight9)" | bc`
outputsum=`echo "($output1 + $output2 + $output3)" | bc`
targetcalc=`echo - | awk -v var1="$e" -v  var2="$outputsum" '{print (1/(1+(var1 ^ -var2)))}'`
#echo targetcalc=$targetcalc
sumerror=`echo "($target - $targetcalc)" | bc`
deltaoutput=`echo "(($targetcalc * (1 - $targetcalc)) * $sumerror)" | bc`
deltaweight1=`echo "scale=8; ($deltaoutput / $hiddensum1)" | bc`
deltaweight2=`echo "scale=8; ($deltaoutput / $hiddensum2)" | bc`
deltaweight3=`echo "scale=8; ($deltaoutput / $hiddensum3)" | bc`
newweight7=`echo "($weight7 + $deltaweight1)" | bc`
newweight8=`echo "($weight8 + $deltaweight2)" | bc`
newweight9=`echo "($weight9 + $deltaweight3)" | bc`
deltahiddensum1=`echo "$hiddensum1 * (1-$hiddensum1)" | bc`
deltahiddensum2=`echo "$hiddensum2 * (1-$hiddensum2)" | bc`
deltahiddensum3=`echo "$hiddensum3 * (1-$hiddensum3)" | bc`
newhiddensum1=`echo "scale=8; (($deltaoutput / $weight7) * $deltahiddensum1)" | bc` 
newhiddensum2=`echo "scale=8; (($deltaoutput / $weight8) * $deltahiddensum2)" | bc`
newhiddensum3=`echo "scale=8; (($deltaoutput / $weight9) * $deltahiddensum3)" | bc`
deltaweightin1=`echo "scale=8; ($newhiddensum1 / $input1)" | bc`
deltaweightin2=`echo "scale=8; ($newhiddensum2 / $input1)" | bc`
deltaweightin3=`echo "scale=8; ($newhiddensum3 / $input1)" | bc`
deltaweightin4=`echo "scale=8; ($newhiddensum1 / $input2)" | bc`
deltaweightin5=`echo "scale=8; ($newhiddensum2 / $input2)" | bc`
deltaweightin6=`echo "scale=8; ($newhiddensum3 / $input2)" | bc`
newweight1=`echo "scale=8; ($weight1 + $deltaweightin1)" | bc`
newweight2=`echo "scale=8; ($weight2 + $deltaweightin2)" | bc`
newweight3=`echo "scale=8; ($weight3 + $deltaweightin3)" | bc`
newweight4=`echo "scale=8; ($weight4 + $deltaweightin4)" | bc`
newweight5=`echo "scale=8; ($weight5 + $deltaweightin5)" | bc`
newweight6=`echo "scale=8; ($weight6 + $deltaweightin6)" | bc`

weight1=`echo "($newweight1)" | bc`
weight2=`echo "($newweight2)" | bc`
weight3=`echo "($newweight3)" | bc`
weight4=`echo "($newweight4)" | bc`
weight5=`echo "($newweight5)" | bc`
weight6=`echo "($newweight6)" | bc`
weight7=`echo "($newweight7)" | bc`
weight8=`echo "($newweight8)" | bc`
weight9=`echo "($newweight9)" | bc`
#echo $targetcalc
(echo -e "\033[0m";echo $newweight1,$newweight2,$newweight3,$newweight4,$newweight5,$newweight6,$newweight7,$newweight8,$newweight9;echo -e "\033[33;0;7m";echo $targetcalc;echo -e "\033[0m") | tr '\n' '\t'
echo \ 
#echo $targetcalc

done

exit

echo -n "" > neuralnetweights.csv
echo -n $newweight1,$newweight2,$newweight3,$newweight4,$newweight5,$newweight6,$newweight7,$newweight8,$newweight9 > neuralnetweights.csv
echo $newweight1,$newweight2,$newweight3,$newweight4,$newweight5,$newweight6,$newweight7,$newweight8,$newweight9
