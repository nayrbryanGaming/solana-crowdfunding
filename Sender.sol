// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Sender {
    // 1. Fungsi deposit yang payable untuk menerima Ether
    function deposit() public payable {}

    // 2. Fungsi untuk mengirim Ether menggunakan method transfer
    // Menggunakan address payable agar bisa menerima Ether.
    function sendEther(address payable _to, uint _amount) public {
        // Pengecekan saldo kontrak sebelum mengirim
        require(address(this).balance >= _amount, "Insufficient balance in contract");
        
        // Mengirim Ether menggunakan transfer (merevert otomatis jika gagal)
        _to.transfer(_amount);
    }

    // 3. Fungsi untuk mengecek saldo Ether di dalam kontrak ini
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Fungsi fallback wajib agar kontrak bisa menerima Ether secara langsung
    receive() external payable {}
}
