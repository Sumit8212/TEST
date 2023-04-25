// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// IMPORTING ERC721 FROM OPENZEPPELIN
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// CREATING ERC721 TOKEN //
contract MyToken is ERC721 {
    constructor() ERC721("MyToken", "MTK") {}

    function safeMint(address owner, uint256 tokenId) public {
        // require(owner==,"only marketplace can mint");
        _safeMint(owner, tokenId);
    }
}

// BIDDING CONTRACT//
contract Bidding {
    address public owner;
    MyToken child = new MyToken(); // CREATING INSTANCE

    constructor(address contract721) {
        child = MyToken(contract721);
        owner = msg.sender;
    }

    // ONLY OWNER MODIFIER //
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can run this function");
        _;
    }

    // MAPPING //
    mapping(uint256 => uint256) public highestBid;
    mapping(address => mapping(uint256 => uint256)) bidding;
    mapping(uint256 => address) highestBidder;

    // MINT FUNCTION ONLY OWNER //

    function mint(address _owner, uint256 _tokenId) public onlyOwner {
        child.safeMint(_owner, _tokenId);
    }

    // SET ON BID FUNCTION ONLY OWNER//

    function setOnBid(
        address _owner,
        uint256 _tokenId,
        uint256 price
    ) public onlyOwner {
        highestBid[_tokenId] = price;
        bidding[_owner][_tokenId];
    }

    // BID FUNCTION SO ANY USER CAN PARTICIPATE ON BIDDING  //

    function bid(address user, uint256 tokenId, uint256 price) public {
        require(
            child.ownerOf(tokenId) != user,
            " owner should not be allowed to bid on his own nft"
        );
        require(user == msg.sender, "you can't bid on another address");
        require(
            highestBid[tokenId] < price,
            "Increase your bid someone already bid higher than you!"
        );
        bidding[user][tokenId] = price;
        highestBid[tokenId] = price;
        highestBidder[tokenId] = user;
    }

    // CHECK HIGHEST BIDDER OF A NFT //
    function checkhighestBidder(uint256 tokenId) public view returns (address) {
        return highestBidder[tokenId];
    }

    // AUCTION ENNDED //
    function EndAuction(uint256 tokenId) public onlyOwner {
        child.safeTransferFrom(
            child.ownerOf(tokenId),
            highestBidder[tokenId],
            tokenId
        ); // transfer ownership of tokenId to highestBidder
        payable(child.ownerOf(tokenId)).transfer(highestBid[tokenId]); // transfering amount of biiding to tokenId owner.
    }
}
