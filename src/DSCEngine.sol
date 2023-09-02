// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
* @title DSCEngine
* @author Adrian Zeni
* Desgined to be minimal, keeping a $1 peg
* (eventually spx)
* 
* Similar to DAI but without governance/fees. Our system should always
* be overcollateralized as well.
*
* @notice This contract is the core, handling all mining
* and redeeming logic, as well as deposits and withdrawls
*/

contract DSCEngine is ReentrancyGuard {


    //////////////////////////////////////////
    // errors 
    ////////////////////////////////////////// 

    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();

    //////////////////////////////////////////
    // state vars 
    ////////////////////////////////////////// 

    mapping(address token => address priceFeed) private s_priceFeeds; //tokenToPriceFeed
    mapping(address user => mapping(address token => uint256 amount)) 
        private s_collateralDeposited;

    DecentralizedStableCoin private immutable i_dsc;

    //////////////////////////////////////////
    // events
    ////////////////////////////////////////// 
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    //////////////////////////////////////////
    // modifiers 
    ////////////////////////////////////////// 

    modifier moreThanZero(uint256 amount) {
        if(amount == 0) {
            revert DSCEngine__NeedsMoreThanZero(); 
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if(s_priceFeeds[token] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    //////////////////////////////////////////
    // functions 
    ////////////////////////////////////////// 

    constructor(
        address[] memory tokenAddresses, 
        address[] memory priceFeedAddresses,
        address dscAddress
    ) {
        //usd price feeds
        if(tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }



    //////////////////////////////////////////
    // external functions 
    ////////////////////////////////////////// 

    function depositCollateralAndMintDsc() external {}

    /**
     * @notice follows CEI pattern
     * @param tokenCollateralAddress - The address of token to deposit at collateral
     * @param amountCollateral - The amount of collateral to deposit
     */


    function depositCollateral(
        address tokenCollateralAddress, 
        uint256 amountCollateral
    ) 
        external 
        moreThanZero(amountCollateral) 
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}




}
