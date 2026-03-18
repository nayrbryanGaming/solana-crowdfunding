// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureVault {
    // 1. Owner functionality
    address public owner;

    // 2. Authorization system for users
    mapping(address => bool) public authorized;

    // 3. Pausable functionality
    bool public paused;

    // 4. Balance tracking
    mapping(address => uint) public balances;

    // 5. Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Not authorized");
        _;
    }

    // 6. Constructor: sets owner and authorizes owner
    constructor() {
        owner = msg.sender;
        authorized[msg.sender] = true;
        paused = false;
    }

    // 7. authorize(address) function (owner only)
    function authorize(address account) public onlyOwner {
        authorized[account] = true;
    }

    // 8. pause() function (owner only)
    function pause() public onlyOwner {
        paused = true;
    }

    // 9. unpause() function (owner only)
    function unpause() public onlyOwner {
        paused = false;
    }

    // 10. deposit(uint) function (authorized users only, when not paused)
    function deposit(uint amount) public onlyAuthorized whenNotPaused {
        balances[msg.sender] += amount;
    }

    // 11. getBalance() view function
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    // 12. isPaused() view function
    function isPaused() public view returns (bool) {
        return paused;
    }
}
