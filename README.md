# bsc

## Prequisites
Terraform
Helm
AzureCli

Login to azure cli

## Infrastructure

1. Run the script in iac/scripts/make-container.sh
2. In the iac folder
    1. Run terraform init
    2. Run terraform apply and agree
3. When it is finished, make sure to run the following

`az aks get-credentials --resource-group rg-3fd118jc --name aks-weu-tst-aks`

## HELM

1. Go in the charts folder
2. In the values.yaml file make sure init_genesis: true is enabled
3. Run helm install bsc ./bsc
4. Disable init_genesis: true for the future

