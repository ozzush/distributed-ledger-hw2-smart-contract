// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "../contracts/OzushToken.sol";
import "../contracts/OzushExchangeOffice.sol";

contract UserSimulator {
    OzushToken public token;
    OzushExchangeOffice public office;

    constructor(OzushToken _token, OzushExchangeOffice _office) {
        token = _token;
        office = _office;
        token.approve(address(office), type(uint256).max);
    }

    function sell(uint256 amount) external {
        office.sellTokens(amount);
    }

    receive() external payable {}
}
