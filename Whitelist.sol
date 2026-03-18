// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Whitelist {
    // 1. Mapping whitelist dari address ke bool
    mapping(address => bool) public whitelist;

    // 2. Variabel uint untuk menyimpan data
    uint public value;

    // 3. Modifier onlyWhitelisted untuk mengecek apakah pengirim terdaftar di whitelist
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Not whitelisted");
        _;
    }

    // 4. Fungsi untuk menambahkan diri sendiri (msg.sender) ke whitelist
    function addToWhitelist() public {
        whitelist[msg.sender] = true;
    }

    // 5. Fungsi untuk mengecek apakah msg.sender terdaftar di whitelist
    function isWhitelisted() public view returns (bool) {
        return whitelist[msg.sender];
    }

    // 6. Fungsi untuk menyetel nilai (Hanya bisa dipanggil oleh mereka yang terdaftar di whitelist)
    function setValue(uint _value) public onlyWhitelisted {
        value = _value;
    }

    // 7. Fungsi untuk mengambil nilai yang tersimpan
    function getValue() public view returns (uint) {
        return value;
    }
}
