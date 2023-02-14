// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MultiDeligateCall {
    error DelegateCallFailed();

    function multiDelegateCall(bytes[] calldata data)
    external
    payable
    returns (bytes[] memory results)
    {
        results = new bytes[](data.length);

        for (uint i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if(!ok) {
            revert DelegateCallFailed();
            }
            results[i] = res;
        }
    }

}

contract TestMultiDelegatecall is MultiDeligateCall {
    event Log(address caller, string func, uint i);

    function func1(uint x, uint y) external {
        emit Log(msg.sender, "func1", x + y);
    }
    function func2() external returns (uint) {
        emit Log(msg.sender, "func2", 2);
        return 111;
    }
}

contract Helper {
    function getFunc1Data(uint x, uint y) external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.func1.selector, x, y);
    }

    function getFunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.func2.selector);
    }


}