// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract CardNFT is ERC721, Ownable {
    using Strings for uint256;

    struct Card {
        string card;
        uint256 num;
    }

    mapping(uint256 _tokenId => Card) public _cardData;
    mapping(uint256 _tokenId => uint256) public _price;
    uint256 public _tokenId;

    constructor(address owner) ERC721("CardNFT", "CARD") Ownable(owner) {}

    function get_price(Card memory data) internal pure returns (uint256) {
        string[52] memory cards = [
            "SA",
            "SK",
            "SQ",
            "SJ",
            "S10",
            "S9",
            "S8",
            "S7",
            "S6",
            "S5",
            "S4",
            "S3",
            "S2",
            "HA",
            "HK",
            "HQ",
            "HJ",
            "H10",
            "H9",
            "H8",
            "H7",
            "H6",
            "H5",
            "H4",
            "H3",
            "H2",
            "DA",
            "DK",
            "DQ",
            "DJ",
            "D10",
            "D9",
            "D8",
            "D7",
            "D6",
            "D5",
            "D4",
            "D3",
            "D2",
            "CA",
            "CK",
            "CQ",
            "CJ",
            "C10",
            "C9",
            "C8",
            "C7",
            "C6",
            "C5",
            "C4",
            "C3",
            "C2"
        ];

        uint256 index = 0;

        for (uint256 i = 0; i < 52; i++) {
            if (keccak256(abi.encodePacked(cards[i])) == keccak256(abi.encodePacked(data.card))) {
                index = i;
                break;
            }
        }

        return ((52 - index) + data.num / 10000) * 1000000;
    }

    function mint(address to, Card memory data) public onlyOwner {
        _cardData[_tokenId] = data;
        _price[_tokenId] = get_price(data);
        _mint(to, _tokenId);
        _tokenId++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        Card memory card = _cardData[tokenId];
        return string(
            abi.encodePacked(
                "data:json;base64,", Base64.encode(bytes(string(abi.encodePacked(card.card, "-", card.num.toString()))))
            )
        );
    }
}
