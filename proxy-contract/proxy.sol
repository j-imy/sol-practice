// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract Proxy{
    address implementation;

    function changeImplementation(address _implementation) external{
        implementation = _implementation;
    }

    function changeX(uint _x) external{
        Logic1(implementation).changeX(_x);
    }
}


contract Logic1{
    uint public x = 0;
    function changeX(uint _x) external{
        x = _x;
    }
}


contract Logic2{
    uint public x = 0;
    function changeX(uint _x) external{
        x = _x;
    }
}
