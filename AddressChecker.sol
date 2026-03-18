// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AddressChecker {
    // 1. Fungsi untuk mengecek apakah sebuah alamat adalah kontrak atau bukan
    // Kita menggunakan properti .code.length untuk melihat apakah ada bytecode di alamat tersebut.
    function isContract(address _addr) public view returns (bool) {
        // Jika panjang kodenya > 0, berarti alamat tersebut adalah kontrak (bukan EOA)
        return _addr.code.length > 0;
    }

    // 2. Fungsi checkSelf yang memanggil isContract dengan alamat kontrak ini sendiri
    // address(this) akan selalu mengembalikan true karena ini adalah kontrak.
    function checkSelf() public view returns (bool) {
        return isContract(address(this));
    }
}
