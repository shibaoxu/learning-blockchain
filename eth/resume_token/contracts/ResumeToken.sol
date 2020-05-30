// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

contract ERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId)
        public
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public;
}


contract Resume is ERC721 {
    string private _name;
    string private _symbol;
    Art[] public arts;
    uint256 private pendingArtCount;
    mapping(uint256 => address) private _tokenOwner;
    mapping(address => uint256) private _ownedTokenCount;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => ArtTxn[]) private artTxns;
    uint256 public index;

    struct Art {
        uint256 id;
        string title;
        string description;
        uint256 price;
        string date;
        string authorName;
        address payable author;
        address payable owner;
        uint256 status;
        string image;
    }

    struct ArtTxn {
        uint256 id;
        uint256 price;
        address seller;
        address buyer;
        uint256 txnDate;
        uint256 status;
    }

    event LogArtSold(
        uint256 _tokenId,
        string _title,
        string _authorName,
        uint256 _price,
        address _author,
        address _current_owner,
        address _buyer
    );
    event LogArtTokenCreate(
        uint256 _tokenId,
        string _title,
        string _category,
        string _authorName,
        uint256 _price,
        address _author,
        address _current_owner
    );
    event LogArtResell(uint256 _tokenId, uint256 _status, uint256 _price);

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function createAndSellArt(
        string memory _title,
        string memory _description,
        string memory _date,
        string memory _authorName,
        uint256 _price,
        string memory _image
    ) public {
        require(bytes(_title).length > 0, "The title cannot be empty");
        require(bytes(_date).length > 0, "The Date can not be empty");
        require(
            bytes(_description).length > 0,
            "The description can not be empty"
        );
        require(_price > 0, "The price cannot be empty");
        require(bytes(_image).length > 0, "The image cannot be empty");
        Art memory _art = Art({
            id: index,
            title: _title,
            description: _description,
            price: _price,
            date: _date,
            authorName: _authorName,
            author: msg.sender,
            owner: msg.sender,
            status: 1,
            image: _image
        });
        uint256 tokenId = arts.push(_art) - 1;
        _mint(msg.sender, tokenId);
        emit LogArtTokenCreate(
            tokenId,
            _title,
            _date,
            _authorName,
            _price,
            msg.sender,
            msg.sender
        );
        index++;
        pendingArtCount++;
    }

    function buyArt(uint256 _tokenId) public payable {
        (
            uint256 _id,
            string memory _title,
            ,
            uint256 _price,
            uint256 _status,
            ,
            string memory _authorName,
            address _author,
            address payable _currentOwner,

        ) = findArt(_tokenId);
        require(_currentOwner != address(0), '');
        require(msg.sender != address(0), '');
        require(msg.sender != _currentOwner, '');
        require(msg.value >= _price, '');
        require(arts[_tokenId].owner != address(0), '');

        _transfer(_currentOwner, msg.sender, _tokenId);

        if (msg.value > _price) msg.sender.transfer(msg.value - _price);

        _currentOwner.transfer(_price);

        arts[_tokenId].owner = msg.sender;
        arts[_tokenId].status = 0;
        ArtTxn memory _artTxn = ArtTxn({
            id: _id,
            price: _price,
            seller: _currentOwner,
            buyer: msg.sender,
            txDate: now,
            status: _status
        });

        artTxns[_id].push(_artTxn);
        pendingArtCount--;

        emit LogArtSold(_tokenId, _title, _authorName, _price, _author, _currentOwner, msg.sender);
    }

    function _exists(uint256 tokenId) internal view returns(bool){
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /** 铸造token, 把新的token增加到合约中
     */
    function _mint(address _to, uint256 tokenId) internal {
        require(_to != address(0), '');
        require(!_exists(tokenId), '');
        _tokenOwner[tokenId] = _to;
        _ownedTokenCount[_to]++;
        emit Transfer(address(0), _to, tokenId);
    }
}
