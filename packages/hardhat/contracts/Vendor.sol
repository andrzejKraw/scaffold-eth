pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable{

  YourToken yourToken;
  uint256 public constant tokensPerEth = 100;
  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfEth);

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }

  

  function buyTokens() public payable  {
    require(msg.value > 0, "You need to send some ETH");
    uint256 amountOfTokens = msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokens);

    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
  }

  function sellTokens(uint256 _amount) public {
    require (_amount > 0, "Amount has to be bigger than 0");
    
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(_amount <= userBalance, "Amount to sell must be lower or equal to your balance");
    
    uint256 amountOfEthToTransfer = _amount / tokensPerEth;
    uint256 ownerEthBalance = address(this).balance;
    require(ownerEthBalance >= amountOfEthToTransfer, "Vendor does not have enough funds");
    
    (bool tokensSent) = yourToken.transferFrom(msg.sender, address(this), _amount);

    require(tokensSent, "Something went wrong with sending tokens");

    (bool ethSent,) = msg.sender.call{value: amountOfEthToTransfer}("");

    require(ethSent, "Something went wrong");

    emit SellTokens(msg.sender, _amount, amountOfEthToTransfer);

  }
  function withdraw() public onlyOwner {
    (bool ethSent, ) = msg.sender.call{value: address(this).balance}("");
  }

}
