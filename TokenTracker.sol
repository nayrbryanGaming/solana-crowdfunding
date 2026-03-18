// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenTracker {
    // 1. Definisi 3 tipe event berbeda dengan parameter indexed
    event Minted(address indexed to, uint amount);
    event Burned(address indexed from, uint amount);
    event Transferred(address indexed from, address indexed to, uint amount);

    // Variabel untuk melacak total supply dan saldo
    uint public totalSupply;
    mapping(address => uint) public balances;

    // 2. Fungsi mint untuk menambah supply dan saldo
    function mint(address to, uint amount) public {
        totalSupply += amount;
        balances[to] += amount;
        
        // Memancarkan event Minted
        emit Minted(to, amount);
    }

    // 3. Fungsi burn untuk mengurangi supply dan saldo pengirim
    function burn(uint amount) public {
        require(balances[msg.sender] >= amount, "Saldo tidak cukup untuk burn");
        
        totalSupply -= amount;
        balances[msg.sender] -= amount;
        
        // Memancarkan event Burned
        emit Burned(msg.sender, amount);
    }

    // 4. Fungsi transfer antar alamat
    function transfer(address to, uint amount) public {
        require(balances[msg.sender] >= amount, "Saldo tidak cukup untuk transfer");
        
        balances[msg.sender] -= amount;
        balances[to] += amount;
        
        // Memancarkan event Transferred
        emit Transferred(msg.sender, to, amount);
    }

    // 5. Fungsi untuk mengambil saldo alamat tertentu
    function getBalance(address account) public view returns (uint) {
        return balances[account];
    }

    // 6. Fungsi untuk mengambil total supply saat ini
    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }
}
