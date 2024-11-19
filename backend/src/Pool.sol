// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title Pool
/// @author Antek Mnm

import "@openzeppelin/contracts/access/Ownable.sol";

error CollectIsFinished();
error GoalAlreadyReached();
error CollectNotFinished();
error FailedToSendEther();
error NoContribution();
error NotEnoughFounds();

contract Pool is Ownable {
    uint256 public end;
    uint256 public goal;
    uint256 public totalCollected;
    //on pourra savoir quelle addresse a donnée et combien
    mapping(address => uint256) public contributions;
    //on va emmetre un évenement quand une personne a donnée une contribution, indexed comme en sql permet de rechercher plus facilement dans les contributeurs
    event Contribute(address indexed contributor, uint256 amount);
    
    constructor(uint256 _duration, uint256 _goal)
    Ownable(msg.sender){
        //on paramètre la date de fin de la cagnotte
        end = block.timestamp + _duration;
        goal = _goal;
    }

    /// @notice Allows to contribute to the Pool
    function contribute() external payable {
        if(block.timestamp >= end) {
            revert CollectIsFinished();
        }
        if(msg.value == 0){
            revert NotEnoughFounds();
        }

        contributions[msg.sender] += msg.value;
        totalCollected += msg.value;

        emit Contribute(msg.sender, msg.value);
    }

    /// @notice Allows the owner to withdraw the gain to the pool
    function withdraw() external onlyOwner{
        if(block.timestamp < end || totalCollected < goal) {
            revert CollectNotFinished();
        }
        //rappatrie l'argent de l'address du contrat, sent va représenter est-ce que le virement de la cagnotte a fonctionné ou pas
        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        if(!sent){
            revert FailedToSendEther();
        }
    }

    /// @notice allows the user to get his money back
    function refund() external {
        if(block.timestamp < end) {
            revert CollectNotFinished();
        }
        if(totalCollected >= goal) {
            revert GoalAlreadyReached();
        }
        if(contributions[msg.sender] == 0){
            revert NoContribution();
        }

        uint256 amount = contributions[msg.sender];
        contributions[msg.sender] = 0;

        totalCollected -= amount;
        //on lui envoi le montant
        (bool sent,) = msg.sender.call{value: amount}("");
        if(!sent){
            revert FailedToSendEther();
        }
    }
}