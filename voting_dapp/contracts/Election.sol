// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Election {
    // Model a Candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    // Store accounts that have voted
    mapping(address => bool) public voters;
    address[] voterAddresses;

    // Store Candidates
    // Fetch Candidate
    mapping(uint256 => Candidate) public candidates;

    // Store Candidates Count
    uint256 public candidatesCount;

    // voted event
    event votedEvent(uint256 indexed candidateId);

    // reset event
    event resetEvent();

    constructor() {
        addCandidate("Donald Trump");
        addCandidate("Joe Biden");
    }

    function addCandidate(string memory name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, name, 0);
    }

    function vote(uint256 candidateId) public {
        // require that they haven't voted before
        require(!voters[msg.sender]);

        // require a valid candidate
        require(candidateId > 0 && candidateId <= candidatesCount);

        // record that voter has voted
        voters[msg.sender] = true;

        // update candidate vote Count
        candidates[candidateId].voteCount++;
        voterAddresses.push(msg.sender);

        // trigger voted event
        emit votedEvent(candidateId);
    }

    function resetVotes() public {
        for (uint256 index = 1; index <= candidatesCount; index++) {
            candidates[index].voteCount = 0;
        }

        for (uint256 index = 0; index < voterAddresses.length; index++) {
            delete voters[voterAddresses[index]];
        }

        delete voterAddresses;

        emit resetEvent();
    }
}
