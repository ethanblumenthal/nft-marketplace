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
}