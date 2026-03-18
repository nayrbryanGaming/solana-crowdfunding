// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // 1. Struct Proposal
    struct Proposal {
        string description;
        uint voteCount;
    }

    // 2. Dynamic array of Proposal structs
    Proposal[] public proposals;

    // 3. Mapping to track if an address has voted (voter => hasVoted)
    mapping(address => bool) public hasVoted;

    // 4. Function to add a new proposal
    function addProposal(string memory desc) public {
        proposals.push(Proposal(desc, 0));
    }

    // 5. Function to vote for a proposal (only once per address)
    function vote(uint proposalIndex) public {
        require(!hasVoted[msg.sender], "Address has already voted");
        require(proposalIndex < proposals.length, "Invalid proposal index");

        proposals[proposalIndex].voteCount += 1;
        hasVoted[msg.sender] = true;
    }

    // 6. Function to get the vote count of a proposal
    function getVotes(uint proposalIndex) public view returns (uint) {
        require(proposalIndex < proposals.length, "Invalid proposal index");
        return proposals[proposalIndex].voteCount;
    }

    // 7. Function to get the total number of proposals
    function getProposalCount() public view returns (uint) {
        return proposals.length;
    }
}
