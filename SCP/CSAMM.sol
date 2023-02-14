// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IERC20.sol";

contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0;
    uint public reserve1; 

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount; 
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount; 
    }
    function _update(uint _res0, uint _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }

    function swap(address _tokenIn, uint _amountIn)payable external returns
    (uint amountOut) {
        require(_tokenIn == address(token0)|| _tokenIn == address(token1),"invalid token");

    
    bool isToken0 = _tokenIn == address(token0);
    (IERC20 tokenIn, IERC20 tokenOut, uint resIn, uint resOut) = isToken0 ? (token0 , token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);
    
        //transfer token in
      tokenIn.transferFrom(msg.sender, address(this), resIn);
            uint amountIn = token0.balanceOf(address(this)) - reserve0;
        //0.3%
        amountOut = (amountIn * 997)/1000;

        //update reserve0 and reserve1
        (uint res0, uint res1) = isToken0
        ? (resIn + _amountIn, resOut - amountOut)
        : (resOut - amountOut, resIn + _amountIn);
        _update(res0, res1);

        

        // transfer token out
        
           tokenOut.transfer(msg.sender, amountOut);
      



    }
    function addLiquidity(uint _amount0, uint _amount1) external returns (uint shares){
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));

        uint d0 = bal0 - reserve0;
        uint d1 = bal1 - reserve1;

        if(totalSupply == 0) {
            shares = d0 + d1;
        } else {
            shares = ((d0 + d1)* totalSupply/ (reserve1 + reserve0));
        }

        require(shares > 0, "shares = 0");
        _update(bal0, bal1);
    }
    function removeLiquidity(uint _shares) external returns (uint d0, uint d1) {
        d0 = (reserve0 * _shares) / totalSupply;
        d1 = (reserve1 * _shares)  / totalSupply;

        _burn(msg.sender, _shares);
        _update(reserve0 - d0, reserve1 - d1);

        if (d0 >0 ) {
            token0.transfer(msg.sender, d0);
        }
        if (d1 >0 ) {
            token1.transfer(msg.sender, d1);
        }
    }
}