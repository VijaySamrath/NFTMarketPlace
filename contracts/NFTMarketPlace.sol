
// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketPlace is ReentrancyGuard
{
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner;
  uint256 listingprice=0.01  ether;

  constructor()
  {
      owner=payable(msg.sender);
  }

  struct MarketItem
  {
      uint256 itemId;
      address nftContract;
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
  }

  mapping (uint256=>MarketItem) private idToMarketItem;

  event MarketItemCreated(uint256 indexed itemId,address indexed nftContract, uint256 indexed tokenId,
   address seller,address owner,uint256 price,bool sold);

/** Return the listing price of contract */
function getListingPrice() public view returns(uint256)
{
    return listingprice;
}

/**Places an item for sale on the marketplace */
function createMarketItem(address nftContract,uint256 tokenId,uint256 price) public payable nonReentrant
{
    require(price>0,"Price must be atleast 1 wei");
    require(msg.value==listingprice,"Price must be equal to listingPrice");
    _itemIds.increment();
    uint256 itemId=_itemIds.current();
    idToMarketItem[itemId]=MarketItem(itemId,nftContract,tokenId,payable(msg.sender),payable(address(0)),price,false);

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price, false);
}
/**Create the Sale of a marketplace item */
/**Transfer ownership of the item, as well as funds between party */

function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant
{
   uint price=idToMarketItem[itemId].price;
   uint tokenId=idToMarketItem[itemId].tokenId;

   require(msg.value==price,"Please submit the asking price in order to complete the purchase");
   
   idToMarketItem[itemId].seller.transfer(msg.value);

   IERC721(nftContract).transferFrom(address(this),msg.sender,tokenId);

   idToMarketItem[itemId].owner=payable(msg.sender);
   idToMarketItem[itemId].sold=true;
   _itemsSold.increment();
   payable(owner).transfer(listingprice);

}

/**Returns all unsold market items */

function fetchMarketItems() public view returns (MarketItem[] memory)
{
    uint itemCount=_itemIds.current();
    uint unsoldItemCount=_itemIds.current()-_itemsSold.current();
    uint currentIndex=0;

    MarketItem[] memory items=new MarketItem[](unsoldItemCount);

    for(uint i=0;i<itemCount;i++)
    {
        if(idToMarketItem[i+1].owner==address(0))
        {
            uint currentId=i+1;
            MarketItem storage currentItem=idToMarketItem[currentId];
            items[currentIndex]=currentItem;
            currentIndex+=1;
        }
    }
    return items;
}

/** Return only items that a user has purchased */

function fetchMyNFTs() public view returns(MarketItem[] memory)
{
    uint totalItemCount=_itemIds.current();
    uint itemCount=0;
    uint currentIndex=0;

    for(uint i=0;i<totalItemCount;i++)
    {
        if(idToMarketItem[i+1].owner==msg.sender)
        {
            itemCount+=1;
        }
    }
    MarketItem[] memory items=new MarketItem[](itemCount);

    for(uint i=0;i<totalItemCount;i++)
    {
        if(idToMarketItem[i+1].owner==msg.sender)
        {
            uint currentId=i+1;
            MarketItem storage currentItem=idToMarketItem[currentId];
            items[currentIndex]=currentItem;
            currentIndex+=1;
        }
    }
    return items;
}

/**Return only items a user has created */
function fetchItemsCreated() public view returns(MarketItem[] memory)
{
    uint totalItemCount=_itemIds.current();
    uint itemCount=0;
    uint currentIndex=0;

    for(uint i=0;i<totalItemCount;i++)
    {
        if(idToMarketItem[i+1].seller==msg.sender)
        {
            itemCount+=1;
        }
    }
    MarketItem[] memory items=new MarketItem[](itemCount);

    for(uint i=0;i<totalItemCount;i++)
    {
          if(idToMarketItem[i+1].seller==msg.sender)
          {
              uint currentId=i+1;

              MarketItem storage currentItem=idToMarketItem[currentId];
              items[currentIndex]=currentItem;
              currentIndex+=1;
          }
    }
    return items;
}

}