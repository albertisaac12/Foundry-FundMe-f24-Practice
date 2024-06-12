//1.Deploy mocks when we are on a local anvil chain
//2. Keep track of contract address across the diffrent chains
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol" ;
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
contract HelperConfig is Script{

    NetworkConfig public activeNetworkConfig;
    struct NetworkConfig{
        address priceFeed; //ETH/USD price feed address
    }
    
    uint8 public constant Decimals =8;
    int256 public constant INITIAL_PRICE = 2000e8;


    constructor(){
        if(block.chainid==11155111){
            activeNetworkConfig=getSepoliaEthConfig();
        }else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }


    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        //1. Deploy the mocks
        //2. Return the mock address
        if(activeNetworkConfig.priceFeed!=address(0)){
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(Decimals,INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed:address(mockPriceFeed)});

        return anvilConfig;

    }
}