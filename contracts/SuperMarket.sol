// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract SuperMarket is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _groceryIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;
    address payable owner;

    mapping(uint256 => GroceryItem) private idToGroceryItem;

    struct GroceryItem {
      uint256 groceryId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
    }

    event GroceryItemCreated (
      uint256 indexed groceryId,
      address seller,
      address owner,
      uint256 price,
      bool sold
    );

    constructor() ERC721("SuperMarket Groceries", "SMG") {
      owner = payable(msg.sender);
    }

    /* Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable {
      require(owner == msg.sender, "Only supermarket owner can update listing price.");
      listingPrice = _listingPrice;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
      return listingPrice;
    }

    /* Mints a token and lists it in the supermarket */
    function createGrocery(string memory tokenURI, uint256 price) public payable returns (uint) {
      _groceryIds.increment();
      uint256 newGroceryId = _groceryIds.current();

      _mint(msg.sender, newGroceryId);
      _setTokenURI(newGroceryId, tokenURI);
      createGroceryItem(newGroceryId, price);
      return newGroceryId;
    }

    function createGroceryItem(
      uint256 groceryId,
      uint256 price
    ) private {
      require(price > 0, "Price must be at least 1 wei");
      require(msg.value == listingPrice, "Price must be equal to listing price");

      idToGroceryItem[groceryId] =  GroceryItem(
        groceryId,
        payable(msg.sender),
        payable(address(this)),
        price,
        false
      );

      _transfer(msg.sender, address(this), groceryId);
      emit GroceryItemCreated(
        groceryId,
        msg.sender,
        address(this),
        price,
        false
      );
    }

    /* allows someone to resell an item they have purchased */
    function resellGrocery(uint256 groceryId, uint256 price) public payable {
      require(idToGroceryItem[groceryId].owner == msg.sender, "Only item owner can perform this operation");
      require(msg.value == listingPrice, "Price must be equal to listing price");
      idToGroceryItem[groceryId].sold = false;
      idToGroceryItem[groceryId].price = price;
      idToGroceryItem[groceryId].seller = payable(msg.sender);
      idToGroceryItem[groceryId].owner = payable(address(this));
      _itemsSold.decrement();

      _transfer(msg.sender, address(this), groceryId);
    }

    /* Creates the sale of a grocery item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createGrocerySale(
      uint256 groceryId
      ) public payable {
      uint price = idToGroceryItem[groceryId].price;
      address seller = idToGroceryItem[groceryId].seller;
      require(msg.value == price, "Please submit the asking price in order to complete the purchase");
      idToGroceryItem[groceryId].owner = payable(msg.sender);
      idToGroceryItem[groceryId].sold = true;
      idToGroceryItem[groceryId].seller = payable(address(0));
      _itemsSold.increment();
      _transfer(address(this), msg.sender, groceryId);
      payable(owner).transfer(listingPrice);
      payable(seller).transfer(msg.value);
    }

    /* Returns all unsold grocery items */
    function fetchGroceryItems() public view returns (GroceryItem[] memory) {
      uint itemCount = _groceryIds.current();
      uint unsoldItemCount = _groceryIds.current() - _itemsSold.current();
      uint currentIndex = 0;

      GroceryItem[] memory items = new GroceryItem[](unsoldItemCount);
      for (uint i = 0; i < itemCount; i++) {
        if (idToGroceryItem[i + 1].owner == address(this)) {
          uint currentId = i + 1;
          GroceryItem storage currentItem = idToGroceryItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyGroceries() public view returns (GroceryItem[] memory) {
      uint totalItemCount = _groceryIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToGroceryItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }

      GroceryItem[] memory items = new GroceryItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToGroceryItem[i + 1].owner == msg.sender) {
          uint currentId = i + 1;
          GroceryItem storage currentItem = idToGroceryItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items a user has listed */
    function fetchItemsListed() public view returns (GroceryItem[] memory) {
      uint totalItemCount = _groceryIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToGroceryItem[i + 1].seller == msg.sender) {
          itemCount += 1;
        }
      }

      GroceryItem[] memory items = new GroceryItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToGroceryItem[i + 1].seller == msg.sender) {
          uint currentId = i + 1;
          GroceryItem storage currentItem = idToGroceryItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }
}