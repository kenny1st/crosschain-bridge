
---

### **Example Solidity Contract (`contracts/Bridge.sol`)**  
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrossChainBridge is Ownable {
    mapping(bytes32 => bool) public processedTransactions;
    IERC20 public token;

    event TokenLocked(address indexed user, uint256 amount, bytes32 txHash);
    event TokenReleased(address indexed user, uint256 amount, bytes32 txHash);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function lockTokens(uint256 _amount, bytes32 _txHash) public {
        require(!processedTransactions[_txHash], "Transaction already processed");
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        processedTransactions[_txHash] = true;
        emit TokenLocked(msg.sender, _amount, _txHash);
    }

    function releaseTokens(address _recipient, uint256 _amount, bytes32 _txHash) external onlyOwner {
        require(!processedTransactions[_txHash], "Transaction already processed");

        processedTransactions[_txHash] = true;
        require(token.transfer(_recipient, _amount), "Transfer failed");

        emit TokenReleased(_recipient, _amount, _txHash);
    }
}
