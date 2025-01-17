// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketPlace is Ownable,ERC721URIStorage {
    // Product
    struct Product {
        string name;
        string description;
        uint price;
        uint quantity;
        string ipfsLink;
        uint sold;
    }

    Product[] private products;

    // Timestamps of sold, Address of customer
    string public marketPlaceName; 
    string public marketPlaceDescription;
    uint private tokenId = 0;

    constructor(string memory _name, string memory _description) Ownable(msg.sender) ERC721("BITMART", "BMART") {
        marketPlaceName = _name;
        marketPlaceDescription = _description;
    }

    function addProduct(string memory _name, string memory _description, uint _price, uint _quantity, string memory _ipfsLink) public {
        require(bytes(_name).length > 0, "Name required");
        require(_price > 0, "Price required");
        require(bytes(_description).length > 0, "Description required");
        require(_quantity > 0, "Quantity required");
        require(bytes(_ipfsLink).length > 0, "IPFS Link required");

        products.push(Product(_name, _description, _price, _quantity, _ipfsLink, 0));
    }

    function getProducts() public view returns (Product[] memory) {
       return products;
    }

    function getProduct(uint _id) public view returns (Product memory) {
        require(_id >= 0 && _id < products.length, "Invalid product id");
        return products[_id];
    }

    function deleteProduct(uint _id) public {
        require(_id >= 0 && _id < products.length, "Invalid product id");
        products[_id] = products[products.length - 1];
        products.pop();
    }

    function editProduct(uint _id, string memory _name, string memory _description, uint _price, uint _quantity, string memory _ipfsLink) public {
        require(_id >= 0 && _id < products.length, "Invalid product id");
        require(bytes(_name).length > 0, "Name required");
        require(bytes(_description).length > 0, "Description required");
        require(_price > 0, "Price required");
        require(_quantity > 0, "Quantity required");
        require(bytes(_ipfsLink).length > 0, "IPFS Link required");

        products[_id].name = _name;
        products[_id].price = _price;
        products[_id].description = _description; 
        products[_id].quantity = _quantity;
        products[_id].ipfsLink = _ipfsLink;
    }

    function buyProduct(uint _id) public payable {
        require(_id >= 0 && _id < products.length, "Invalid product id");
        require(products[_id].quantity > 0, "Product out of stock");
        require(msg.value >= products[_id].price, "Insufficient funds");

        payable(owner()).transfer(msg.value);

  
        // Update product information
        products[_id].sold += 1;
        products[_id].quantity -= 1;

        // Mint NFT
        tokenId = tokenId + 1;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, string(abi.encodePacked(marketPlaceName, marketPlaceDescription, products[_id].name, products[_id].description)));
    }

}
