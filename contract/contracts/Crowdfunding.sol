// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Crowdfunding {
    // 创作者
    address public author;

    // 参与金额
    mapping(address => uint256) public joined;

    // 众筹目标
    uint256 constant Target = 10 ether;

    // 众筹截止时间
    uint256 public endTime;

    // 记录当前众筹价格
    uint256 public price = 0.2 ether;

    // 作者提取资金之后，关闭众筹
    bool public closed = false;

    // 部署合约时调用，初始化作者以及众筹结束时间
    constructor() {
        author = msg.sender;
        endTime = block.timestamp + 30 days;
    }

    // 更新价格，这是一个内部函数
    function updatePrice() internal {
        uint256 rise = (address(this).balance / 1 ether) * 0.002 ether;
        price = 0.2 ether + rise;
    }

    // 用户向合约转账时 触发的回调函数
    function pay() external payable {
        // require(block.timestamp < endTime && !closed);
        // require(joined[msg.sender] == 0);
        // require(msg.value >= price);
        joined[msg.sender] = 0.2 ether;
        updatePrice();
    }

    // 作者提取资金
    function withdrawFund() external payable {
        require(msg.sender == author);
        require(address(this).balance >= Target);
        closed = true;
        payable(msg.sender).transfer(address(this).balance);
    }

    // 读者赎回资金
    function withdraw() external {
        require(block.timestamp > endTime);
        require(!closed);
        require(Target > address(this).balance);

        payable(msg.sender).transfer(joined[msg.sender]);
    }
}
