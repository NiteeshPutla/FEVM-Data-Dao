// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataDAO {

    address payable public storageCollector;
    uint public voteEndTime;
    uint public DAObalance;
    uint decision;
    bool ended;
    address public storagesetter;

    struct Voter {
        uint weight; 
        bool voted;  
        address delegate; 
        uint vote;   
    }

    struct Proposal {
        string name;   
        uint voteCount; 
    }
    Proposal[] public proposals;

    mapping(address=>uint) balances;
    mapping(address => Voter) public voters;

    constructor(
        address payable _storageCollector,
        uint _voteTime,
        string[] memory proposalNames
    ) {
        storageCollector = _storageCollector;
        storagesetter = msg.sender;
        
        voteEndTime = block.timestamp + _voteTime;
        voters[storagesetter].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {

            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
     function DepositEth() public payable {
        DAObalance = address(this).balance;
        
        if (block.timestamp > voteEndTime)
            revert ("voteAlreadyEnded");

         require(voteEndTime > block.timestamp, "");

            
        require(DAObalance <= 1 ether, "1 Ether balance has been reached");
        
        DAObalance = address(this).balance;
        balances[msg.sender]+=msg.value;
    }

      function giveRightToVote(address voter) public {

        require(
            msg.sender == storagesetter,
            "Only owner can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
      }

      function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

       function withdraw(uint amount) public{
        if(balances[msg.sender]>=amount){
        balances[msg.sender]-=amount;
        payable(msg.sender).transfer(amount);
        DAObalance = address(this).balance;
        }
    }

    function EndVote() public {
        require(
            block.timestamp > voteEndTime,
            "Vote not yet ended.");
          
        require(
            ended == true,
            "Must count vote first");  
            
        require(
            DAObalance >= 1 ether,
            "Not enough balance in DAO required to stake. Members may withdraw deposited ether.");
            
        require(
            decision == 0,
            "DAO cannot buy stakes. Members may withdraw deposited ether.");
            
            
        if (DAObalance  < 1 ether) revert();
            (bool success, ) = address(storageCollector).call{value: 1 ether}(abi.encodeWithSignature("purchase(uint256)", 1));
            require(success);
            
        DAObalance = address(this).balance;
  
        }

}