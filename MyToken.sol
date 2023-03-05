 // SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "https://github.com/0xcert/ethereum-erc721/src/contracts/tokens/nf-token-metadata.sol";
import "https://github.com/0xcert/ethereum-erc721/src/contracts/ownership/ownable.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFConsumerBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/utils/math/SafeMath.sol";
import "https://github.com/quai19/oracles-core/blob/master/contracts/OraclesProxy.sol";

contract newNFT is NFTokenMetadata, Ownable, VRFConsumerBase {
    using SafeMath for uint256;

    string constant INFURA_ENDPOINT = "https://ipfs.infura.io/ipfs/";
    bytes32 internal keyHash;
    uint256 internal fee;

    OraclesProxy public oraclesProxy;

    constructor(address vrfCoordinator, address link, address _oraclesProxy, bytes32 _keyHash, uint256 _fee) VRFConsumerBase(vrfCoordinator, link) {
        nftName = "SectionTest NFT";
        nftSymbol = "STNF";
        keyHash = _keyHash;
        fee = _fee;
        oraclesProxy = OraclesProxy(_oraclesProxy);
    }

    struct Request {
        uint256 tokenId;
        address requester;
    }
    mapping(bytes32 => Request) public requests;
    mapping(uint256 => string) public tokenURIs;

    function requestNewRandomToken() public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyHash, fee);
        requests[requestId] = Request(0, msg.sender);
        return requestId;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        uint256 newTokenId = (randomNumber % 10000) + 1;
        Request storage req = requests[requestId];
        require(req.requester != address(0), "Requester address not valid");
        require(req.tokenId == 0, "Token ID already assigned");
        req.tokenId = newTokenId;
        _safeMint(req.requester, newTokenId);
    }

    function getNFTMetadata(uint256 _tokenId) external view returns (string memory) {
        string memory tokenURI = super.tokenURI(_tokenId);
        return string(abi.encodePacked(INFURA_ENDPOINT, tokenURI));
    }

    function mint(address _to, uint256 _tokenId, string calldata _uri) external onlyOwner {
        super._mint(_to, _tokenId);
        super._setTokenUri(_tokenId, _uri);
        string memory metadata = getNFTMetadata(_tokenId);
        // Do something with the metadata
    }

    function getCurrentPrice(string calldata _symbol) external view returns (uint256) {
        return oraclesProxy.getAssetPrice(_symbol);
    }
}
