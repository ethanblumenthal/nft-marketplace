pragma solidity 0.8.4;

import "./IERC721.sol";

contract CryptoKitties is IERC721 {
    string public override constant name = "CryptoKitties";
    string public override constant symbol = "CK";

    event Birth(address owner, uint256 kittenId, uint256 momId, uint256 dadId, uint256 genes);

    struct Kitty {
        uint256 genes;
        uint64 birthTime;
        uint32 momId;
        uint32 dadId;
        uint16 generation;
    }

    Kitty[] kitties;

    mapping (uint256 => address) public kittyIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;

    function balanceOf(address owner) external view override returns (uint256 balance) {
        return ownershipTokenCount[owner];
    }

    function totalSupply() public view override returns (uint) {
        return kitties.length;
    }

    function ownerOf(uint256 _tokenId) external view override returns (address) {
        return kittyIndexToOwner[_tokenId];
    }

    function transfer(address _to, uint256 _tokenId) external override {
        require(_to != address(0));
        require(_to != address(this));
        require(_owns(msg.sender, _tokenId));

        _transfer(msg.sender, _to, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;

        kittyIndexToOwner[_tokenId] = _to;

        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
        }

        // Emit the transfer event
        emit Transfer(_from, _to, _tokenId);
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return kittyIndexToOwner[_tokenId] == _claimant;
    }
}