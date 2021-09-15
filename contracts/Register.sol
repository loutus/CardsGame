// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


contract Register{

    struct User {
        string username;
        uint256[] cards;
        bool won;
    }

    mapping(address => User) users;

    event SignIn(address indexed userAddress, string username);
    event GetCard(address userAddress, uint256 cardnumber);
    event Win(address userAddress);

    function username(address userAddr) public view returns(string memory) {
        require(bytes(users[msg.sender].username).length > 0, "user has not sign in yet");
        return users[userAddr].username;
    }

    function userCards(address userAddr) public view returns(uint256[] memory) {
        require(bytes(users[msg.sender].username).length > 0, "user has not sign in yet");
        return users[userAddr].cards;
    }

    function signIn(string memory _username) public {
        require(bytes(users[msg.sender].username).length == 0, "user has signed in before");
        require(bytes(_username).length > 0, "set a username");

        users[msg.sender].username = _username;

        emit SignIn(msg.sender, _username);
    }

    function _getCard(address _userAddr, uint256 _cardNum) internal {
        require(bytes(users[msg.sender].username).length > 0, "user has not sign in yet");
        users[_userAddr].cards.push(_cardNum);
        emit GetCard(_userAddr, _cardNum);
    }

    function _win(address _userAddr) internal {
        require(bytes(users[msg.sender].username).length > 0, "user has not sign in yet");
        users[_userAddr].won = true;
        emit Win(_userAddr);
    }
}