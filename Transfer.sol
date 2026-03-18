// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Transfer {
    // 1. Event dengan parameter 'indexed' agar bisa difilter di aplikasi luar
    // Kita bisa memiliki hingga 3 parameter indexed per event.
    event TransferEvent(address indexed from, address indexed to, uint amount);

    // 2. Variabel untuk melacak jumlah total transfer yang terjadi
    uint public transferCount;

    // 3. Fungsi untuk melakukan simulasi transfer dan memancarkan event
    function transfer(address to, uint amount) public {
        // Memancarkan event TransferEvent dengan msg.sender sebagai pengirim
        emit TransferEvent(msg.sender, to, amount);
        
        // Menambah hitungan total transfer
        transferCount += 1;
    }

    // 4. Fungsi untuk membaca jumlah total transfer (count)
    function getTransferCount() public view returns (uint) {
        return transferCount;
    }
}
