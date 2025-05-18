// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "remix_tests.sol";
import "../contracts/OzushToken.sol";
import "../contracts/OzushExchangeOffice.sol";

contract ExchangeAdminTest {
    OzushToken token;
    OzushExchangeOffice office;

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
    }

    receive() external payable {}

    function testUpdateRates() public {
        uint256 newBuyRate = 1200;
        uint256 newSellRate = 2200;

        office.updateRates(newBuyRate, newSellRate);
        Assert.equal(office.buyRate(), newBuyRate, "Buy rate not updated");
        Assert.equal(office.sellRate(), newSellRate, "Sell rate not updated");
    }

    function testPauseUnpause() public {
        office.pause();
        Assert.ok(office.paused(), "Contract should be paused");

        office.unpause();
        Assert.ok(!office.paused(), "Contract should be unpaused");
    }

    function testWithdrawETH() public {
        uint256 before = address(this).balance;
        office.withdrawETH(payable(address(this)), 1 ether);
        uint256 afterBal = address(this).balance;

        Assert.ok(afterBal > before, "ETH should be withdrawn");
    }

    function testWithdrawTokens() public {
        uint256 before = token.balanceOf(address(this));
        office.withdrawTokens(address(this), 1000 ether);
        uint256 afterBal = token.balanceOf(address(this));

        Assert.equal(afterBal - before, 1000 ether, "Tokens should be withdrawn");
    }
}
