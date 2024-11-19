// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Script.sol";
import { Pool } from '../src/Pool.sol';

contract MyScript is Script {
    function run() external {
        //je récup la clé privé du premier compte généré par la commande anvil dans le terminal et stocké dans ma variable d'env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        uint256 end = 4 weeks;
        uint256 goal = 10 ether;
        Pool pool = new Pool(end, goal);
        vm.stopBroadcast();
        //forge script script/Deploy.s.sol:MyScript --fork-url http://127.0.0.1:8545 --broadcast
    }
}