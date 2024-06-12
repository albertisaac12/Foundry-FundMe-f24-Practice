-include .env

build:; forge build

deployandVerify:
	forge script  script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEP_API) --private-key $(PVT_KEY) --broadcast --verify --etherscan-api-key $(ETHER_SCAN) -vvvv