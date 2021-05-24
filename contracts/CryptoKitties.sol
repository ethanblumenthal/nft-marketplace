// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IERC721.sol";
import "./Ownable.sol";

contract CryptoKitties is IERC721, Ownable {

    uint256 public constant CREATION_LIMIT_GEN0 = 10;
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

    uint256 gen0Counter;

    function getKitty(uint256 _id) external view returns (uint256 genes, uint256 birthTime, uint256 momId, uint256 dadId, uint256 generation) {
        Kitty storage kitty = kitties[_id];

        genes = uint256(kitty.genes);
        birthTime = uint256(kitty.birthTime);
        momId = uint256(kitty.momId);
        dadId = uint256(kitty.dadId);
        generation = uint256(kitty.generation);

    }

    function createKittyGen0(uint256 _genes) public onlyOwner returns (uint256) {
        require(gen0Counter < CREATION_LIMIT_GEN0);

        gen0Counter++;

        // Gen0 have no owners as they are owned by the contract
        return _createKitty(0, 0, 0, _genes, msg.sender);
    }

    function _createKitty(uint256 _momId, uint256 _dadId, uint256 _generation, uint256 _genes, address _owner) private returns (uint256) {
        Kitty memory _kitty = Kitty({
            genes: _genes,
            birthTime: uint64(block.timestamp),
            momId: uint32(_momId),
            dadId: uint32(_dadId),
            generation: uint16(_generation)
        });

        uint256 newKittenId = kitties.push(_kitty) - 1;
        emit Birth(_owner, newKittenId, _momId, _dadId, _genes);
        _transfer(address(0), _owner, newKittenId);

        return newKittenId;
    }

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