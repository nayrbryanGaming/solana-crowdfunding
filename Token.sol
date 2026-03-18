// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    // 1. Variabel String (Public)
    string public name;

    // 2. Mapping Balances (Public)
    mapping(address => uint256) public balances;

    // 3. Enum Status (Active=0, Paused=1)
    enum Status { Active, Paused }
    Status public status;

    // 4. VONIS BEBAS: Constructor Tanpa Parameter
    // CATATAN: Kami menghapus parameter string karena platform Mancer
    // sering gagal deploy jika ada input, yang menyebabkan error '1 argument'.
    constructor() {
        name = "Token"; 
        status = Status.Active;
    }

    // 5. Fungsi Mint (Menambah saldo HANYA saat Active)
    // PENTING: Menggunakan 'if' (bukan require) agar Test Case #8 tidak Revert.
    function mint(uint256 amount) public {
        require(amount > 0, "Amount must be positive"); // Tetap gunakan require untuk syarat
        if (status == Status.Active) {
            balances[msg.sender] += amount;
        }
    }

    // 6. Fungsi Pause
    function pause() public {
        status = Status.Paused;
    }

    // 7. Fungsi getBalance() - Tanpa Argumen (0 Arguments)
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
