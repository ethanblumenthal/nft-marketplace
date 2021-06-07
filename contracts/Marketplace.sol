// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IMarketplace.sol";
import "./CryptoKitties.sol";
import "./Ownable.sol";

abstract contract Marketplace is Ownable, IMarketplace {
    CryptoKitties private _cryptoKitties;

    struct Offer {
        address payable seller;
        uint256 price;
        uint256 index;
        uint256 tokenId;
        bool active;
    }

    Offer[] offers;

    mapping(uint256 => Offer) tokenIdToOffer;

    function setKittyContract(address _cryptoKittiesAddress) public override onlyOwner {
        _cryptoKitties = CryptoKitties(_cryptoKittiesAddress);
    }

    constructor (address _cryptoKittiesAddress) {
        setKittyContract(_cryptoKittiesAddress);
    }

    function getOffer(uint256 _tokenId) public view override returns (address seller, uint256 price, uint256 index, uint256 tokenId, bool active) {
        Offer storage offer = tokenIdToOffer[_tokenId];
        return (offer.seller, offer.price, offer.index, offer.tokenId, offer.active);
    }

     function getAllTokenOnSale() public view override returns(uint256[] memory listOfOffers) {
        uint256 totalOffers = offers.length;

        if (totalOffers == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](totalOffers);
            uint256 offerId;

            for (offerId = 0; offerId < totalOffers; offerId++) {
                if (offers[offerId].active == true) {
                    result[offerId] = offers[offerId].tokenId;
                }
            }
            return result;
        }
    }

    function _ownsKitty(address _address, uint256 _tokenId) internal view returns (bool) {
        return (_cryptoKitties.ownerOf(_tokenId) == _address);
    }

    // Create a new offer based on the given tokenId and price
    function setOffer(uint256 _price, uint256 _tokenId) public override {
        require(_ownsKitty(msg.sender, _tokenId), "You are not the owner of that kitty");
        require(tokenIdToOffer[_tokenId].active == false, "You can't sell the same kitty twice");
        require(_cryptoKitties.isApprovedForAll(msg.sender, address(this)), "Contract needs to be approved to transfer the kitty in the future");

        Offer memory _offer = Offer({
            seller: payable(msg.sender),
            price: _price,
            active: true,
            tokenId: _tokenId,
            index: offers.length
        });

        tokenIdToOffer[_tokenId] = _offer;
        offers.push(_offer);

        emit MarketTransaction("Create offer", msg.sender, _tokenId);
    }

    // Remove an existing offer
    function removeOffer(uint256 _tokenId) public override {
        Offer memory offer = tokenIdToOffer[_tokenId];
        require(offer.seller == msg.sender, "You are not the seller of that kitty");

        delete tokenIdToOffer[_tokenId];
        offers[offer.index].active = false;

        emit MarketTransaction("Remove offer", msg.sender, _tokenId);
    }

    // Accept an offer to buy the kitty
    function buyKitty(uint256 _tokenId) public payable override {
        Offer memory offer = tokenIdToOffer[_tokenId];
        require(msg.value == offer.price, "The price is incorrect");
        require(tokenIdToOffer[_tokenId].active == true, "No active order present");

        // Delete the kitty from the mapping before paying out to prevent reentry attacks
        delete tokenIdToOffer[_tokenId];
        offers[offer.index].active = false;

        // Transfer the funds t the seller
        if (offer.price > 0) {
            offer.seller.transfer(offer.price);
        }

        // Transfer ownership of the kitty
        _cryptoKitties.transferFrom(offer.seller, msg.sender, _tokenId);
        emit MarketTransaction("Buy", msg.sender, _tokenId);
    }
}