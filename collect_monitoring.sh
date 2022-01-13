#!/bin/bash
# run for every deployer

deployer_setup_path="/root/deployer_setup" #todo - if will change
monitoring_files_path="monitoring_files"

#secret_manager=$(find .. -name secret_manager.sh)
#source $secret_manager

if [ -d "./monitoring_files" ]; then
    rm -r ./monitoring_files
fi
mkdir -m 777 ./monitoring_files

#___________collect the files from deployers ___________

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!! why ssh -i /root/deployer_setup/brooklyn-wip.pem centos@176.34.243.190 not work - need to change again to wip
#get list of deployers
NAMES=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=deployer-vpc-brooklyn-wip1*" | jq -r ".Reservations[].Instances[0].KeyName")

for custumers in $NAMES
do
  customer=$(echo $custumers | cut -d'-' -f 2)

  #get state
  state=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=deployer-vpc-$custumers-main" | jq -r ".Reservations[].Instances[0].State.Name")
  #~~~~ only if the state running do the logic ~~~~
  if [ $state == "running" ]

  then
    #get private key
    key_name="brooklyn-$customer"

    #get deployer ip
    DEPLOYER_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=deployer-vpc-brooklyn-$customer-main" | jq -r ".Reservations[-1].Instances[0].PublicIpAddress")
    echo "key_name.pem"  $key_name.pem "DEPLOYER_IP" $DEPLOYER_IP

    #copy file
    scp -r -i $deployer_setup_path/$key_name.pem centos@$DEPLOYER_IP:/tmp/monitoring/monitoring_status.txt ./monitoring_files/monitoring_$customer.txt
  fi
done

#_________ anlyze the all infornation_______
#call to python script
json=$(python -c'import create_payloud; create_payloud.createPayloud()')

#________send curl________
AUTH_TOKEN_RESPONSE=$(curl -X POST \
  -H 'Accept: application/json' \
  -H 'X-API-KEY: 38cae46167789f34f4ee4cbbe5ace1f8' \
  -H 'Content-Type: application/json' \
  -d "${json}" \
  https://vdqylwu498.execute-api.eu-west-1.amazonaws.com/dev/health)

echo "res from SRE portal " $AUTH_TOKEN_RESPONSE


#_____________clean the files______________

#echo "cleanup local created files"
#rm -f "$deployer_setup_path/$key_name.pem"
#rm -f ""
