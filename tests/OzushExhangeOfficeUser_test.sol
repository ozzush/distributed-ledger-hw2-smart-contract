// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "remix_tests.sol"; 
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

contract ExchangeBuySellTest {
    OzushToken token;
    OzushExchangeOffice office;
    UserSimulator user;

    uint256 buyRate = 1000;
    uint256 sellRate = 2000;

    function beforeEach() public {
        token = new OzushToken(1_000_000 ether);
        office = new OzushExchangeOffice(
            address(this),
            IERC20(address(token)),
            buyRate,
            sellRate
        );

        token.mint(address(office), 500_000 ether);
        payable(address(office)).transfer(10 ether);

        user = new UserSimulator(token, office);
        token.mint(address(user), 2_000 ether);
    }

    receive() external payable {}

    function testBuyTokens() public {
        uint256 ethToSend = 1 ether;
        uint256 expectedTokens = (ethToSend * 1e18) / buyRate;

        uint256 prevBalance = token.balanceOf(address(this));
        office.buyTokens{value: ethToSend}();
        uint256 newBalance = token.balanceOf(address(this));

        Assert.equal(newBalance - prevBalance, expectedTokens, "Token amount mismatch");
    }

    function testSellTokens() public {
        uint256 tokenAmount = 2000 ether;
        uint256 ethExpected = (tokenAmount * 1e18) / sellRate;

        uint256 preETH = address(user).balance;
        user.sell(tokenAmount);
        uint256 postETH = address(user).balance;

        Assert.ok(postETH > preETH, "User should receive ETH");
    }
}
