// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.7.0;

contract Copyright {
    event RegisteredContent(
        uint256 conter,
        bytes32 indexed hashId,
        string indexed contentUrl,
        address indexed owner,
        uint256 timestamp,
        string email,
        string termsOfUse
    );

    struct Content {
        uint256 conter;
        bytes32 hashId;
        string contentUrl;
        address owner;
        uint256 timestamp;
        string email;
        string termsOfUse;
    }

    mapping(bytes32 => Content) public copyrightsById;
    
}
