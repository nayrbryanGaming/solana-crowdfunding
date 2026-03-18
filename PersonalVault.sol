// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PersonalVault
 * @dev Kontrak simpanan pribadi dengan penguncian waktu (Time-Locked).
 * Dana hanya bisa ditarik oleh pemilik setelah waktu pembukaan (Unlock Time) tercapai.
 */
contract PersonalVault {
    address public owner;           // Siapa pemilik vault ini
    uint256 public unlockTime;      // Kapan dana bisa diambil (timestamp)
    
    // Events untuk mencatat aktivitas penting
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);
    event LockExtended(uint256 newUnlockTime);
    
    // Custom errors untuk efisiensi gas (Solidity 0.8.4+)
    error FundsLocked();
    error NotOwner();
    error InvalidUnlockTime();

    // Modifier untuk membatasi akses hanya bagi pemilik
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /**
     * @dev Constructor untuk inisialisasi vault.
     * @param _unlockTime Waktu pembukaan (harus di masa depan).
     */
    constructor(uint256 _unlockTime) payable {
        if (_unlockTime <= block.timestamp) revert InvalidUnlockTime();
        
        owner = msg.sender;
        unlockTime = _unlockTime;

        // Jika ada ETH yang dikirim saat deployment, catat sebagai deposit
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    /**
     * @dev Fungsi deposit untuk menambah saldo vault (Hanya owner).
     * Sesuai brief: "Owner adds ETH to the vault".
     */
    function deposit() public payable onlyOwner {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Fungsi withdraw: Mengambil seluruh dana setelah waktu kunci berakhir.
     */
    function withdraw() public onlyOwner {
        // 1. Cek apakah waktu sudah melewati unlockTime
        if (block.timestamp < unlockTime) {
            revert FundsLocked();
        }

        // 2. Ambil saldo saat ini
        uint256 amount = address(this).balance;
        require(amount > 0, "Kontrak tidak memiliki saldo");

        // 3. Efek: Emit event sebelum transfer (Checks-Effects-Interactions)
        emit Withdrawal(amount, block.timestamp);

        // 4. Interaksi: Transfer seluruh saldo ke pemilik
        // Menggunakan call{value: amount}("") sesuai rekomendasi keamanan terbaru
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer Gagal");
    }

    /**
     * @dev Fungsi extendLock: Memperpanjang waktu kunci (Tidak bisa dikurangi).
     * @param newTime Timestamp baru untuk pembukaan kunci.
     */
    function extendLock(uint256 newTime) public onlyOwner {
        // Validasi: Waktu baru harus lebih besar dari waktu kunci saat ini
        if (newTime <= unlockTime) {
            revert InvalidUnlockTime();
        }

        unlockTime = newTime;
        emit LockExtended(newTime);
    }

    // Fungsi pembantu untuk mengecek saldo kontrak saat ini
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Fungsi fallback agar kontrak bisa menerima ETH secara langsung dari pemilik
    receive() external payable {
        if (msg.sender == owner) {
            emit Deposit(msg.sender, msg.value);
        }
    }
}
