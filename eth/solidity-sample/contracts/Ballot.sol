// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;


/// @title Voting with delegation
contract Ballot {
    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }

    struct Proposal {
        bytes32 name;
        uint256 voteCount;
    }

    address public chairPerson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) public {
        chairPerson = msg.sender;
        voters[chairPerson].weight = 1;
        for (uint8 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairPerson,
            "Only chair person can give right to vote."
        );
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "The voter's weight must be 0.");
        voters[voter].weight = 1;
    }

    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted");
        require(to != msg.sender, "Self-delegate is disallowed.");

        // 有Bug
        address tempTo = to;
        while (voters[tempTo].delegate != address(0)) {
            tempTo = voters[tempTo].delegate;
            require(tempTo != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = tempTo;
        Voter storage _delegate = voters[to];
        if (_delegate.voted) {
            proposals[_delegate.vote].voteCount += sender.weight;
        } else {
            _delegate.weight += sender.weight;
        }
    }

    function vote(uint256 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint256 _winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                _winningProposal = p;
            }
        }
    }

    function winnerName() public view returns (bytes32 _winnerName){
        _winnerName = proposals[winningProposal()].name;
    }
}
