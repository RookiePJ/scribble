pragma solidity 0.8.4;

contract Foo {
    // Simple map
    uint[] a = [10];
    int8[] b;

    /// @custom:scribble #if_succeeds unchecked_sum(a) > 10 && unchecked_sum(a) < 20;
    function pushA(uint k) public {
        a.push(k);
    }

    /// ignored @custom:scribble #if_succeeds unchecked_sum(a) > 10 && unchecked_sum(a) < 20;
    function setA(uint k, uint v) public {
        a[k] = v;
    }

    /// @custom:scribble #if_succeeds unchecked_sum(b) > -10 && unchecked_sum(b) < 10;
    function pushB(int8 k) public {
        b.push(k);
    }

    /// @custom:scribble #if_succeeds unchecked_sum(b) > -10 && unchecked_sum(b) < 10;
    function setB(uint k, int8 v) public {
        b[k] = v;
    }
    

    /// @custom:scribble #if_succeeds unchecked_sum(c) > -10 && unchecked_sum(c) < 10;
    function memArr(int16[] memory c) public {
    }

    /// @custom:scribble #if_succeeds unchecked_sum(c) > -10 && unchecked_sum(c) < 10;
    function calldataArr(int16[] calldata c) external {
    }

    /// #if_succeeds unchecked_sum(c) < 10;
    function overflowCheck(uint[] calldata c) external {
    }
}
