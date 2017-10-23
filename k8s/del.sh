 for i in `az container  list -g 'Demo-k8s' --query [].name | sed 's/,//g' | sed 's/\"//g'`
 do
     echo $i
     az container delete --name $i  -g 'Demo-k8s' --yes  --verbose
 done