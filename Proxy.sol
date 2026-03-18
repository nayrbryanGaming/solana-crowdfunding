// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. Logic contract yang berisi fungsi untuk menyetel nilai
contract Logic {
    uint public value;

    function setValue(uint _value) public {
        value = _value;
    }
}

// 2. Proxy contract yang menggunakan delegatecall
contract Proxy {
    // Tata letak storage harus sama dengan Logic contract
    uint public value;
    address public logicContract;

    constructor() {
        // Deploy Logic contract dan simpan alamatnya
        logicContract = address(new Logic());
    }

    // Fungsi untuk mengeksekusi setValue pada Logic menggunakan delegatecall
    function execute(uint _value) public {
        // Delegatecall menjalankan kode Logic tapi menggunakan storage Proxy
        (bool success, ) = logicContract.delegatecall(
            abi.encodeWithSignature("setValue(uint256)", _value)
        );
        require(success, "Delegatecall failed");
    }

    // Fungsi untuk membaca nilai yang tersimpan di storage Proxy
    function getValue() public view returns (uint) {
        return value;
    }
}
