// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("MyNFT", "MNFT") {}

    function awardItem(address recipient, string memory hash, string memory metadata) public returns (uint256) {
        require(bytes(metadata).length > 0, "Metadata should not be empty");
        require(bytes(hash).length > 0, "IPFS hash should not be empty");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);

        string memory tokenURI = string(abi.encodePacked(_baseURI(), hash));
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://";
    }


    function setTokenURI(uint256 tokenId, string memory tokenURI) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _setTokenURI(tokenId, tokenURI);
    }
}
