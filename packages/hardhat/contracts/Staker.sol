pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  
  event Stake(address _addr, uint256 amountStaked);
  
  modifier afterDeadline() {
    require(now > deadline, "too little time has passed");
    _;
  }

  modifier notCompleted() {
    require(exampleExternalContract.checkCompleted() == false, "The contract has been completed already");
    _;
  }

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  mapping (address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = now + 30 seconds;
  bool openForWithdraw = true;

  function stake() public payable notCompleted {
      balances[msg.sender] += msg.value;
      emit Stake(msg.sender, balances[msg.sender]);
  }

  function execute() public afterDeadline {
    require(address(this).balance > threshold, "threshold hasn't been reached yet");

    exampleExternalContract.complete{value: address(this).balance}();

  }

  function withdraw() public notCompleted {
    require(address(this).balance < threshold, "the threshold value was reached. Funds are locked.");
    require(balances[msg.sender] > 0, "you haven't deposited, yet");
    
    uint256 amount = balances[msg.sender];

    balances[msg.sender] = 0;
    msg.sender.transfer(amount);

  }

  function timeLeft() public view returns (uint256) {
    if (now < deadline) {
      return deadline - now;
    } else {
      return 0;
    }
  }
}
