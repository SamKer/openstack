#openstack

#additionnal parameters
params=
# get list clouds (if multiple cloud access in clouds.yaml)
listClouds=$(cat ~/.config/openstack/clouds.yaml  | yq .clouds -j | jq -r '.|keys[]')
# default cloud conf
defaultconf=$(cat ~/.config/openstack/default-tenant)
# if old
oldconf=$OS_CLOUD

# test si le cloud sécifié existe
for c in $listClouds
do
	if [ $1 == $c ]
	then
		conf=$c
		shift
	fi
done

# si pas de conf, alors on prend celui déjà chargé 
if [[ !$conf ]] && [[ $oldconf ]]
then
	echo "no conf specified, taking the old $oldconf"
	conf=$oldconf
fi
# si non plus alors celui par default
if [ ! $conf ]
then 
	echo "no conf specified, taking default $defaultconf"
	conf=$defaultconf
fi
echo "OS_CLOUD: $conf"

# command 
command=$1



echo "Switching conf $oldconf to $conf"

## used by openstack cinder paker..
export OS_CLOUD=$conf
export OS_AUTH_URL=$(cat ~/.config/openstack/clouds.yaml  | yq .clouds.$OS_CLOUD.auth.auth_url | tr -d '"')
export OS_USERNAME=$(cat ~/.config/openstack/clouds.yaml  | yq .clouds.$OS_CLOUD.auth.username | tr -d '"')
export OS_PASSWORD=$(cat ~/.config/openstack/clouds.yaml  | yq .clouds.$OS_CLOUD.auth.password | tr -d '"')
export OS_USER_DOMAIN_NAME=$(cat ~/.config/openstack/clouds.yaml  | yq .clouds.$OS_CLOUD.auth.user_domain_name | tr -d '"')
export OS_DOMAIN_NAME=$(cat ~/.config/openstack/clouds.yaml  | yq .clouds.$OS_CLOUD.auth.user_domain_name | tr -d '"')
export OS_TENANT_NAME=$(cat ~/.config/openstack/clouds.yaml  | yq .clouds.$OS_CLOUD.auth.project_name | tr -d '"')
export OS_PROJECT_DOMAIN_NAME=$(cat ~/.config/openstack/clouds.yaml  | yq .clouds.$OS_CLOUD.auth.user_domain_name | tr -d '"')


#special paker
export CHECKPOINT_DISABLE=1
export PACKER_LOG=1
export PACKER_LOG_PATH=error.log

#special cinder
#if [ $command == "cinder" ]
#then
#	params=" --insecure"
#fi



echo "running $1 command"
$@ $params
