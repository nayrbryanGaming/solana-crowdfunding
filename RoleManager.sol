// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoleManager {
    // 1. Mapping dari address ke bool bernama admins
    mapping(address => bool) public admins;

    // 2. Modifier onlyAdmin untuk membatasi akses fungsi khusus admin
    modifier onlyAdmin() {
        require(admins[msg.sender], "Not an admin");
        _;
    }

    // 3. Constructor untuk menyetel pengirim awal (msg.sender) sebagai admin
    constructor() {
        admins[msg.sender] = true;
    }

    // 4. Fungsi untuk menambahkan admin baru (Hanya bisa dipanggil oleh admin)
    function addAdmin(address account) public onlyAdmin {
        admins[account] = true;
    }

    // 5. Fungsi untuk mengecek apakah pemanggil saat ini adalah admin
    function isAdmin() public view returns (bool) {
        return admins[msg.sender];
    }
}
