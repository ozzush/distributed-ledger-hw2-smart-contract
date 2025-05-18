// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.29;

import "remix_tests.sol";
import "../contracts/OzushToken.sol";
import "../contracts/OzushExchangeOffice.sol";
import "./UserSimulator.sol";

contract ExchangeBuySellTest {
    OzushToken token;
    OzushExchangeOffice office;
    UserSimulator user;

    uint256 buyRate = 1000;
    uint256 sellRate = 2000;

    // Make the test contract receive ETH
    receive() external payable {}

    function beforeEach() public {
        // Deploy token; owner is this test contract
        token = new OzushToken(1_000_000);

        // Deploy exchange office
        office = new OzushExchangeOffice(
            IERC20(address(token)),
            buyRate,
            sellRate
        );

        // Fund exchange with tokens and ETH
        token.mint(address(office), 500_000 * 1e18);
        payable(address(office)).transfer(10 ether);

        // Deploy user simulator and fund it
        user = new UserSimulator(token, office);
        token.mint(address(user), 2_000 * 1e18);
    }

    function testBuyTokens() public {
        uint256 ethToSend = 1 ether;
        uint256 expectedTokens = (ethToSend * 1e18) / buyRate;

        uint256 prevBalance = token.balanceOf(address(this));
        office.buyTokens{value: ethToSend}();
        uint256 newBalance = token.balanceOf(address(this));

        Assert.equal(
            newBalance - prevBalance,
            expectedTokens,
            "Token amount mismatch after buy"
        );
    }

    function testSellTokens() public {
        uint256 tokenAmount = 2_000 * 1e18;
        uint256 expectedEth = (tokenAmount * 1e18) / sellRate;

        uint256 preBalance = address(user).balance;
        user.sell(tokenAmount);
        uint256 postBalance = address(user).balance;

        Assert.ok(
            postBalance > preBalance,
            "User should receive ETH from selling tokens"
        );
        Assert.ok(
            postBalance - preBalance >= expectedEth,
            "User ETH gain should match expected"
        );
    }
}
