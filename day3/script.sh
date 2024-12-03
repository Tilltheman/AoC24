#!/bin/bash

input=$1

sum=0
for result in $(grep -Po 'mul\(\d+,\d+\)' "$input" ); do
    temp=$(echo $result | grep -Po '\d+' | awk -v mul=1 '
{
    mul*=$1;
};
END {print mul;}')
sum=$(($sum+$temp))
done
echo $sum
