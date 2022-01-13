bin/bash
#the scripts to build tenant for customer from init.json

sum_run=0
sum_crash=0
sum=0
declare -a vodis=("ingestimages" "vodisconfig" "vodistracker" "vodingestsystem-vodpublisher" "vodpackagerouter" "vodorchestrator")
#declare -a vodis=("ingestimages" "vodisconfig")
# ~~~~~ run over group ~~~~~~~~~~~~~~~~

declare -A componentMap
for i in "${vodis[@]}"
do
    declare -A newmap
    echo $i
    component_list=$(kubectl get pods | grep $i )
    echo "$component_list"
    sum_runing=$(kubectl get pods | grep $i | grep Running | wc -l)
    newmap[runing]=$sum_runing
    sum_run=$((sum_run + $sum_runing))
    crash=$(kubectl get pods | grep $i | grep CrashLoopBackOff | wc -l)
    newmap[crash]=$crash
    sum_crash=$((sum_crash + $crash))
    echo "the sum of $i crash " $crash
    percent=0
    if [$sum_runing != 0]
    then
      percent=$(($crash / $sum_runing))
    fi
    newmap[percent]=$percent
    componentMap[$i]=${newmap[@]}
done

#~~~~~ sumerize ~~~~~~~

for comp in "${vodis[@]}"
do
    status=0
    echo "--- key" $comp
    echo "--- value " ${componentMap[$comp]}
    #echo " --prac" $(((jq -r ".${componentMap[$comp][0]}") / (jq -r ".${componentMap[$comp][1]}") ))
    SUBSTRING1=$(echo ${componentMap[$comp]}| cut -d' ' -f 2)
    echo "--crash-"  $SUBSTRING1
    SUBSTRING2=$(echo ${componentMap[$comp]}| cut -d' ' -f 3)
    echo "--run-" $SUBSTRING2
    percentComp=$(echo ${componentMap[$comp]}| cut -d' ' -f 1)
    echo "--percent -- " $percentComp
    sumPer=$(($percentComp * 100))
    echo "sumPer --" $sumPer
    case $sumPer in
       [0:100]) status=0
       ;;
       [101:120]) status=1
       ;;
       *) status=2
    esac
    echo "status of percent --" $status
    # write in the file status of components
done


echo "-----------DONE ---------------"
echo " sum crash is " $sum_crash
echo " sum run is " $sum_run

status_vod=0
case $sum_crash in
   0) status_vod=0
   ;;
   [1:2]) status_vod=1
   ;;
   *) status_vod=2
   ;;
esac

echo "---------אthe status " $status_vod

cat >|  monitoring_status.txt <<EOF
COMPONENT VODOIS status:$sum_crash crash:$sum_crash run:$sum_run
COMPONENT OPSHUB status:0 crash:0 run:12
TOTAL status:0 crash:$sum_crash run:21
EOF
