// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrderBook {
    // 1. Definisi Struct Order
    struct Order {
        uint id;
        address buyer;
        uint amount;
    }

    // 2. Event OrderCreated (mencatat id, pembeli, dan jumlah)
    event OrderCreated(uint id, address buyer, uint amount);

    // Variabel untuk melacak jumlah total pesanan
    uint public orderCount;

    // 3. Fungsi untuk membuat pesanan baru
    function createOrder(uint amount) public {
        // Menaikkan hitungan pesanan (digunakan sebagai ID)
        orderCount++;
        
        // Memancarkan event OrderCreated dengan data pesanan baru
        // Kita mencatat ID yang baru naik, alamat pengirim, dan jumlah pesanan.
        emit OrderCreated(orderCount, msg.sender, amount);
    }

    // 4. Fungsi untuk membaca jumlah total pesanan
    function getOrderCount() public view returns (uint) {
        return orderCount;
    }
}
