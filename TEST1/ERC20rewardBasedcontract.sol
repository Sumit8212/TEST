// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";

// STANDARD ERC20 TOKEN
contract StandardToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("SumoToken", "ST") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

// REWARD ERC20 TOKEN

contract RewardToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("RewardToken", "RWD") {
        _mint(msg.sender, 100 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract StakingContract {
    StandardToken public standardToken;
    RewardToken public rewardToken;

    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public lastStakedTime;

    event Staked(address indexed staker, uint256 amount);
    event Withdrawn(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 amount);

    constructor(address _standardToken, address _rewardToken) {
        standardToken = StandardToken(_standardToken);
        rewardToken = RewardToken(_rewardToken);
    }

    // PUT ON STAKE FUNCTION //
    function stake(uint256 _amount) public {
        require(_amount > 0, "Invalid amount");
        standardToken.transferFrom(msg.sender, address(this), _amount);
        stakedAmount[msg.sender] += _amount;
        lastStakedTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, _amount);
    }

    // WITHDRAW FUNCTION //
    function withdraw() public {
        uint256 amount = stakedAmount[msg.sender];
        require(amount > 0, "No stake found");
        uint256 reward = calculateReward(msg.sender);
        stakedAmount[msg.sender] = 0;
        lastStakedTime[msg.sender] = 0;
        if (reward > 0) {
            rewardToken.transfer(msg.sender, reward);
            emit RewardClaimed(msg.sender, reward);
        }
        standardToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    // CLAIM REWARD FUNCTION //
    function claimReward() public {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward available");
        lastStakedTime[msg.sender] = block.timestamp;
        rewardToken.transfer(msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }

    // CLAIM REWARD FUNCTION //

    function calculateReward(address _staker) public view returns (uint256) {
        uint256 stakedTime = block.timestamp - lastStakedTime[_staker];
        if (stakedTime < 10 seconds) {
            return 0;
        }
        uint256 rewardRate = 5; // 5 reward token per minute
        uint256 reward = (stakedAmount[_staker] * rewardRate * stakedTime) /
            10 seconds;
        return reward;
    }
}
