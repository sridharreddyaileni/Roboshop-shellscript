#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-00ac01ec9a8c43ec9
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
# ZONE_ID=copy paste from route53 if records available
# DOMAIN_NAME="copy paste from route53 if records available"

for i in "${INSTANCES[@]}"
do
    echo "instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ] 
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-00ac01ec9a8c43ec9 --tag-specifications "ResourceType=instance, Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    #create R53 record, make sure you delete exisiting records in route53
    # aws route53 change-resource-record-sets \
    # --hosted-zone-id $ZONE_ID \
    # --change-batch '
    # {
    #     "comment": "Creating a record set for cognito endpoint"
    #     ,"Changes": [{
    #     "Action"            :"CREATE"
    #     ,"ResourceRecordSet" : {
    #         "Name"              : "'$i'.'$DOMAIN_NAME'"
    #         ,"Type"             : "A"
    #         ,TTL"               :  1
    #         ,"ResourceRecords"  : [{
    #             "Value"         : "'$IP_ADDRESS'"
    #         }]
    #     }
    #     }]
    # }
done