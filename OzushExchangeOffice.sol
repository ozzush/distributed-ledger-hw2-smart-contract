pragma solidity 0.8.29;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract OzushExchangeOffice is Ownable2Step, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public token;
    uint256 public buyRate;
    uint256 public sellRate;
    uint8 private _inProgress = 1;  // Avoid zero-to-one write

    event TokensBought(address indexed buyer, uint256 ethSpent, uint256 tokensReceived);
    event TokensSold(address indexed seller, uint256 tokensSold, uint256 ethReceived);
    event ETHWithdrawn(address indexed to, uint256 amount);
    event TokensWithdrawn(address indexed to, uint256 amount);
    event RatesUpdated(uint256 newBuyRate, uint256 newSellRate);
    event Paused();
    event Unpaused();

    constructor(address initialOwner, IERC20 _token, uint256 _buyRate, uint256 _sellRate) 
        Ownable(initialOwner)
        payable 
    {
        require(initialOwner != address(0), "Zero owner");
        require(address(_token) != address(0), "Zero token");
        require(_buyRate != 0, "Zero buyRate");
        require(_sellRate != 0, "Zero sellRate");

        token = _token;
        buyRate = _buyRate;
        sellRate = _sellRate;
    }

    modifier nonReentrant() {
        require(_inProgress == 1, "Reentrancy");
        _inProgress = 2;
        _;
        _inProgress = 1;
    }

    function buyTokens() external payable nonReentrant {
        require(msg.value != 0, "No ETH");

        uint256 tokensToBuy = (msg.value * 1e18) / buyRate;
        require(tokensToBuy != 0, "Too little ETH");

        require(token.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens");
        token.safeTransfer(msg.sender, tokensToBuy);

        emit TokensBought(msg.sender, msg.value, tokensToBuy);
    }

    function sellTokens(uint256 tokenAmount) external nonReentrant payable {
        require(tokenAmount != 0, "No tokens");

        uint256 ethAmount = (tokenAmount * 1e18) / sellRate;
        require(ethAmount != 0, "Too few tokens");

        address self = address(this);
        IERC20 _token = token;
        
        require(self.balance > ethAmount, "Low ETH");
        require(_token.balanceOf(self) >= tokenAmount, "Low token");

        _token.safeTransferFrom(msg.sender, self, tokenAmount);

        (bool sent, ) = msg.sender.call{value: ethAmount}("");
        require(sent, "ETH send fail");

        emit TokensSold(msg.sender, tokenAmount, ethAmount);
    }

    function withdrawETH(address payable to, uint256 amount) external onlyOwner payable {
        require(to != address(0), "Zero address");
        require(amount != 0, "Zero amount");
        uint256 selfbal;
        assembly {
            selfbal := selfbalance()
        }
        require(selfbal > amount, "Low ETH");

        (bool success, ) = to.call{value: amount}("");
        require(success, "Withdraw fail");

        emit ETHWithdrawn(to, amount);
    }

    function withdrawTokens(address to, uint256 amount) external onlyOwner payable {
        require(to != address(0), "Zero address");
        require(amount != 0, "Zero amount");
        require(token.balanceOf(address(this)) >= amount, "Low token");

        IERC20 _token = token;
        _token.safeTransfer(to, amount);

        emit TokensWithdrawn(to, amount);
    }

    function updateRates(uint256 _buyRate, uint256 _sellRate) external onlyOwner payable  {
        require(_buyRate != 0, "Zero buy");
        require(_sellRate != 0, "Zero sell");

        if (_buyRate != buyRate) {
            buyRate = _buyRate;
        }

        if (_sellRate != sellRate) {
            sellRate = _sellRate;
        }

        emit RatesUpdated(_buyRate, _sellRate);
    }

    function pause() external onlyOwner payable {
        _pause();
        emit Paused();
    }

    function unpause() external onlyOwner payable {
        _unpause();
        emit Unpaused();
    }

}
