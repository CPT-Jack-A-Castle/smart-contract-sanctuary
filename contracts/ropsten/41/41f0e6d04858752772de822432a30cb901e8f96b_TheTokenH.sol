pragma solidity ^0.4.24;

library SafeMath {
    /**
    * Multiplies method
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    /**
    * Division method.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
    * Subtracts method.
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * Add method.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
contract ERC223Interface {
    uint public totalSupply;
    function balanceOf(address who) public constant returns (uint) ;
    function transfer(address to, uint value) public;
    function transfer(address to, uint value, bytes data) public;
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
contract ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value, bytes _data) public;
}
contract TheTokenH is ERC223Interface {
    using SafeMath for uint;
    address owner = msg.sender;
    mapping(address => uint) balances; // List of user balances.

    string public constant name = &quot;The Token H&quot;;
    string public constant symbol = &quot;TKH&quot;;
    uint public constant decimals = 8;
    uint256 public totalSupply = 690000000e8;
    uint256 public tokensPerEth = 15000000e8;
    uint256 public constant MIN_CONTRIBUTION = 1 ether / 100; // 0.01 Ether
    uint256 public totalDistributed = 0 ;
    bool public distributionFinished = false;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Distr(address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 value);
    event TokensPerEthUpdated(uint _tokensPerEth);
    event TransferOwnership(address _newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier canDistr() {
        require(!distributionFinished);
        _;
    }
    function TheTokenH() public {     

        distr(0x77b87ff0db2111c3faecf37a90860c426bcd865d, (totalSupply.div(100)).mul(5));
        distr(0xaff8e56ad310e59d222a462eb62b21c2f9037369, 138000000e8);
        distr(0x3a639048166fecb574c323804c92680cfd7791bf, (totalSupply.div(100)).mul(10));
        
    }
    
    function () external payable {
        getTokens();
     }
    function getTokens() payable canDistr public {
        uint256 tokens = 0;
        address investor = msg.sender; 
        if(msg.value >= MIN_CONTRIBUTION){
            tokens = tokensPerEth.mul(msg.value) / 1 ether;        
        }
        if (tokens > 0) {
            distr(investor, tokens);
        }
        if (totalDistributed >= totalSupply) {
            distributionFinished = true;
        }
        
    }
    function distr(address _to, uint256 _amount)  private returns (bool) {  
        totalDistributed = totalDistributed.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Distr(_to, _amount);
        emit Transfer(address(0), _to, _amount);

        return true;
    }
    function transferOwnership(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
        emit TransferOwnership(_newOwner);
    }
    function transfer(address _to, uint _value, bytes _data) public{
        uint codeLength;

        assembly {
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
         emit Transfer(msg.sender, _to, _value);
    }
  
    function transfer(address _to, uint _value) public{
        uint codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value,empty);
        }
        emit Transfer(msg.sender, _to, _value);
    }
    function updateTokensPerEth(uint _tokensPerEth) onlyOwner public {        
        tokensPerEth = _tokensPerEth;
        emit TokensPerEthUpdated(_tokensPerEth);
    }
    function burn(uint256 _value) onlyOwner public {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
    
    function withdraw() onlyOwner public {
        address myAddress = this;
        uint256 etherBalance = myAddress.balance;
        owner.transfer(etherBalance);
    }
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

}