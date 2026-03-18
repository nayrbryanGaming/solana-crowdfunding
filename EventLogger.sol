// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventLogger {
    // 1. Definisi event ValueChanged
    // Event ini akan mencatat nilai baru ke log blockchain
    event ValueChanged(uint newValue);

    // 2. Variabel private uint
    uint private value;

    // 3. Fungsi untuk menyetel nilai dan memancarkan event
    function setValue(uint _value) public {
        value = _value;
        // Memancarkan event ValueChanged dengan nilai baru
        emit ValueChanged(_value);
    }

    // 4. Fungsi untuk membaca nilai yang tersimpan
    function getValue() public view returns (uint) {
        return value;
    }
}
