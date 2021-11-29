pragma solidity >=0.6.0 <0.7.0;

contract ExampleExternalContract {

  bool public completed;

  function checkCompleted() public view returns (bool) {
    return completed;
  }
  
  function complete() public payable {
    completed = true;
  }

}
