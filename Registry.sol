// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. Interface untuk pemanggilan kontrak eksternal
interface ICounter {
    function increment() external;
    function getCount() external view returns (uint);
}

contract Registry {
    // 2. Mapping untuk menyimpan alamat kontrak berdasarkan nama
    mapping(string => address) public contracts;
    
    // Variabel untuk melacak jumlah kontrak yang terdaftar
    uint public count;

    // 3. Fungsi register(string, address) untuk mendaftarkan kontrak
    function register(string memory name, address _addr) public {
        // Jika nama tersebut belum pernah didaftarkan, kita tambah jumlah totalnya
        if (contracts[name] == address(0)) {
            count++;
        }
        contracts[name] = _addr;
    }

    // 4. Fungsi getContract(string) untuk mengambil alamat berdasarkan nama
    function getContract(string memory name) public view returns (address) {
        return contracts[name];
    }

    // 5. Fungsi getRegistryCount() untuk mengembalikan jumlah kontrak yang terdaftar
    function getRegistryCount() public view returns (uint) {
        return count;
    }

    // 6. Fungsi callCounter(string) untuk memanggil increment() pada counter yang terdaftar
    function callCounter(string memory name) public {
        address counterAddress = contracts[name];
        require(counterAddress != address(0), "Kontrak tidak ditemukan");
        
        // Melakukan interaksi eksternal menggunakan interface
        ICounter(counterAddress).increment();
    }

    // 7. Fungsi getCounterValue(string) untuk mengambil nilai dari counter yang terdaftar
    function getCounterValue(string memory name) public view returns (uint) {
        address counterAddress = contracts[name];
        require(counterAddress != address(0), "Kontrak tidak ditemukan");
        
        // Melakukan pemanggilan view eksternal menggunakan interface
        return ICounter(counterAddress).getCount();
    }
}
