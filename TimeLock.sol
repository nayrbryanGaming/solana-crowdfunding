// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLock {
    // 1. Private uint lockDuration diinisialisasi ke 60 detik
    uint private lockDuration = 60;

    // 2. Public uint unlockTime yang disetel di constructor
    uint public unlockTime;

    // 3. Private uint value untuk menyimpan data
    uint private value;

    // 4. Modifier afterUnlock untuk mengecek apakah waktu saat ini >= unlockTime
    modifier afterUnlock() {
        require(block.timestamp >= unlockTime, "Unlock time not reached yet");
        _;
    }

    // 5. Constructor menyetel unlockTime berdasarkan timestamp blok saat ini + durasi kunci
    constructor() {
        unlockTime = block.timestamp + lockDuration;
    }

    // 6. Fungsi untuk menyetel nilai (Hanya bisa dipanggil setelah waktu kunci berakhir)
    function setValue(uint _value) public afterUnlock {
        value = _value;
    }

    // 7. Fungsi untuk mengambil nilai yang tersimpan
    function getValue() public view returns (uint) {
        return value;
    }

    // 8. Fungsi untuk mengambil waktu pembukaan (unlock time)
    function getUnlockTime() public view returns (uint) {
        return unlockTime;
    }

    // 9. Fungsi untuk mengambil durasi penguncian (lock duration)
    function getLockDuration() public view returns (uint) {
        return lockDuration;
    }
}
