// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "@lens/interfaces/ILensHub.sol";
import "@lens/libraries/DataTypes.sol";
import "@solmate/tokens/ERC721.sol";
import "@solmate/auth/Owned.sol";
import "@solmate/utils/SafeTransferLib.sol";

/// @title PostDAO
/// @author The Newt team.
/// @notice An NFT collection that enables you to post on a lens profile owned by a DAO.
/// @dev An ERC-721 contract with mint, burn and a custom withdraw function.

contract PostDAO is ERC721, Owned {
    ILensHub lensHub;

    uint256 public constant TOTAL_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0 ether; // 0 matic
    uint256 public currentSupply;
    uint256 public profileId;
    string baseURI;

    error NotEnoughMatic();
    error NotEnoughNFTs();
    error NotYourNFT();

    event MintedNFT();
    event MoneyWithdrawn(uint256 quantity);
    event BurnedNFT(uint256 id);
    
    /// @dev Constructor of the contract.
    /// @param _name Collection name.
    /// @param _symbol Collection symbol.
    /// @param _baseURI Base URI for the tokenURI.
    /// @param _lensHub The address of a contract following the ILensHub interface.
    /// @param _profileId The profileId that will have the publications.
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        address _lensHub,
        uint256 _profileId
    ) ERC721(_name, _symbol) Owned(msg.sender) {
        currentSupply = 0;
        baseURI = _baseURI;
        lensHub = ILensHub(_lensHub);
        profileId = _profileId;
    }

    /// @dev Mints a new token with the given parameters.
    /// @param recipient The address that will receive the NFTs.
    /// @param amount The number of NFTs that the recipient will receive.
    function mint(address recipient, uint256 amount) external payable {
        if(currentSupply + amount > TOTAL_SUPPLY) revert NotEnoughNFTs();
        if(msg.value < MINT_PRICE * amount) revert NotEnoughMatic();

        unchecked {
            for (uint16 i = 0; i < amount; i++) {
                _mint(recipient, currentSupply++);
            }
        }

        emit MintedNFT();
    }

    /// @dev Burns the token with the given tokenId sending it to the address(0).
    /// @param tokenId Token id of the NFT that you are burning.
    // @param contentURI The URL that points to the post contentURI.
    // @param collectModule The address of the collectModule that you want to use on the post.
    // @param collectModuleInitData The init data in bytes that the collect module needs to get initialised.
    // @param referenceModule The address of the referenceModule that you want to use on the post.
    // @param referenceModuleInitData The init data in bytes that the reference module needs to get initialised.
    function burn(
        uint256 tokenId,
        string calldata contentURI,
        address collectModule,
        bytes calldata collectModuleInitData,
        address referenceModule,
        bytes calldata referenceModuleInitData
    ) external {
        if(msg.sender != ownerOf(tokenId)) revert NotYourNFT();
        _burn(tokenId);

        DataTypes.PostData memory data = DataTypes.PostData(
            profileId,
            contentURI,
            collectModule,
            collectModuleInitData,
            referenceModule,
            referenceModuleInitData
        );

        lensHub.post(data);
        emit BurnedNFT(tokenId);
    }

    /// @dev Withdraws the desired quantity of native token earned by the mintings to a specified address.
    /// @param quantity The amount of native tokens that you want to withdraw.
    /// @param recipent The address that will receive the funds.
    function withdraw(uint256 quantity, address recipent) external onlyOwner {
        SafeTransferLib.safeTransferETH(recipent, quantity);
        emit MoneyWithdrawn(quantity);
    }

    /// @dev Returns the URI of the token with the given tokenId.
    /// @param tokenId Token Id of the NFT that you are getting the URI.
    /// @return TBD.
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(baseURI, tokenId));
    }

    /// @dev Changes the profileId that the collection will post on (you need a dispatcher from lens profile to the smart contract).
    /// @param newProfileId The new profile id that will be set.
    function changeProfileId(uint256 newProfileId) public onlyOwner {
        profileId = newProfileId;
    }
}
