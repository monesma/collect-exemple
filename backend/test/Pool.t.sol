// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "forge-std/Test.sol";
import { Pool } from "../src/Pool.sol";

contract PoolTest is Test {
    //créer une fake address owner et 3 autres
    address owner = makeAddr("User0");
    address addr1 = makeAddr("User1");
    address addr2 = makeAddr("User2");
    address addr3 = makeAddr("User3");
    //le nombre de secondes pour 4 semaines
    uint256 duration = 4 weeks; //timestamp 4 * 7 * 24 * 3600
    uint256 goal = 10 ether;

    Pool pool;
    //avec chaque test (IMPORTANT) on redeploy
    function setUp() public {
        //le prochain call va être exécuté par le owner
        vm.prank(owner);
        pool = new Pool(duration, goal);
    }

    //test 1
    function test_ContractDeployedSuccessfully() public {
        //owner vient de Ownable (heritage) recup l'address du propriétaire
        address _owner = pool.owner();
        //il faut que les address soient identiques
        assertEq(owner, _owner);
        //la fonction getter a été crée automatiquement via solidity
        uint256 _end = pool.end();
        assertEq(block.timestamp + duration, _end);
        //idem pour goal
        uint256 _goal = pool.goal();
        assertEq(goal, _goal);
    }
    //test 2
    function test_RevertWhen_EndIsReached() public {
        //va le temps timestamp de fin + 1h
        vm.warp(pool.end() + 3600);
        //on recup le selecteur de l'erreur hash du nom en 8 charactère => signature
        bytes4 selector = bytes4(keccak256("CollectIsFinished()"));
        //on test l'erreur
        vm.expectRevert(abi.encodeWithSelector(selector));
        vm.prank(addr1);
        //pour pouvoir test l'envoi d'argent on doit attribuer de l'argent addr1
        vm.deal(addr1, 1 ether);
        pool.contribute{value: 1 ether}();
    }
    //test 3
    function test_RevertWhen_NotEnoughFunds() public {
        bytes4 selector = bytes4(keccak256("NotEnoughFounds()"));
        //on test l'erreur
        vm.expectRevert(abi.encodeWithSelector(selector));
        
        vm.prank(addr1);
        //si je n'envoi pas d'argent = erreur
        pool.contribute();
    }
    //test 4
    function test_ExpectEmitSuccessfullContribute(uint96 _amount) public {
        //fuzzing: renseigner des valeurs aléatoires aux test (impossible avec hardhat seulement foundry)
        //96 foundry gère jusqu'a 96 a partir du moment ou on le met pas besoin de lui déclarer un paramètre il va le faire auto aléatoire
        vm.assume(_amount > 0);
        //3 premiers designe les topics on en a qu'un événement ici, le dernier désigne l'amount ici
        vm.expectEmit(true, false, false, true);
        emit Pool.Contribute(address(addr1), _amount);

        vm.prank(addr1);
        vm.deal(addr1, _amount);
        pool.contribute{value: _amount}();
    }

    //test 5
    function test_RevertWhen_NotTheOwner() public {
        bytes4 selector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        //on test l'erreur
        vm.expectRevert(abi.encodeWithSelector(selector, addr1));
        vm.prank(addr1);
        pool.withdraw();
    }

    //test 6
    function test_RevertWhen_EndIsNotReached() public {
        bytes4 selector = bytes4(keccak256("CollectNotFinished()"));
        //on test l'erreur
        vm.expectRevert(abi.encodeWithSelector(selector));
        
        vm.prank(owner);
        pool.withdraw();
    }

    //test 7
    function test_RevertWhen_GoalIsNotReached() public {
        
        vm.prank(addr1);
        vm.deal(addr1, 5 ether);
        pool.contribute{value: 5 ether}();

        //va le temps timestamp de fin + 1h
        vm.warp(pool.end() + 3600);
        bytes4 selector = bytes4(keccak256("CollectNotFinished()"));
        //on test l'erreur
        vm.expectRevert(abi.encodeWithSelector(selector));

        vm.prank(owner);
        pool.withdraw();
    }

    //test 8 
    function test_RevertWhen_WithdrawFailedToSendEther() public {
        //le contrat intelligent PoolTest va devenir proprio de Pool (lorsqu'on test dans une fonction)
        pool = new Pool(duration, goal);
        //pas de receive ni fallback => crash
        vm.prank(addr1);
        vm.deal(addr1, 6 ether);
        pool.contribute{value: 6 ether}();

        vm.prank(addr2);
        vm.deal(addr2, 7 ether);
        pool.contribute{value: 7 ether}();

        vm.warp(pool.end() + 3600);

        bytes4 selector = bytes4(keccak256("FailedToSendEther()"));
        //on test l'erreur
        vm.expectRevert(abi.encodeWithSelector(selector));

        pool.withdraw();
    }

    //test 9
    function test_withdraw() public {
        vm.prank(addr1);
        vm.deal(addr1, 6 ether);
        pool.contribute{value: 6 ether}();

        vm.prank(addr2);
        vm.deal(addr2, 7 ether);
        pool.contribute{value: 7 ether}();

        vm.warp(pool.end() + 3600);

        vm.prank(owner);
        pool.withdraw();
    }

    //test 10
    function test_RevertWhen_CollectNotFinished() public {
        vm.prank(addr1);
        vm.deal(addr1, 5 ether);
        pool.contribute{value: 5 ether}();

        vm.prank(addr2);
        vm.deal(addr2, 3 ether);
        pool.contribute{value: 3 ether}();

        bytes4 selector = bytes4(keccak256("CollectNotFinished()"));
        vm.expectRevert(abi.encodeWithSelector(selector));

        vm.prank(addr1);
        pool.refund();
    }

    //test 11
    function test_RevertWhen_GoalAlreadyReached() public {
        vm.prank(addr1);
        vm.deal(addr1, 6 ether);
        pool.contribute{value: 6 ether}();

        vm.prank(addr2);
        vm.deal(addr2, 7 ether);
        pool.contribute{value: 7 ether}();

        vm.warp(pool.end() + 3600);
        
        bytes4 selector = bytes4(keccak256("GoalAlreadyReached()"));
        vm.expectRevert(abi.encodeWithSelector(selector));
        pool.refund();
    }

    //test12
    function test_RevertWhen_NoContribution() public {
        vm.prank(addr1);
        vm.deal(addr1, 6 ether);
        pool.contribute{value: 6 ether}();

        vm.prank(addr2);
        vm.deal(addr2, 1 ether);
        pool.contribute{value: 1 ether}();
        
        vm.warp(pool.end() + 3600);

        bytes4 selector = bytes4(keccak256("NoContribution()"));
        vm.expectRevert(abi.encodeWithSelector(selector));
        vm.prank(addr3);
        pool.refund();
    }

    //test13
    function test_RevertWhen_RefundFailedToSendEther() public {
        pool = new Pool(duration, goal);

        vm.deal(address(pool), 2 ether);
        pool.contribute{value: 2 ether}();

        vm.prank(addr1);
        vm.deal(addr1, 6 ether);
        pool.contribute{value: 6 ether}();

        vm.prank(addr2);
        vm.deal(addr2, 1 ether);
        pool.contribute{value: 1 ether}();

        vm.warp(pool.end() + 3600);

        bytes4 selector = bytes4(keccak256("FailedToSendEther()"));
        vm.expectRevert(abi.encodeWithSelector(selector));

        pool.refund();
    }

    //test 14
    function test_refund() public {
        vm.prank(addr1);
        vm.deal(addr1, 6 ether);
        pool.contribute{value: 6 ether}();

        vm.prank(addr2);
        vm.deal(addr2, 1 ether);
        pool.contribute{value: 1 ether}();
        
        vm.warp(pool.end() + 3600);

        uint256 balanceBeforeRefund = addr2.balance;

        vm.prank(addr2);
        pool.refund();

        uint256 balanceAfterRefund = addr2.balance;

        assertEq(balanceBeforeRefund + 1 ether, balanceAfterRefund);
    }

}