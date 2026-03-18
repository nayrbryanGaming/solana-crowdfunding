// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pausable {
    // 1. Variabel private paused diinisialisasi ke false
    bool private paused = false;

    // 2. Variabel private counter untuk melacak kenaikan
    uint private counter;

    // 3. Modifier whenNotPaused yang mensyaratkan status tidak sedang di-pause
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    // 4. Fungsi untuk mengubah status menjadi paused
    function pause() public {
        paused = true;
    }

    // 5. Fungsi untuk mengubah status menjadi tidak paused
    function unpause() public {
        paused = false;
    }

    // 6. Fungsi untuk mengembalikan status paused saat ini
    function isPaused() public view returns (bool) {
        return paused;
    }

    // 7. Fungsi increment yang menggunakan modifier whenNotPaused
    function increment() public whenNotPaused {
        counter += 1;
    }

    // 8. Fungsi untuk mengembalikan nilai counter saat ini
    function getCounter() public view returns (uint) {
        return counter;
    }
}
