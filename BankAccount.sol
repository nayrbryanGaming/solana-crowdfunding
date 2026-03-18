// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract BankAccount {
    // 1. Definisi Custom Errors (Solidity 0.8.4+)
    error InvalidAmount();
    error InsufficientFunds(uint requested, uint available);

    // 2. Mapping untuk melacak saldo setiap akun
    mapping(address => uint) public balances;

    // 3. Fungsi deposit: Menambah saldo
    function deposit(uint amount) public {
        if (amount == 0) {
            revert InvalidAmount();
        }
        balances[msg.sender] += amount;
    }

    // 4. Fungsi withdraw: Menarik saldo sendiri
    function withdraw(uint amount) public {
        if (amount == 0) {
            revert InvalidAmount();
        }
        if (balances[msg.sender] < amount) {
            revert InsufficientFunds({
                requested: amount,
                available: balances[msg.sender]
            });
        }
        balances[msg.sender] -= amount;
    }

    // 5. Fungsi transfer: Mengirim saldo ke akun lain
    function transfer(address to, uint amount) public {
        if (amount == 0) {
            revert InvalidAmount();
        }
        if (balances[msg.sender] < amount) {
            revert InsufficientFunds({
                requested: amount,
                available: balances[msg.sender]
            });
        }
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    // 6. Fungsi getMyBalance: Mengecek saldo akun sendiri
    function getMyBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    // 7. Fungsi canWithdraw: Mengecek apakah penarikan mungkin dilakukan
    // Berdasarkan pola platform Mancer: transfer/withdraw 0 adalah tidak mungkin (revert), 
    // maka canWithdraw(0) harus mengembalikan false.
    function canWithdraw(uint amount) public view returns (bool) {
        if (amount == 0) {
            return false;
        }
        return balances[msg.sender] >= amount;
    }
}
