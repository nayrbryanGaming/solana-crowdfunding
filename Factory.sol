// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. Child contract yang menyimpan nilai uint
contract Child {
    uint public value;

    constructor(uint _value) {
        value = _value;
    }
}

// 2. Factory contract untuk mendeploy instance Child baru
contract Factory {
    // Array untuk melacak Child yang telah dideploy
    Child[] public deployedChildren;

    // Fungsi untuk mendeploy Child baru dengan nilai tertentu
    function createChild(uint _value) public {
        Child newChild = new Child(_value);
        deployedChildren.push(newChild);
    }

    // Fungsi untuk mengembalikan jumlah Child yang telah dideploy
    function getChildCount() public view returns (uint) {
        return deployedChildren.length;
    }
}
