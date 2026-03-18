// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExternalCallDemo {
    // 1. Private uint counter untuk melacak hitungan
    uint private counter;

    // 2. Implement increment() external function yang menambah counter
    function increment() external {
        counter += 1;
    }

    // 3. Implement getCount() external view function yang mengembalikan counter
    function getCount() external view returns (uint) {
        return counter;
    }

    // 4. Implement callIncrement() public function yang memanggil this.increment()
    // Menggunakan 'this' memaksa pemanggilan fungsi menjadi 'external call'.
    function callIncrement() public {
        this.increment();
    }

    // 5. Implement callGetCount() public view function yang memanggil this.getCount()
    function callGetCount() public view returns (uint) {
        return this.getCount();
    }
}
