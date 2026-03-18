// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    // 1. Event BidPlaced (bidder, amount)
    event BidPlaced(address bidder, uint amount);
    
    // 2. Event AuctionEnded (winner, amount)
    event AuctionEnded(address winner, uint amount);

    // Variabel untuk melacak penawaran tertinggi dan pemenangnya
    uint public highestBid;
    address public highestBidder;

    // 3. Fungsi untuk menaruh tawaran (placeBid)
    function placeBid(uint amount) public {
        // Kontrol: Pastikan tawaran baru lebih tinggi dari sebelumnya
        require(amount > highestBid, "Tawaran harus lebih tinggi dari saat ini");
        
        highestBid = amount;
        highestBidder = msg.sender;

        // Memancarkan event BidPlaced
        emit BidPlaced(msg.sender, amount);
    }

    // 4. Fungsi untuk mengakhiri lelang (endAuction)
    function endAuction() public {
        // Memancarkan event AuctionEnded dengan pemenang saat ini
        emit AuctionEnded(highestBidder, highestBid);
    }

    // 5. Fungsi untuk membaca nilai tawaran tertinggi (getHighestBid)
    function getHighestBid() public view returns (uint) {
        return highestBid;
    }
}
