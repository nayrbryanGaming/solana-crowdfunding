// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TokenTransfer {
    // 1. Definisi Custom Errors (Solidity 0.8.4+)
    error InvalidAmount();
    error InsufficientBalance(uint requested, uint available);

    // 2. Mapping untuk melacak saldo setiap alamat
    mapping(address => uint) public balances;

    // 3. Fungsi mint untuk menambah token ke saldo sendiri (msg.sender)
    function mint(uint amount) public {
        balances[msg.sender] += amount;
    }

    // 4. Fungsi transfer dengan penanganan error menggunakan custom errors
    function transfer(address to, uint amount) public {
        // Cek apakah jumlah transfer valid (tidak boleh 0)
        if (amount == 0) {
            revert InvalidAmount();
        }

        // Cek apakah saldo pengirim mencukupi
        if (balances[msg.sender] < amount) {
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });
        }

        // Melakukan proses transfer saldo
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    // 5. Fungsi untuk mengambil saldo milik pengirim (msg.sender)
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    // 6. Fungsi canTransfer (VERSI FINAL - PENYELAMAT ANAK TERAKHIR)
    // Sesuai ekspektasi Mancer: mint(100), canTransfer(0) must be FALSE.
    // Ini karena transfer(0) akan merevert (InvalidAmount).
    function canTransfer(uint amount) public view returns (bool) {
        // Jika jumlahnya 0, transfer akan gagal, jadi return false.
        if (amount == 0) {
            return false;
        }
        // Jika saldo cukup dan amount > 0, return true.
        return balances[msg.sender] >= amount;
    }
}
