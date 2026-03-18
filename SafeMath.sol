// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeMath {
    // 1. Fungsi add(uint a, uint b) yang mengembalikan hasil penjumlahan
    // Di Solidity 0.8.0+, overflow dicek secara otomatis.
    function add(uint a, uint b) public pure returns (uint) {
        return a + b;
    }

    // 2. Fungsi subtract(uint a, uint b) yang mengembalikan hasil pengurangan
    // Di Solidity 0.8.0+, underflow dicek secara otomatis.
    function subtract(uint a, uint b) public pure returns (uint) {
        return a - b;
    }

    // 3. Fungsi checkInvariant(uint a, uint b) untuk memverifikasi Invarian: (a + b) - b == a
    // Menggunakan 'assert' untuk memastikan kondisi yang secara matematis tidak boleh salah.
    function checkInvariant(uint a, uint b) public pure returns (bool) {
        // Invarian: jika b ditambah ke a lalu dikurangi b lagi, hasilnya harus tetap a.
        assert((a + b) - b == a);
        return true;
    }
}
