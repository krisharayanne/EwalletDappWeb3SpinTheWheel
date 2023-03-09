// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract EbricAssetToken is ERC1155{
    // Declare the priceFeed as an Aggregator Interface
    AggregatorV3Interface internal priceFeed;
    string public name;
    string public symbol;

constructor() ERC1155("") {
    name = "EbricAssetToken";
    symbol = "EAT";
    /** Define the priceFeed
* Network: Polygon Mumbai
    * Aggregator: MATIC/USD
      * Address: 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
      */
        priceFeed = AggregatorV3Interface(
            0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
        );
}

    // Creating an enumerator
    enum UserStatus
    {
      Unverified,
      Verified
    } 

    enum AssetType {
        Tangible,
        Intangible
    }

    struct User {
        string name;
        string email;
        string contactNumber;
        address payable walletAddress;
        UserStatus userStatus;
    }

    struct UserCredentials {
        string username;
        string passwordHash;
    }

    struct Asset {
        AssetType assetType;
        string assetCategory; // e.g., restaurant, franchise, real estate, luxury item
        uint256 assetValue; // assetValue = tokenQuantity * tokenPrice 
        string assetMetadata; // get ipfs CID for assetMetadata.json file (assetName, assetDescription, assetImage: image file CID)
    }

    struct Token {
        uint256 tokenQuantity; // to be determined by user
        uint256 tokenPrice; // to be determined by user
    }

    uint256 public userIDCount = 0;
    uint256 public assetIDCount = 0;
    uint256 public tokenIDCount = 0;

    mapping(string => uint256) public loginRequestIDToUserID;
    mapping(uint256 => User) public userIDToUser;
    mapping(uint256 => UserCredentials) public userIDToUserCredentials;
    mapping(uint256 => uint256[]) public userIDToAssetID;
    mapping(uint256 => Asset) public assetIDToAsset;
    mapping(uint256 => Token) public tokenIDToToken;
    mapping(uint256 => uint256) public assetIDToTokenID;
    mapping(uint256 => uint256) public tokenIDToAssetID;

    // asset must belong to user transferring token
    modifier assetBelongsToUser(uint256 _fromUserID, uint256 _assetID) {
        bool assetBelongsToUserTransferringToken = false;
        uint256[] memory tempAssetIDs = userIDToAssetID[_fromUserID];
        for(uint256 i = 0; i < tempAssetIDs.length; i++) {
            if(tempAssetIDs[i] == _assetID) {
                assetBelongsToUserTransferringToken = true;
                break;
            }
        }
        require(assetBelongsToUserTransferringToken == true);
        _;
    }

    // addUser function corresponds to sign up functionality
    function addUser(string memory _name, string memory _username, string memory _passwordHash, string memory _email,
    string memory _contactNumber, address payable _walletAddress) public {
        userIDCount += 1;
        User memory user = User(_name, _email, _contactNumber, _walletAddress, UserStatus.Unverified);
        UserCredentials memory userCredentials = UserCredentials(_username, _passwordHash);

        // map userID to user
        userIDToUser[userIDCount] = user;

        // map userID to userCredentials
        userIDToUserCredentials[userIDCount] =  userCredentials;
    }

    // get userID from email, generate new password, hash new password, call resetPasswordHash function
    // get userID from window session storage, retrieve entered new password, hash new password, call resetPasswordHash function
    function resetPasswordHash(uint256 _userID, string memory _newPasswordHash) public {
        userIDToUserCredentials[_userID].passwordHash = _newPasswordHash;
    }

    // verifyUser function corresponds to login functionality
    function verifyUser(string memory _loginRequestID, string memory _username, string memory _passwordHash) public {
        for(uint256 i = 1; i <= userIDCount; i++) { // start for loop statement

            // Check if user is valid
            if(keccak256(abi.encodePacked(userIDToUserCredentials[i].username)) == keccak256(abi.encodePacked(_username))) { // start first if statement
               
                // Check if password is correct
                if(keccak256(abi.encodePacked(userIDToUserCredentials[i].passwordHash)) == keccak256(abi.encodePacked(_passwordHash))) { // start second if statement
                    loginRequestIDToUserID[_loginRequestID] = i;
                } // end second if statement

            } // end first if statement

        } // end for loop statement
    }

    // addAsset function corresponds to list asset functionality
    function addAsset(uint256 _userID, AssetType _assetType, string memory _assetCategory, string memory _assetMetadata,
     uint256 _tokenQuantity, uint256 _tokenPrice) public {
        assetIDCount += 1;
        tokenIDCount += 1;
        uint256 tempAssetValue = _tokenQuantity * _tokenPrice;
        Asset memory asset = Asset(_assetType, _assetCategory, tempAssetValue, _assetMetadata);
        Token memory token = Token(_tokenQuantity, _tokenPrice);
        // map assetID to asset
        assetIDToAsset[assetIDCount] = asset;

        // map tokenID to token
        tokenIDToToken[tokenIDCount] = token;

        // mint tokens to user's wallet address
           _mint(userIDToUser[_userID].walletAddress, tokenIDCount, _tokenQuantity, "");

        // map assetID to tokenID
        assetIDToTokenID[assetIDCount] = tokenIDCount;

        // map tokenID to assetID
        tokenIDToAssetID[tokenIDCount] = assetIDCount;

        // map userID to assetID
        userIDToAssetID[_userID].push(assetIDCount);
    }

    // transferAssetToken function corresponds to purchase asset token functionality
    function transferAssetToken(uint256 _fromUserID, uint256 _toUserID, uint256 _tokenQuantity, uint256 _assetID) public 
    assetBelongsToUser(_fromUserID, _assetID){
        uint256 tempTokenID = assetIDToTokenID[_assetID];

        // Authorize company wallet to transfer tokens to buyers on user's behalf
        _setApprovalForAll(userIDToUser[_fromUserID].walletAddress, msg.sender, true);

        safeTransferFrom(userIDToUser[_fromUserID].walletAddress, userIDToUser[_toUserID].walletAddress, tempTokenID, _tokenQuantity, "");
    }

      /**
    * Returns the latest price and # of decimals to use
    */
    function getLatestPrice() public view returns (int256, uint8) {
// Unused returned values are left out, hence lots of ","s
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint8 decimals = priceFeed.decimals();
        return (price, decimals);
    }

}