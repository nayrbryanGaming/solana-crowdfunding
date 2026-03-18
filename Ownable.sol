// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    // 1. Variabel public address owner
    address public owner;

    // 2. Modifier onlyOwner untuk membatasi akses
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // 3. Constructor untuk menyetel pemilik awal
    constructor() {
        owner = msg.sender;
    }

    // 4. Fungsi untuk mengecek apakah pemanggil adalah owner
    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    // 5. Fungsi untuk memindahkan kepemilikan (hanya bisa dipanggil owner)
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        owner = newOwner;
    }
}
