// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Register{

    struct User {
        string username;
        uint256 credit;
        uint256 score;
        bool won;
    }

    uint256 public x;
    uint256 public y;
    address public marketAddress;
    address public generatorAddress;
    address public ownerAddress;

    address[] addressList;
    
    mapping(address => User) addrToUser;
    mapping(uint256 => address) cardToOwner;


    event SignIn(address indexed userAddress, string username);
    event GetCard(address userAddress, uint256 cardnumber);
    event Win(address userAddress);

    modifier onlyMarket() {
        require(msg.sender == marketAddress);
        _;
    }

    function signIn(string memory _username) public {
        require(bytes(addrToUser[msg.sender].username).length == 0, "user has signed in before");
        
        ////number of users should be limited
        require(addressList.length <= x * y / ((x + y) / 2) + 2, "number of users limit");

        require(bytes(_username).length > 0, "set a username");

        addressList.push(msg.sender);
        addrToUser[msg.sender].username = _username;

        emit SignIn(msg.sender, _username);
    }

    function username(address userAddr) public view returns(string memory) {
        require(bytes(addrToUser[msg.sender].username).length > 0, "user has not sign in yet");
        return addrToUser[userAddr].username;
    }


////////////about cards

    function ownerOf(uint256 _cardNum) public view returns(address) {
        require(_cardNum < x * y, "this card does not exist.");
        require(cardToOwner[_cardNum] != address(0), "this card does not have an owner");
        return cardToOwner[_cardNum];
    }

    // function userCards(address _userAddr) public returns(uint[] memory) {}

    function _getCard(address _userAddr, uint256 _cardNum) public onlyMarket {
        require(bytes(addrToUser[_userAddr].username).length > 0, "user has not sign in yet");
        // addrToUser[_userAddr].cards.push(_cardNum);
        cardToOwner[_cardNum] = _userAddr;
        emit GetCard(_userAddr, _cardNum);
    }

    function _ownRestOfCards() internal {
        for(uint256 i = 0; i < x * y; i++){
            if(cardToOwner[i] == address(0)){
                cardToOwner[i] = generatorAddress;
            }
        }
    }
////////////about scores
    
    function userScore(address userAddr) public view returns(uint256) {
        return addrToUser[userAddr].score;
    }

    function _resetScores() private {
        for(uint256 i = 0; addressList[i] != address(0); i++) {
            addrToUser[addressList[i]].score = 0;
        }
    }
    
    function _updateScores() internal {
        _resetScores();

        for(uint256 i = 0; i < x * y; i++){
            if(cardToOwner[i] != address(0)){
                //one score for each card
                addrToUser[cardToOwner[i]].score++;
                //one score for right side
                if(cardToOwner[i] == cardToOwner[i + 1]) {addrToUser[cardToOwner[i]].score++;}
                //one score for bottom side
                if(cardToOwner[i] == cardToOwner[i + x]) {addrToUser[cardToOwner[i]].score++;}
            }
        }
    }

    function _whoWins() internal view returns(address) {
        address winner = addressList[0];
        for(uint256 i = 1; addressList[i] != address(0); i++) {
            if(addrToUser[addressList[i]].score > addrToUser[addressList[i - 1]].score) {winner = addressList[i];}
        }
        return winner;
    }

    function _win(address _userAddr) internal {
        require(bytes(addrToUser[msg.sender].username).length > 0, "user has not sign in yet");
        addrToUser[_userAddr].won = true;
        emit Win(_userAddr);
    }

////////////about credit

    function charge() public payable {
        require(msg.value > 0, "zero charging value");
        addrToUser[msg.sender].credit += msg.value;
    }

    function withdraw() public {
        uint amount = addrToUser[msg.sender].credit;
        addrToUser[msg.sender].credit = 0;
        address payable reciever;
        if(msg.sender != ownerAddress) {reciever = payable(msg.sender);}
        else {reciever = payable(ownerAddress);}
        reciever.transfer(amount);
    }

    function checkCredit(address _userAddr) public view returns(uint256) {
        return addrToUser[_userAddr].credit;
    }

    function increaseCredit(address _userAddr, uint256 _value) public onlyMarket {
        addrToUser[_userAddr].credit += _value;
    }

    function decreaseCredit(address _userAddr, uint256 _value) public onlyMarket {
        addrToUser[_userAddr].credit -= _value;
    }
}