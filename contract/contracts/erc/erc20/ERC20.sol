// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";

contract ERC20 is IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;

    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // region Base data

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view virtual override returns (uint256 balance) {
        return _balances[_owner];
    }

    // endregion

    // region Transfer

    function transfer(address _to, uint256 _value) public virtual override returns (bool success) {
        _transfer(msg.sender, _to, _value);
        success = true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool success){
        _transfer(_from, _to, _value);

        uint256 leftAllowance = _allowances[_from][msg.sender] - _value;
        require(leftAllowance >= 0);
        _approve(_from, msg.sender, leftAllowance);

        success = true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal virtual {
        require(_from != address(0));
        require(_to != address(0));

        _beforeTokenTransfer(_from, _to, _value);

        uint256 fromBalance = _balances[_from];
        require(fromBalance > _value);
        _balances[_from] = fromBalance - _value;
        _balances[_to] += _value;

        emit Transfer(_from, _to, _value);
        _afterTokenTransfer(_from, _to, _value);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address _from, address _to, uint256 amount) internal virtual {}

    // endregion

    // region Allowance

    function allowance(address _owner, address _spender) public view virtual override returns (uint256 remaining){
        return _allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public virtual override returns (bool success) {
        _approve(msg.sender, _spender, _value);
        success = true;
    }

    function _approve(address _owner, address _spender, uint256 _value) internal {
        require(_owner != address(0));
        require(_spender != address(0));

        _allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function incAllowance(address _spender, uint256 _incValue) public returns (bool) {
        require(_incValue > 0);
        _approve(msg.sender, _spender, _allowances[msg.sender][_spender] + _incValue);
        return true;
    }

    function decAllowance(address _spender, uint256 _decValue) public returns (bool) {
        require(_decValue > 0);

        uint256 curAllowance = _allowances[msg.sender][_spender];
        require(curAllowance > _decValue);

        _approve(msg.sender, _spender, curAllowance - _decValue);
        return true;
    }

    // endregion

    function mint(address _to, uint256 _value) public virtual {
        require(_to != address(0));
        require(_value > 0);

        _beforeTokenTransfer(address(0), _to, _value);

        _totalSupply += _value;
        _balances[_to] += _value;
        emit Transfer(address(0), _to, _value);

        _afterTokenTransfer(address(0), _to, _value);
    }

    function burn(address _from, uint256 _value) public virtual {
        require(_from != address(0));
        require(_value > 0);

        _beforeTokenTransfer(_from, address(0), _value);

        uint256 curBalance = _balances[_from];
        require(curBalance > _value);
        _balances[_from] = curBalance - _value;
        _totalSupply -= _value;

        emit Transfer(_from, address(0), _value);
        _afterTokenTransfer(_from, address(0), _value);
    }

}
