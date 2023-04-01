// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// modified royalties baser IERC2981 interfaces
interface IERC2981 is IERC165 {
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice,
        uint256 royaliPercentage
    ) external view returns (address receiver, uint256 royaltyAmount);
}

contract MutantAIGoerli is ERC721, Ownable, IERC2981 {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private supply;

    string public uriPrefix = "";
    string public uriSuffix = "";

    uint256 public mintCost = 0.1 ether;
    uint256 public maxSupply = 5555;
    uint256 public maxMintAmountPerTx = 3;
    uint256 mintLimit = 3;
    mapping(address => uint256) public mintCount;
    address public beneficiary;
    address public royalties;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        string memory _initialBaseURI
    ) ERC721(tokenName, tokenSymbol) {
        beneficiary = owner();
        royalties = owner();
        uriPrefix = _initialBaseURI;
    }

    modifier mintRequire(uint256 _mintAmount) {
        require(
            _mintAmount > 0 && _mintAmount <= maxMintAmountPerTx,
            "Invalid mint amount!"
        );
        require(
            supply.current() + _mintAmount <= maxSupply,
            "Will exceed maximum supply!"
        );
        _;
    }

    function totalSupply() public view returns (uint256) {
        return supply.current();
    }

    function mint(uint256 _mintAmount) public payable mintRequire(_mintAmount) {
        require(msg.value >= mintCost * _mintAmount, "Insufficient funds!");
        require(
            mintCount[msg.sender] + _mintAmount <= mintLimit,
            "public mint limit exceeded"
        );

        _mintLoop(msg.sender, _mintAmount);
        mintCount[msg.sender] += _mintAmount;
    }

    function airdrop(
        address[] memory _recipients,
        uint256 _amount
    ) public onlyOwner {
        uint256 count = _recipients.length;
        for (uint256 i = 0; i < count; i++) {
            for (uint256 j = 0; j < _amount; j++) {
                _safeMint(_recipients[i], supply.current());
                supply.increment();
            }
        }
    }

    function getmintCount() public view returns (uint256) {
        return mintCount[msg.sender];
    }

    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;

        while (
            ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply
        ) {
            address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _owner) {
                ownedTokenIds[ownedTokenIndex] = currentTokenId;
                ownedTokenIndex++;
            }
            currentTokenId++;
        }
        return ownedTokenIds;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory currentBaseURI = _baseURI();
        return (
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _tokenId.toString(),
                        uriSuffix
                    )
                )
                : ""
        );
    }

    function withdraw() public onlyOwner {
        payable(beneficiary).transfer(address(this).balance);
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }

    function setRoyalties(address _royalties) public onlyOwner {
        royalties = _royalties;
    }

    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
        for (uint256 i = 0; i < _mintAmount; i++) {
            _safeMint(_receiver, supply.current());
            supply.increment();
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }

    function setBaseURI(string memory uri) public onlyOwner {
        uriPrefix = uri;
    }

    function setUriSuffix(string memory newData) public onlyOwner {
        uriSuffix = newData;
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice,
        uint256 _percentage
    ) external view returns (address, uint256 royaltyAmount) {
        _tokenId; // silence solc warning
        royaltyAmount = (_salePrice / 100) * _percentage;
        return (royalties, royaltyAmount);
    }
}
